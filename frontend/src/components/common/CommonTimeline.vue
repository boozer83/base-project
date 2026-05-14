<script setup lang="ts">
export interface TimelineItem {
  content: string
  timestamp: string
  type?: 'primary' | 'success' | 'warning' | 'danger' | 'info'
  placement?: 'top' | 'bottom'
}

const props = defineProps<{
  items: TimelineItem[]
}>()
</script>

<template>
  <el-timeline>
    <el-timeline-item
      v-for="(item, i) in items"
      :key="i"
      :timestamp="item.timestamp"
      :type="item.type"
      :placement="item.placement ?? 'top'"
    >
      {{ item.content }}
    </el-timeline-item>
  </el-timeline>
</template>
