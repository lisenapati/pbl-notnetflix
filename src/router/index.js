import { createRouter, createWebHashHistory } from 'vue-router';
import HomeView from '@/views/HomeView.vue';
import DownloadView from '@/views/DownloadView.vue';

const routes = [
  {
    path: '/',
    name: 'Home',
    component: HomeView,
  },
  {
    path: '/download',
    name: 'Download',
    component: DownloadView,
  },
];

const router = createRouter({
  history: createWebHashHistory(),
  routes,
});

export default router;
