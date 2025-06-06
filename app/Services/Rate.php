<?php

namespace App\Services;

use App\Models\Rate as ModelsRate;
use Cache;
use Exception;
use Illuminate\Support\Facades\Http;

class Rate
{

    /**
     * call the coincap api
     */

     public static function api($path)
     {
 
        $token = env('COINCAP_APIKEY');
        $response = Http::withToken($token)->get("https://rest.coincap.io/v3/$path/?apiKey=$token");
        if (!$response->successful()) {
            throw new \Exception("Failed to fetch api for $path");
        }
        return $response->json('data', []);
     } 

    /**
     * cache the coincap symbols for easy retriviels
     */
    public static function  symbols()
    {
        return Cache::remember('--rates--symbols--', 60 * 60, function () {
            $assets =  [];
            foreach (static::api('assets') as $asset) {
                $assets[$asset['symbol']] = floatval($asset['priceUsd']);
            }
            foreach (static::api('rates') as $asset) {
                $assets[$asset['symbol']] = floatval($asset['rateUsd']);
            }
            return $assets;
        });
    }

    /**
     * update the rates table for the chain currencies
     */
    public static function update()
    {
        $siteCurrency = 'USD';
        $assets = collect(static::api('assets'))->flatMap(function ($asset) {
            return [$asset['symbol'] => floatval($asset['priceUsd'])];
        });
        $rates = collect(static::api('rates'))->flatMap(function ($asset) {
            return [$asset['symbol'] => floatval($asset['rateUsd'])];
        });
        ModelsRate::pluck('symbol')
            ->unique()
            ->each(function ($symbol) use ($assets, $rates, $siteCurrency) {
                $rate = $assets[$symbol] ?? $rates[$symbol] ?? null;
                if (!$rate) return;
                if ($siteCurrency != 'USD') {
                    $conversionRate = $rates[$siteCurrency];
                    if (!$conversionRate) return;
                    $rate *= $conversionRate;
                }
                ModelsRate::where('symbol', $symbol)->update(['usd_rate' => $rate]);
            });
    }
}
