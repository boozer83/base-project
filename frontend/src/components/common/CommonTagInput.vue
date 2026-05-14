<script setup lang="ts">
import { ref, nextTick } from 'vue'
import { Plus } from '@element-plus/icons-vue'

const props = defineProps<{
  placeholder?: string
  maxTags?: number
}>()

const model = defineModel<string[]>({ default: () => [] })

const inputVisible = ref(false)
const inputValue = ref('')
const inputRef = ref<HTMLInputElement | null>(null)

async function showInput() {
  if (props.maxTags && model.value.length >= props.maxTags) return
  inputVisible.value = true
  await nextTick()
  inputRef.value?.focus()
}

function confirm() {
  const tag = inputValue.value.trim()
  if (tag && !model.value.includes(tag)) {
    model.value = [...model.value, tag]
  }
  inputValue.value = ''
  inputVisible.value = false
}

function remove(tag: string) {
  model.value = model.value.filter((t) => t !== tag)
}
</script>

<template>
  <div class="tag-input">
    <el-tag
      v-for="tag in model"
      :key="tag"
      closable
      :disable-transitions="false"
      @close="remove(tag)"
    >
      {{ tag }}
    </el-tag>

    <el-input
      v-if="inputVisible"
      ref="inputRef"
      v-model="inputValue"
      size="small"
      style="width: 100px"
      @keyup.enter="confirm"
      @blur="confirm"
    />
    <el-button
      v-else-if="!maxTags || model.length < maxTags"
      size="small"
      :icon="Plus"
      @click="showInput"
    >
      {{ placeholder ?? '태그 추가' }}
    </el-button>
  </div>
</template>

<style scoped>
.tag-input {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  border: 1px dashed #dcdfe6;
  border-radius: 6px;
  min-height: 48px;
}
</style>
