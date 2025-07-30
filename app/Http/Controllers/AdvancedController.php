<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Http\Resources\Launchpad as LaunchpadResource;
use App\Http\Resources\Trade;
use App\Http\Resources\Holder;
use App\Http\Resources\Msg;
use App\Models\Launchpad;
use App\Models\Rate;
use App\Models\Poolstat;
use App\Models\Trade as ModelsTrade;
use Carbon\Carbon;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use Inertia\Inertia;

class AdvancedController extends Controller
{
    /**
     * Display the advanced page with launchpads data.
     * @return \Illuminate\View\View
     */
    public function advanced(Request $request)
    {
        $keyword = $request->get('search');
        $perPage = 25;

        // Always get all launchpads for the main list (no search filter)
        $launchpadsQuery = Launchpad::query()
            ->with(['factory'])
            ->withSum(['trades as volume24h' => fn($q) => $q->where('created_at', '>=', now()->subDays(1))], 'usd')
            ->withCount(['trades']);

        $launchpadsItems = $launchpadsQuery->latest('volume24h')->paginate($perPage);

        return Inertia::render('Advanced/Advanced', [
            'launchpads' => LaunchpadResource::collection($launchpadsItems), 
            'type' => 'advanced',
            'top' => function () {
                return self::getTopLaunchpads();
            },
            'usdRates' => function () {
                return Rate::all()->keyBy('symbol');
            }
        ]);
    }

    public function search(Request $request)
    {
        $keyword = $request->get('search');
        $perPage = 25;
        $searchedLaunchpads = collect();
        if (!empty($keyword)) {
            $searchedQuery = Launchpad::query()
                ->with(['factory'])
                ->withSum(['trades as volume24h' => fn($q) => $q->where('created_at', '>=', now()->subDays(1))], 'usd')
                ->withCount(['trades'])
                ->where(function($q) use ($keyword) {
                    $q->where('contract', 'LIKE', "%$keyword%")
                      ->orWhere('token', 'LIKE', "%$keyword%")
                      ->orWhere('name', 'LIKE', "%$keyword%")
                      ->orWhere('symbol', 'LIKE', "%$keyword%")
                      ->orWhere('description', 'LIKE', "%$keyword%")
                      ->orWhere('website', 'LIKE', "%$keyword%");
                });
            $searchedLaunchpads = $searchedQuery->get();
        }
        return LaunchpadResource::collection($searchedLaunchpads);
    }

    /**
     * Display the advanced trading view for a specific launchpad.
     * @param  string  $contract
     * @return \Illuminate\View\View
     */
    public function advancedTradingView(Request $request, $contract)
    {
        $launchpad = Launchpad::where('contract', $contract)->firstOrFail();

        return Inertia::render('Advanced/AdvancedTradingView', [

            'launchpad' => function () use ($launchpad) {
                $launchpad->load(['factory', 'user']);
                $launchpad->loadCount(['holders']);
                return new LaunchpadResource($launchpad);
            },

            'rate' => function () use ($launchpad) {
                return Rate::query()->where('chainId', $launchpad->chainId)->first();
            },
            'stats' => function () use ($launchpad) {
                return self::getRank($launchpad->id);
            },
            'poolstats' => function () use ($launchpad) {
                return $this->getLatestStats($launchpad);
            },
            'trades' => function () use ($launchpad) {
                $trades = $launchpad->trades()->latest()->paginate(12);
                return Trade::collection($trades);
            },
            'holders' => function () use ($launchpad) {
                $holders = $launchpad->holders()->latest('qty')->take(100)->get();
                return Holder::collection($holders);
            },
            'msgs' => function () use ($launchpad) {
                $msgs = $launchpad->msgs()->with('user')->oldest()->take(50)->get();
                return Msg::collection($msgs);
            },
            'pinned' => function () use ($launchpad) {
                $msgs = $launchpad->msgs()->where('pinned', true)->latest()->take(2)->get();
                return Msg::collection($msgs);
            },
            'top' => function () {
                return self::getTopLaunchpads();
            },
            'report' => self::getTradeReport($launchpad->id)
        ]);
    }

    /**
     * Get the latest pool stats for a launchpad
     */
    public function getLatestStats(Launchpad $launchpad)
    {
        // Cache for 5 minutes since stats are updated every 5 minutes
        $stats = Cache::remember("pool_stats_{$launchpad->id}", 300, function () use ($launchpad) {
            return Poolstat::where('launchpad_id', $launchpad->id)
                ->latest('timestamp')
                ->first();
        });
        if (!$stats) {
            return [
                'priceChanges' => [
                    '1H' => 0,
                    '24H' => 0,
                    '7D' => 0
                ],
                'stats' => [
                    'volume24h' => 0,
                    'tvl' => 0,
                    'feeTier' => 0,
                    'transactions24h' => 0,
                    'totalTransactions' => 0,
                    'liquidity' => 0,
                    'currentPrice' => 0,
                    'minPrice' => 0,
                    'maxPrice' => 0
                ]
            ];
        }

        return [
            'priceChanges' => [
                '1H' => $stats->price_change_1h,
                '24H' => $stats->price_change_24h,
                '7D' => $stats->price_change_7d
            ],
            'stats' => [
                'volume24h' => $stats->volume_24h,
                'tvl' => $stats->tvl_usd,
                'feeTier' => $stats->fee_tier,
                'transactions24h' => $stats->transactions_24h,
                'totalTransactions' => $stats->total_transactions,
                'liquidity' => $stats->liquidity,
                'currentPrice' => $stats->token0_price,
                'minPrice' => $stats->min_price_24h,
                'maxPrice' => $stats->max_price_24h
            ]
        ];
    }

    /**
     * Get report for trading statistics for a launchpad
     * 
     * @param int $launchpadId
     * @return array
     */
    public static function getTradeReport($launchpadId)
    {
        $now = Carbon::now();

        // Time windows for price changes
        $timeWindows = [
            '5m' => $now->copy()->subMinutes(5),
            '1h' => $now->copy()->subHour(),
            '6h' => $now->copy()->subHours(6),
            '24h' => $now->copy()->subHours(24)
        ];
        $stats = [];
        // Calculate price changes for each time window
        foreach ($timeWindows as $period => $startTime) {
            $trades = ModelsTrade::where('launchpad_id', $launchpadId)
                ->where('created_at', '>=', $startTime)
                ->orderBy('created_at')
                ->get();
            $first = $trades->first();
            $last = $trades->last();
            if ($trades->count() >= 2) {
                $firstPrice = bcdiv("$first->usd", "$first->qty", 18);
                $lastPrice = bcdiv("$last->usd", "$last->qty", 18);
                $priceChange = bcdiv(bcsub($lastPrice, $firstPrice, 18), $firstPrice, 18) * 100;
            } else {
                $priceChange = 0;
            }
            $stats["change_{$period}"] = round($priceChange, 2);
        }

        // Get trade counts and volumes for last 24h
        $last24h = DB::table('trades')
            ->where('launchpad_id', $launchpadId)
            ->where('created_at', '>=', $timeWindows['24h'])
            ->select([
                DB::raw('COUNT(*) as total_txns'),
                DB::raw('COUNT(CASE WHEN type = "buy" THEN 1 END) as buys'),
                DB::raw('COUNT(CASE WHEN type = "sell" THEN 1 END) as sells'),
                DB::raw('SUM(usd) as volume'),
                DB::raw('SUM(CASE WHEN type = "buy" THEN usd ELSE 0 END) as buy_volume'),
                DB::raw('SUM(CASE WHEN type = "sell" THEN usd ELSE 0 END) as sell_volume'),
                DB::raw('COUNT(DISTINCT CASE WHEN type = "buy" THEN address END) as buyers'),
                DB::raw('COUNT(DISTINCT CASE WHEN type = "sell" THEN address END) as sellers'),
                DB::raw('COUNT(DISTINCT address) as makers')
            ])
            ->first();

        return [
            'price_changes' => [
                '5m' => $stats['change_5m'],
                '1h' => $stats['change_1h'],
                '6h' => $stats['change_6h'],
                '24h' => $stats['change_24h']
            ],
            'transactions' => [
                'total' => $last24h->total_txns ?? 0,
                'buys' => $last24h->buys ?? 0,
                'sells' => $last24h->sells ?? 0
            ],
            'volume' => [
                'total' => round($last24h->volume ?? 0),
                'buy' => round($last24h->buy_volume ?? 0),
                'sell' => round($last24h->sell_volume ?? 0)
            ],
            'participants' => [
                'total' => $last24h->makers ?? 0,
                'buyers' => $last24h->buyers ?? 0,
                'sellers' => $last24h->sellers ?? 0
            ]
        ];
    }

    public static function getRank(int $launchpadId): array
    {
        // Create a subquery for the volume aggregation
        $volumeQuery = DB::table('launchpads as l')
            ->select([
                'l.id',
                DB::raw('SUM(t.usd) as volume')
            ])
            ->leftJoin('trades as t', 'l.id', '=', 't.launchpad_id')
            ->groupBy('l.id');

        // Use the subquery to apply the window function
        $result = DB::table(DB::raw("({$volumeQuery->toSql()}) as volumes"))
            ->mergeBindings($volumeQuery)
            ->select([
                'volume as total_volume',
                DB::raw('DENSE_RANK() OVER (ORDER BY volume DESC) as position'),
                DB::raw('(SELECT COUNT(*) FROM launchpads) as total_launchpads')
            ])
            ->where('id', $launchpadId)
            ->first();

        if (!$result) {
            throw new \Exception("Launchpad with ID {$launchpadId} not found");
        }
        return [
            'rank' => (int)$result->position,
            'totalVolume' => (float)$result->total_volume ?? 0,
            'totalLaunchpads' => (int)$result->total_launchpads
        ];
    }

    public static function getTopLaunchpads(int $limit = 10)
    {
        // Create a subquery for the volume aggregation
        $volumeQuery = DB::table('launchpads as l')
            ->select([
                'l.id',
                'l.name',
                'l.symbol',
                'l.logo',
                'l.contract',
                'l.created_at',
                DB::raw('SUM(t.usd) as volume'),
                DB::raw('MAX(t.usd) as high'),
                DB::raw('MIN(t.usd) as low')
            ])
            ->leftJoin('trades as t', 'l.id', '=', 't.launchpad_id')
            ->groupBy('l.id', 'l.name', 'l.symbol', 'l.logo', 'l.contract', 'l.created_at');  // Added missing columns

        // Use the subquery to apply the window function
        return DB::table(DB::raw("({$volumeQuery->toSql()}) as volumes"))
            ->mergeBindings($volumeQuery)
            ->select([
                'id',
                'name',
                'symbol',
                'contract',
                'logo',
                'low',
                'high',
                'created_at',
                'volume as total_volume',
                DB::raw('DENSE_RANK() OVER (ORDER BY volume DESC) as position')
            ])
            ->orderBy('volume', 'desc')
            ->limit($limit)
            ->get();
    }
}
