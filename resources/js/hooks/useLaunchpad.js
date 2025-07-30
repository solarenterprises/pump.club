import { ref, computed } from "vue";

export function useLaunchpad(launchpad) {
    const launchpadInfo = computed(() => {
        return {
            marketCap: ref('599.3M')
        };
    });

    return { launchpadInfo };
}