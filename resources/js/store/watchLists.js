import useLocalStorage from '@/hooks/useLocalStorage';

const watchLists = useLocalStorage('watchLists', []);

export default watchLists; 