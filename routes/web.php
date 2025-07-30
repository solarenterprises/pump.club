<?php

use App\Http\Controllers\AdvancedController;
use App\Http\Controllers\LaunchpadsController;
use App\Http\Controllers\MsgsController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\S3Controller;
use App\Http\Controllers\TradesController;
use Illuminate\Foundation\Application;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;


Route::get('/dashboard', function () {
    return Inertia::render('Dashboard');
})->middleware(['auth', 'verified'])->name('dashboard');


Route::get('/terms', fn() => Inertia::render('Terms'))->name('terms');
Route::get('/privacy', fn() => Inertia::render('Privacy'))->name('privacy');


Route::controller(S3Controller::class)
->group(function () {
    Route::post('sign/{disk?}/{folder?}', 'sign')->name('s3.sign');
});


Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'view'])->name('profile.view');
});

#advanced
Route::name('advanced.')->controller(AdvancedController::class)->group(function () {
    Route::get('/advanced', 'advanced')->name('advanced');
    Route::get('/advanced/search', 'search')->name('search');
    Route::get('/advanced/coin/{contract}', 'advancedTradingView')
    ->where('contract', '0x[a-fA-F0-9]{40}')
    ->name('advancedTradingView');
});

require __DIR__ . '/otp.php';
require __DIR__ . '/web3.php';

#launchpads
Route::name('launchpads.')->controller(LaunchpadsController::class)->group(function () {
    Route::get('/{type?}', 'index')->whereIn('type', ['trending', 'top', 'featured', 'rising', 'new', 'finalized', 'mine'])->name('index');
    Route::get('/launch', 'create')->name('create');
    Route::post('/launchpads/store', 'store')->name('store');
    Route::post('/launchpads/status/{launchpad}', 'updateStatus')->name('update.status');
    Route::post('/launchpads/livestream/{launchpad}', 'updateLiveStream')->name('update.livestream');
    Route::put('/launchpads/finalize/{launchpad}', 'finalize')->name('finalize');
    Route::get('/{launchpad:contract}', 'show')
        ->where('launchpad', '0x[a-fA-F0-9]{40}')
        ->name('show');
    Route::put('/launchpads/{launchpad}', 'update')->name('update');
});
#launchpads

#msgs
Route::name('msgs.')->controller(MsgsController::class)->group(function () {
    Route::get('/msgs', 'index')->name('index');
    Route::get('/msgs/create', 'create')->name('create');
    Route::post('/msgs/store', 'store')->name('store');
    Route::get('/msgs/{msg}/show', 'show')->name('show');
    Route::get('/msgs/{msg}/edit', 'edit')->name('edit');
    Route::put('/msgs/{msg}', 'update')->name('update');
    Route::put('/msgs/toggle/{msg}', 'toggle')->name('toggle');
    Route::delete('/msgs/{msg}', 'destroy')->name('destroy');
});
#msgs


#trades
Route::name('trades.')->controller(TradesController::class)->group(function () {
    Route::post('/trades/store', 'store')->name('store');
    Route::get('/api/launchpad/{launchpad:contract}/candles', 'getCandles')->name('candles');
});
#trades
