<script setup lang="ts">
import { Star, Bell } from '@element-plus/icons-vue'
import { CommonTimeline, CommonBadge, CommonButton, CommonAvatar, CommonAvatarGroup } from '@/components/common'
import type { TimelineItem } from '@/components/common'

const timelineItems: TimelineItem[] = [
  { content: '프로젝트 킥오프 및 요구사항 정의', timestamp: '2026-05-01', type: 'primary' },
  { content: '백엔드 API 개발 완료',             timestamp: '2026-05-07', type: 'success' },
  { content: '프론트엔드 통합 테스트 진행 중',   timestamp: '2026-05-12', type: 'warning' },
  { content: '배포 예정',                         timestamp: '2026-05-20' },
]
</script>

<template>
  <div class="row">
    <div class="col">
      <p class="label">타임라인</p>
      <CommonTimeline :items="timelineItems" />
    </div>
    <div class="col">
      <p class="label">뱃지 (Badge)</p>
      <div class="badge-row">
        <CommonBadge :value="5"><CommonButton>댓글</CommonButton></CommonBadge>
        <CommonBadge :value="99" :max="50"><CommonButton>알림</CommonButton></CommonBadge>
        <CommonBadge is-dot><CommonButton :icon="Bell">메시지</CommonButton></CommonBadge>
      </div>
      <p class="label" style="margin-top: 20px">아바타 (Avatar)</p>
      <div class="avatar-row">
        <CommonAvatar :size="48" src="https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png" />
        <CommonAvatar :size="48" style="background-color: #409eff">AB</CommonAvatar>
        <CommonAvatar :size="48" :icon="Star" style="background-color: #67c23a" />
        <CommonAvatarGroup>
          <CommonAvatar src="https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png" />
          <CommonAvatar style="background-color: #409eff">B</CommonAvatar>
          <CommonAvatar style="background-color: #e6a23c">C</CommonAvatar>
          <CommonAvatar style="background-color: #f56c6c">+3</CommonAvatar>
        </CommonAvatarGroup>
      </div>
    </div>
  </div>
</template>

<style scoped>
.row { display: flex; align-items: flex-start; gap: 48px; flex-wrap: wrap; }
.col { display: flex; flex-direction: column; gap: 8px; }
.label { font-size: 13px; color: #606266; margin: 0; font-weight: 500; }
.badge-row { display: flex; gap: 16px; align-items: center; }
.avatar-row { display: flex; gap: 12px; align-items: center; flex-wrap: wrap; }
</style>
