<script setup lang="ts">
import { useAuthStore } from '@/stores/useAuthStore'
import { useRouter } from 'vue-router'
import { Connection } from '@element-plus/icons-vue'
import { CommonMenu, CommonSubMenu, CommonMenuItem, CommonButton, CommonAvatar, CommonIcon } from '@/components/common'

const authStore = useAuthStore()
const router = useRouter()

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
      <CommonSubMenu index="community">
        <template #title>커뮤니티</template>
        <CommonMenuItem index="/community/notice">공지사항</CommonMenuItem>
      </CommonSubMenu>
      <CommonMenuItem index="/sample">샘플</CommonMenuItem>
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
