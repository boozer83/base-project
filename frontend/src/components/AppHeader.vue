<script setup lang="ts">
import { watch } from 'vue'
import { useAuthStore } from '@/stores/useAuthStore'
import { useMenuStore } from '@/stores/useMenuStore'
import { useRouter } from 'vue-router'
import { Connection } from '@element-plus/icons-vue'
import { CommonMenu, CommonSubMenu, CommonMenuItem, CommonButton, CommonAvatar, CommonIcon } from '@/components/common'

const authStore = useAuthStore()
const menuStore = useMenuStore()
const router = useRouter()

watch(() => authStore.isLoggedIn, () => {
  menuStore.fetchMenus()
})

async function handleLogout() {
  await authStore.logout()
  router.push('/')
}
</script>

<template>
  <div class="header-inner">
    <div class="header-logo">
      <router-link to="/" class="logo-link">커뮤니티</router-link>
    </div>

    <CommonMenu mode="horizontal" :ellipsis="false" class="header-nav" router>
      <template v-for="menu in menuStore.menus" :key="menu.id">
        <CommonSubMenu v-if="menu.children.length > 0" :index="String(menu.id)">
          <template #title>{{ menu.name }}</template>
          <CommonMenuItem
            v-for="child in menu.children"
            :key="child.id"
            :index="child.path || String(child.id)"
          >
            {{ child.name }}
          </CommonMenuItem>
        </CommonSubMenu>
        <CommonMenuItem v-else :index="menu.path || String(menu.id)">
          {{ menu.name }}
        </CommonMenuItem>
      </template>
    </CommonMenu>

    <div class="header-auth">
      <template v-if="authStore.isLoggedIn">
        <CommonAvatar v-if="authStore.user?.picture" :src="authStore.user.picture" :size="32" />
        <span class="user-name">{{ authStore.user?.name }}</span>
        <CommonButton size="small" @click="handleLogout">로그아웃</CommonButton>
      </template>
      <template v-else>
        <CommonButton type="primary" size="small" @click="authStore.loginWithGoogle">
          <template #icon><CommonIcon><Connection /></CommonIcon></template>
          Google 로그인
        </CommonButton>
      </template>
    </div>
  </div>
</template>

<style scoped>
.header-inner {
  display: flex;
  align-items: center;
  padding: 0 24px;
  height: 60px;
  gap: 16px;
}
.header-logo { flex-shrink: 0; }
.logo-link { font-size: 20px; font-weight: 700; color: #409eff; text-decoration: none; }
.header-nav { flex: 1; border-bottom: none; }
.header-auth { display: flex; align-items: center; gap: 8px; flex-shrink: 0; }
.user-name { font-size: 14px; color: #303133; }
</style>
