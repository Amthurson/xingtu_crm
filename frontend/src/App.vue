<template>
  <el-container>
    <el-header>
      <div class="header-content">
        <h1 class="logo">达人老师CRM</h1>
        <el-menu
          mode="horizontal"
          :default-active="activeIndex"
          class="header-menu"
          @select="handleSelect"
        >
          <el-menu-item index="1">首页</el-menu-item>
          <el-menu-item index="2">达人管理</el-menu-item>
          <el-menu-item index="3">数据统计</el-menu-item>
        </el-menu>
      </div>
    </el-header>
    <el-main>
      <router-view />
    </el-main>
  </el-container>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const activeIndex = ref('2')

const handleSelect = (key) => {
  if (key === '2') {
    router.push('/influencers')
  } else if (key === '1') {
    router.push('/')
  }
}
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

#app {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
}

.el-header {
  background-color: #fff;
  border-bottom: 1px solid #e4e7ed;
  padding: 0 20px;
  height: 60px !important;
  display: flex;
  align-items: center;
}

.header-content {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.logo {
  font-size: 24px;
  font-weight: bold;
  color: #FC376F;
  margin-right: 40px;
}

.header-menu {
  flex: 1;
  border-bottom: none;
}

.el-main {
  background-color: #f5f7fa;
  min-height: calc(100vh - 60px);
  padding: 20px;
}
</style>


