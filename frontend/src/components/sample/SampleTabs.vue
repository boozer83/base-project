<script setup lang="ts">
import { ref } from 'vue'
import { CommonTabs } from '@/components/common'
import type { TabItem } from '@/components/common'

const activeTab = ref('info')
const tabs: TabItem[] = [
  { name: 'info',     label: '기본 정보' },
  { name: 'settings', label: '상세 설정' },
  { name: 'activity', label: '활동 내역' },
  { name: 'stats',    label: '통계' },
]
</script>

<template>
  <CommonTabs v-model="activeTab" :tabs="tabs" type="border-card">
    <template #info>프로필과 기본 설정을 표시합니다.</template>
    <template #settings>알림, 보안, 연동 서비스를 관리합니다.</template>
    <template #activity>최근 로그인, 게시글, 댓글 이력을 보여줍니다.</template>
    <template #stats>방문 수, 클릭 수, 전환율 등의 지표를 표시합니다.</template>
  </CommonTabs>
</template>
