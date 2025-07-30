import { ref, watch } from 'vue';

export default function useLocalStorage(key, defaultValue) {
    const data = ref(
        (() => {
            try {
                const item = localStorage.getItem(key);
                return item ? JSON.parse(item) : defaultValue;
            } catch {
                return defaultValue;
            }
        })()
    );

    watch(
        data,
        (val) => {
            localStorage.setItem(key, JSON.stringify(val));
        },
        { deep: true }
    );

    return data;
}