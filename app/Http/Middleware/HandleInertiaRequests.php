<?php

namespace App\Http\Middleware;

use App\Http\Resources\User;
use App\Models\Factory;
use App\Models\Rate;
use App\Models\Setting;
use Auth;
use Cache;
use Illuminate\Http\Request;
use Illuminate\Support\Arr;
use Illuminate\Support\Facades\File;
use Inertia\Middleware;

class HandleInertiaRequests extends Middleware
{
    /**
     * The root template that is loaded on the first page visit.
     *
     * @var string
     */
    protected $rootView = 'app';

    /**
     * Determine the current asset version.
     */
    public function version(Request $request): ?string
    {
        return parent::version($request);
    }

    /**
     * Define the props that are shared by default.
     *
     * @return array<string, mixed>
     */
    public function share(Request $request): array
    {
        $setting = Setting::find(1);
        $isAdminRoute = str_starts_with(request()->route()?->getName() ?? '', 'admin.') ||
            str_starts_with(request()->path(), 'admin/');
        return [
            ...parent::share($request),
            'auth' => [
                'user' => Auth::check() ? new User($request->user()) : null,
            ],
            'flash' => value(function () use ($request) {
                return array_filter([
                    'info' => $request->session()->get('message') ?? $request->session()->get('info'),
                    'error' => $request->session()->get('error'),
                    'success' => $request->session()->get('success'),
                ]);
            }),
            'links' => [...config('app.links', []), ...Arr::only(
                $setting->toArray(),
                [
                    'twitter',
                    'youtube',
                    'tgGroup',
                    'tgChannel',
                    'discord',
                    'documentation',
                ]
            )],
            'appName' => $setting->name ?? config('app.name'),
            'appLogo' => $setting->logo,
            'uploadsDisk' => fn() => config('filesystems.default'),
            's3' => fn() => config('filesystems.default') != 'public',
            'profilePhotoDisk' => fn() => config('filesystems.profile_photo_disk'),
            'chainIds' => fn() => Cache::remember('chainids', 60, function () {
                $foundry = json_decode(File::get(base_path('evm/Foundry.json')), true);
                return array_keys($foundry['addresses']);
            }),
            ...Arr::only(
                $setting->toArray(),
                [
                    'rpc',
                    'ankr',
                    'infura',
                    'blast',
                    'chat',
                    'featured',
                ]
            ),
            ...(config('evm.ankr_key', null) ? ['ankr' => config('evm.ankr_key')] : []),
            ...(config('evm.blastapi_key', null) ? ['blast' => config('evm.blastapi_key')] : []),
            ...(config('evm.infura_key', null) ? ['infura' => config('evm.infura_key')] : []),
            'evm' => collect(config('evm'))->values()->reject(function ($evm) {
                return !is_array($evm) || !isset($evm['chainId']) || !isset($evm['symbol']);
            })->keyBy('chainId'),
            'activeChains' => function () use ($isAdminRoute) {
                if ($isAdminRoute) {
                    return Cache::remember('chainids2', 60, function () {
                        $foundry = json_decode(File::get(base_path('evm/Foundry.json')), true);
                        return collect(array_keys($foundry['addresses']))->map(fn($ch) => (int)$ch)->values()->unique()->all();
                    });
                }
                $chains = Factory::query()->pluck('chainId')->map(fn($ch) => (int)$ch)->values()->unique()->all();
                return [...$chains, 43114]; // always return avalanche mainnet
            },
            'isAdminRoute' => $isAdminRoute,
            'projectId' => config('evm.project_id'),
            'usdRates' =>  function () {
                return Rate::query()->pluck('usd_rate', 'chainId')->all();
            },
        ];
    }
}
