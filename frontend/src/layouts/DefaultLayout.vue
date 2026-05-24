<script setup lang="ts">
import { onMounted } from 'vue'
import { useAuthStore } from '@/stores/useAuthStore'
import { useMenuStore } from '@/stores/useMenuStore'
import AppHeader from '@/components/AppHeader.vue'
import { CommonContainer, CommonHeader, CommonMain, CommonFooter } from '@/components/common'

const authStore = useAuthStore()
const menuStore = useMenuStore()

onMounted(() => {
  authStore.fetchUser()
  menuStore.fetchMenus()
})
</script>

<template>
  <CommonContainer class="layout">
    <CommonHeader class="layout-header">
      <AppHeader />
    </CommonHeader>
    <CommonMain class="layout-main">
      <router-view />
    </CommonMain>
    <CommonFooter class="layout-footer">
      <span>© 2026 커뮤니티. All rights reserved.</span>
    </CommonFooter>
  </CommonContainer>
</template>

<style scoped>
.layout {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}
.layout-header {
  padding: 0;
  height: auto;
  background-color: #fff;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.1);
  position: sticky;
  top: 0;
  z-index: 100;
}
.layout-main {
  flex: 1;
  max-width: 1200px;
  margin: 0 auto;
  width: 100%;
  padding: 24px 20px;
}
.layout-footer {
  text-align: center;
  color: #909399;
  font-size: 14px;
  background-color: #f5f7fa;
  border-top: 1px solid #e4e7ed;
}
</style>
