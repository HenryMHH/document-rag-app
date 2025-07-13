import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '@/views/HomeView.vue'
import Dashboard from '@/layout/Dashboard.vue'
import UserManagement from '@/views/UserManagement.vue'
import Documentation from '@/views/Documentation.vue'
import LoginPage from '@/views/LoginPage.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'Home',
      component: HomeView,
    },
    {
      path: '/login',
      name: 'Login',
      component: LoginPage,
    },
    {
      path: '/dashboard',
      name: 'Dashboard',
      component: Dashboard,
      children: [
        {
          path: 'user-management',
          name: 'User Management',
          component: UserManagement,
        },
        {
          path: 'documentation',
          name: 'Documentation',
          component: Documentation,
        },
      ],
    },
  ],
})

export default router
