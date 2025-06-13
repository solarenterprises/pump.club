<!-- eslint-disable new-cap -->

<script setup>
	import { onMounted, onUnmounted } from "vue";

	const props = defineProps({
		launchpad: {
			type: Object,
			required: true,
		},
	});

	let widget = null;

	const configureWidget = () => {
		return new window.TradingView.widget({
			symbol: props.launchpad.symbol,
			interval: "60",
			container: "tv_chart_container",
			library_path: "/charting_library/",
			locale: "en",
			disabled_features: [
				"use_localstorage_for_settings",
				"header_saveload",
				"chart_template_storage",
			],
			// enabled_features: ["study_templates"],
			// charts_storage_url: "https://saveload.tradingview.com",
			// charts_storage_api_version: "1.1",
			client_id: "tradingview.com",
			user_id: "public_user",
			fullscreen: false,
			autosize: true,
			theme: "Dark",
			custom_css_url: "/tradingview.css",
			overrides: {
				"paneProperties.backgroundType": "solid",
				"paneProperties.background": "#262626",
				// Grid lines - using gray-750 (#333333) for subtle contrast
				"paneProperties.vertGridProperties.color": "#333333",
				"paneProperties.horzGridProperties.color": "#333333",
				// Scales - using various gray shades
				"scalesProperties.backgroundColor": "#262626", // gray-800
				"scalesProperties.lineColor": "#333333", // gray-750
				"scalesProperties.textColor": "#8b8b8b", // gray-450
				// Crosshair - using gray-550
				"crossHairProperties.color": "#636363",
				"crossHairProperties.style": 0,
				// Chart style
				"mainSeriesProperties.style": 1,
				"mainSeriesProperties.showPriceLine": true,
				// Volume
				volumePaneSize: "medium",
				"volume.volume.color.0": "#ef4444",
				"volume.volume.color.1": "#22c55e",

				"mainSeriesProperties.candleStyle.upColor": "#26a69a",
				"mainSeriesProperties.candleStyle.downColor": "#ef5350",
				"mainSeriesProperties.candleStyle.borderUpColor": "#26a69a",
				"mainSeriesProperties.candleStyle.borderDownColor": "#ef5350",
				"mainSeriesProperties.candleStyle.wickUpColor": "#26a69a",
				"mainSeriesProperties.candleStyle.wickDownColor": "#ef5350",
			},
			datafeed: {
				onReady: (callback) => {
					setTimeout(() => {
						callback({
							supported_resolutions: [
								"1",
								"5",
								"15",
								"30",
								"60",
								"240",
								"D",
								"W",
							],
							currency_codes: ["USD"],
							supports_marks: false,
							supports_time: true,
							supports_timescale_marks: false,
						});
					}, 0);
				},

				searchSymbols: (userInput, exchange, symbolType, onResult) => {
					onResult([
						{
							symbol: props.launchpad.symbol,
							full_name: props.launchpad.symbol,
							description: props.launchpad.symbol,
							exchange: "DEX",
							type: "crypto",
						},
					]);
				},

				resolveSymbol: (
					symbolName,
					onSymbolResolvedCallback,
					onResolveErrorCallback,
				) => {
					setTimeout(() => {
						onSymbolResolvedCallback({
							name: props.launchpad.symbol,
							full_name: props.launchpad.symbol,
							description: props.launchpad.symbol,
							type: "crypto",
							session: "24x7",
							timezone: "Etc/UTC",
							ticker: props.launchpad.symbol,
							minmov: 1,
							pricescale: 100000000,
							has_intraday: true,
							intraday_multipliers: [
								"1",
								"5",
								"15",
								"30",
								"60",
								"240",
							],
							supported_resolutions: [
								"1",
								"5",
								"15",
								"30",
								"60",
								"240",
								"D",
								"W",
							],
							volume_precision: 8,
							data_status: "streaming",
						});
					}, 0);
				},

				getBars: async (
					symbolInfo,
					resolution,
					periodParams,
					onHistoryCallback,
					onErrorCallback,
				) => {
					try {
						const response = await fetch(
							`/api/launchpad/${props.launchpad.contract}/candles?timeframe=${resolution}&from=${periodParams.from}&to=${periodParams.to}`,
						);

						if (!response.ok) {
							throw new Error("Network response was not ok");
						}

						const data = await response.json();

						if (data.length === 0) {
							onHistoryCallback([], { noData: true });
							return;
						}

						const bars = data.map((bar) => ({
							time: bar.timestamp * 1000,
							open: parseFloat(bar.open),
							high: parseFloat(bar.high),
							low: parseFloat(bar.low),
							close: parseFloat(bar.close),
							volume: parseFloat(bar.volume),
						}));

						onHistoryCallback(bars, { noData: false });
					} catch (err) {
						console.error("Error fetching candles:", err);
						onErrorCallback(err);
					}
				},

				subscribeBars: (
					symbolInfo,
					resolution,
					onRealtimeCallback,
					subscribeUID,
					onResetCacheNeededCallback,
				) => {
					window.Echo.channel(
						`launchpad.${props.launchpad.id}`,
					).listen("NewTradeEvent", (trade) => {
						// Convert trade to OHLC format
						const bar = {
							time: new Date(trade.created_at).getTime(),
							open: parseFloat(trade.amount),
							high: parseFloat(trade.amount),
							low: parseFloat(trade.amount),
							close: parseFloat(trade.amount),
							volume: parseFloat(trade.qty),
						};
						onRealtimeCallback(bar);
					});
				},

				unsubscribeBars: (subscriberUID) => {
					window.Echo.leave(`launchpad.${props.launchpad.id}`);
				},
			},
		});
	};

	onMounted(async () => {
		const scriptPath = "/charting_library/charting_library.js";

		// Load TradingView library if not already loaded
		if (!document.querySelector(`script[src="${scriptPath}"]`)) {
			const script = document.createElement("script");
			script.src = scriptPath;
			script.type = "text/javascript";
			document.head.appendChild(script);

			script.onload = () => {
				widget = configureWidget();
			};
		} else {
			widget = configureWidget();
		}
	});

	onUnmounted(() => {
		if (widget) {
			widget.remove();
			widget = null;
		}
		window.Echo.leave(`launchpad.${props.launchpad.id}`);
	});
</script>
<template>
	<div class="relative">
		<div id="tv_chart_container" class="w-full h-[400px]"></div>
	</div>
</template>
