<script setup lang="ts">
import { useAuthStore } from '@/stores/useAuthStore'
import { useRouter } from 'vue-router'

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

    <el-menu
      mode="horizontal"
      :ellipsis="false"
      class="header-nav"
      router
    >
      <el-sub-menu index="community">
        <template #title>커뮤니티</template>
        <el-menu-item index="/community/notice">공지사항</el-menu-item>
      </el-sub-menu>
    </el-menu>

    <div class="header-auth">
      <template v-if="authStore.isLoggedIn">
        <el-avatar
          v-if="authStore.user?.picture"
          :src="authStore.user.picture"
          :size="32"
        />
        <span class="user-name">{{ authStore.user?.name }}</span>
        <el-button size="small" @click="handleLogout">로그아웃</el-button>
      </template>
      <template v-else>
        <el-button type="primary" size="small" @click="authStore.loginWithGoogle">
          <el-icon><Connection /></el-icon>
          Google 로그인
        </el-button>
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

.header-logo {
  flex-shrink: 0;
}

.logo-link {
  font-size: 20px;
  font-weight: 700;
  color: #409eff;
  text-decoration: none;
}

.header-nav {
  flex: 1;
  border-bottom: none;
}

.header-auth {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-shrink: 0;
}

.user-name {
  font-size: 14px;
  color: #303133;
}
</style>
