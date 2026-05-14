<script setup lang="ts">
import { CommonButton, CommonTooltip, CommonPopover } from '@/components/common'
</script>

<template>
  <div class="row">
    <CommonTooltip content="위쪽 툴팁" placement="top">
      <CommonButton>Top 툴팁</CommonButton>
    </CommonTooltip>
    <CommonTooltip content="아래쪽 툴팁" placement="bottom">
      <CommonButton>Bottom 툴팁</CommonButton>
    </CommonTooltip>
    <CommonPopover placement="right" title="팝오버 제목" :width="200" trigger="click" content="팝오버 내용입니다. 클릭하면 나타납니다.">
      <template #reference><CommonButton type="primary">팝오버 (클릭)</CommonButton></template>
    </CommonPopover>
    <CommonPopover placement="top" title="호버 팝오버" :width="200" trigger="hover" content="마우스를 올리면 나타납니다.">
      <template #reference><CommonButton type="success">팝오버 (호버)</CommonButton></template>
    </CommonPopover>
  </div>
</template>

<style scoped>
.row { display: flex; flex-wrap: wrap; gap: 8px; align-items: center; }
</style>
