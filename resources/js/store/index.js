import { createStore } from 'vuex';

export default createStore({
  state: {
    searchModal: false,
  },
  mutations: {
    openSearchModal(state) {
      state.searchModal = true;
    },
    closeSearchModal(state) {
      state.searchModal = false;
    },
  },
  actions: {
    openSearchModal({ commit }) {
      commit('openSearchModal');
    },
    closeSearchModal({ commit }) {
      commit('closeSearchModal');
    },
  },
}); 