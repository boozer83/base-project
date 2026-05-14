<script setup lang="ts">
import { useAuthStore } from '@/stores/useAuthStore'
import { CommonCard, CommonButton } from '@/components/common'

const authStore = useAuthStore()
</script>

<template>
  <div class="home-page">
    <CommonCard class="welcome-card">
      <template #header>
        <h1 class="welcome-title">커뮤니티에 오신 것을 환영합니다</h1>
      </template>
      <p class="welcome-desc">다양한 정보와 소식을 공유하는 공간입니다.</p>
      <div class="quick-links">
        <CommonButton type="primary" @click="$router.push('/community/notice')">
          공지사항 보기
        </CommonButton>
        <CommonButton v-if="!authStore.isLoggedIn" @click="authStore.loginWithGoogle">
          Google로 로그인
        </CommonButton>
      </div>
    </CommonCard>
  </div>
</template>

<style scoped>
.home-page { max-width: 800px; margin: 40px auto; }
.welcome-title { margin: 0; font-size: 24px; }
.welcome-desc { color: #606266; font-size: 16px; margin-bottom: 24px; }
.quick-links { display: flex; gap: 12px; }
</style>
