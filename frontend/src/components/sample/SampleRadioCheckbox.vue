<script setup lang="ts">
import { ref } from 'vue'
import { CommonRadioGroup, CommonCheckboxGroup, CommonSwitch } from '@/components/common'

const radioOptions = [
  { value: 'option1', label: '옵션 1' },
  { value: 'option2', label: '옵션 2' },
  { value: 'option3', label: '옵션 3' },
]
const checkboxOptions = [
  { value: 'a', label: '항목 A' }, { value: 'b', label: '항목 B' },
  { value: 'c', label: '항목 C' }, { value: 'd', label: '항목 D' },
]

const radioValue    = ref('option1')
const checkboxGroup = ref<(string | number)[]>(['a', 'c'])
const switchValue   = ref(true)
</script>

<template>
  <div class="row">
    <div class="col">
      <p class="label">라디오</p>
      <CommonRadioGroup v-model="radioValue" :options="radioOptions" />
    </div>
    <div class="col">
      <p class="label">라디오 버튼</p>
      <CommonRadioGroup v-model="radioValue" :options="radioOptions" button-style />
    </div>
    <div class="col">
      <p class="label">체크박스</p>
      <CommonCheckboxGroup v-model="checkboxGroup" :options="checkboxOptions" />
    </div>
    <div class="col">
      <p class="label">스위치</p>
      <CommonSwitch v-model="switchValue" active-text="켜짐" inactive-text="꺼짐" />
    </div>
  </div>
</template>

<style scoped>
.row { display: flex; align-items: flex-start; gap: 32px; flex-wrap: wrap; }
.col { display: flex; flex-direction: column; gap: 8px; }
.label { font-size: 13px; color: #606266; margin: 0; font-weight: 500; }
</style>
