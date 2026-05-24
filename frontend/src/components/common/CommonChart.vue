<script setup lang="ts">
import VChart from 'vue-echarts'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { BarChart, LineChart, PieChart, ScatterChart } from 'echarts/charts'
import {
  GridComponent,
  TooltipComponent,
  LegendComponent,
  TitleComponent,
  DataZoomComponent,
  ToolboxComponent,
} from 'echarts/components'
import type { EChartsOption } from 'echarts'

use([
  CanvasRenderer,
  BarChart, LineChart, PieChart, ScatterChart,
  GridComponent, TooltipComponent, LegendComponent,
  TitleComponent, DataZoomComponent, ToolboxComponent,
])

defineProps<{
  option: EChartsOption
  height?: string
}>()
</script>

<template>
  <v-chart :option="option" :style="{ height: height ?? '300px', width: '100%' }" autoresize />
</template>
