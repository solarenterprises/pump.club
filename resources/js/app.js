/* eslint-disable import/order */
import '../css/app.css';
import './bootstrap';

import { createApp, h } from 'vue';

import { useWagmiAdapter } from '@/lib/wagmi.js';
import { createInertiaApp } from '@inertiajs/vue3';
import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query';
import { WagmiPlugin } from '@wagmi/vue';
import { resolvePageComponent } from 'laravel-vite-plugin/inertia-helpers';
import "tippy.js/dist/tippy.css";
import "tippy.js/themes/light.css";
import "v-calendar/dist/style.css";
import { createI18n } from "vue-i18n";
import VueTippy from "vue-tippy";
import { ZiggyVue } from '../../vendor/tightenco/ziggy';
import "../css/vcalendar-theme.css";
import messages from "./vue-i18n-locales.generated.js";
import store from './store';

const appName = import.meta.env.VITE_APP_NAME || 'Laravel';
const queryClient = new QueryClient();
createInertiaApp({
    title: (title) => `${title} - ${appName}`,
    resolve: (name) =>
        resolvePageComponent(
            `./Pages/${name}.vue`,
            import.meta.glob('./Pages/**/*.vue'),
        ),
    setup({ el, App, props, plugin }) {
        const i18n = createI18n({
            locale: props.initialPage.props.locale,
            fallbackLocale: "en", // set fallback locale
            messages, // set locale messages,
            legacy: false,
        });
        const adapter = useWagmiAdapter(props.initialPage.props);
        const app = createApp({ render: () => h(App, props) })
            .use(plugin)
            .use(ZiggyVue)
            .use(WagmiPlugin, { config: adapter.wagmiConfig })
            .use(VueQueryPlugin, { queryClient })
            .use(i18n)
            .use(VueTippy)
            .use(store)
            .mount(el);
        return app;
    },
    progress: {
        color: '#f5f5f3',
    },
});
