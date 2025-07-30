import { provide, inject, ref, onMounted, onUnmounted, watch } from 'vue';

import useEmblaCarousel from 'embla-carousel-vue';

const CarouselContext = Symbol('CarouselContext');

export function useCarouselProvider(options, plugins) {
    const [carouselRef, api] = useEmblaCarousel(options, plugins);
    const canScrollPrev = ref(false);
    const canScrollNext = ref(false);

    function onSelect(api) {
        if (!api) return;
        canScrollPrev.value = api.canScrollPrev();
        canScrollNext.value = api.canScrollNext();
    }

    function scrollPrev() {
        api.value?.scrollPrev();
    }

    function scrollNext() {
        api.value?.scrollNext();
    }

    onMounted(() => {
        if (!api.value) return;
        onSelect(api.value);
        api.value.on('reInit', onSelect);
        api.value.on('select', onSelect);
    });

    onUnmounted(() => {
        api.value?.off('select', onSelect);
    });

    const contextValue = {
        carouselRef,
        api,
        scrollPrev,
        scrollNext,
        canScrollPrev,
        canScrollNext,
        orientation: options.value.axis === 'y' ? 'vertical' : 'horizontal',
    };

    provide(CarouselContext, contextValue);

    return contextValue;
}

export function useCarousel() {
    const context = inject(CarouselContext);
    if (!context) {
        throw new Error('useCarousel must be used within a <Carousel />');
    }
    return context;
} 