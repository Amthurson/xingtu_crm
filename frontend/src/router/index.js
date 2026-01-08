import { createRouter, createWebHistory } from 'vue-router'
import InfluencerList from '../views/InfluencerList.vue'

const routes = [
  {
    path: '/',
    redirect: '/influencers'
  },
  {
    path: '/influencers',
    name: 'InfluencerList',
    component: InfluencerList
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router


