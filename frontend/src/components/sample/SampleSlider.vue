<script setup lang="ts">
import { ref } from 'vue'
import { CommonSlider, CommonRate, CommonProgress, CommonButton } from '@/components/common'

const sliderValue   = ref(40)
const rateValue     = ref(3)
const progressValue = ref(65)
</script>

<template>
  <div class="row">
    <div class="col wide">
      <p class="label">슬라이더 — {{ sliderValue }}%</p>
      <CommonSlider v-model="sliderValue" style="width: 300px" />
    </div>
    <div class="col">
      <p class="label">평점 (Rate)</p>
      <CommonRate v-model="rateValue" :texts="['최악', '나쁨', '보통', '좋음', '최고']" show-text />
    </div>
    <div class="col wide">
      <p class="label">진행률 — {{ progressValue }}%</p>
      <div class="progress-row">
        <CommonProgress :percentage="progressValue" style="flex: 1" />
        <CommonButton size="small" @click="progressValue = Math.min(100, progressValue + 10)">+10</CommonButton>
        <CommonButton size="small" @click="progressValue = Math.max(0,   progressValue - 10)">-10</CommonButton>
      </div>
      <CommonProgress type="circle" :percentage="progressValue" :width="80" style="margin-top: 12px" />
    </div>
  </div>
</template>

<style scoped>
.row { display: flex; align-items: flex-start; gap: 32px; flex-wrap: wrap; }
.col { display: flex; flex-direction: column; gap: 8px; }
.col.wide { min-width: 340px; }
.label { font-size: 13px; color: #606266; margin: 0; font-weight: 500; }
.progress-row { display: flex; align-items: center; gap: 12px; }
</style>
