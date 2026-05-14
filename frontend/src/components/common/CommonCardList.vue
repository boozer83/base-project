<script setup lang="ts">
const props = defineProps<{
  items: Record<string, unknown>[]
  minCardWidth?: number
  gap?: number
}>()
</script>

<template>
  <div
    class="card-grid"
    :style="{
      gridTemplateColumns: `repeat(auto-fill, minmax(${minCardWidth ?? 300}px, 1fr))`,
      gap: `${gap ?? 16}px`,
    }"
  >
    <el-card
      v-for="item in items"
      :key="(item.id as string | number)"
      shadow="hover"
      class="card-item"
    >
      <slot :item="item" />
    </el-card>
  </div>
</template>

<style scoped>
.card-grid { display: grid; }
.card-item { transition: transform 0.2s; }
.card-item:hover { transform: translateY(-2px); }
</style>
