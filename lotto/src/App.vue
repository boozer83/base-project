<template>
  <div id="app">
    <!-- 배경 파티클 -->
    <div class="bg-particles">
      <span v-for="i in 20" :key="i" class="particle" :style="particleStyle(i)" />
    </div>
    <LottoGenerator />
  </div>
</template>

<script setup lang="ts">
import LottoGenerator from './components/LottoGenerator.vue'

function particleStyle(i: number) {
  const size = Math.random() * 4 + 1
  return {
    width: `${size}px`,
    height: `${size}px`,
    left: `${(i * 5.3) % 100}%`,
    animationDelay: `${(i * 0.7) % 8}s`,
    animationDuration: `${6 + (i % 5)}s`,
  }
}
</script>

<style>
@import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700;900&display=swap');

* { box-sizing: border-box; margin: 0; padding: 0; }

body {
  font-family: 'Noto Sans KR', sans-serif;
  background: #0a0a1a;
  min-height: 100vh;
  overflow-x: hidden;
}

#app {
  position: relative;
  min-height: 100vh;
}

/* 배경 파티클 */
.bg-particles {
  position: fixed;
  inset: 0;
  pointer-events: none;
  z-index: 0;
  background: radial-gradient(ellipse at 20% 50%, #1a0533 0%, transparent 50%),
              radial-gradient(ellipse at 80% 20%, #0d1f3c 0%, transparent 50%),
              radial-gradient(ellipse at 50% 80%, #1a0a00 0%, transparent 50%),
              #0a0a1a;
}

.particle {
  position: absolute;
  border-radius: 50%;
  background: rgba(212, 175, 55, 0.6);
  animation: float linear infinite;
  bottom: -10px;
}

@keyframes float {
  0%   { transform: translateY(0) scale(1); opacity: 0; }
  10%  { opacity: 1; }
  90%  { opacity: 0.5; }
  100% { transform: translateY(-100vh) scale(0.3); opacity: 0; }
}
</style>
