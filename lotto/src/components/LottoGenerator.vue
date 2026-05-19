<template>
  <div class="lotto-wrap">

    <!-- 로딩 -->
    <div v-if="status === 'loading'" class="loading-overlay">
      <div class="loading-box">
        <div class="loader-ring" />
        <p>최신 당첨번호 확인 중...</p>
      </div>
    </div>

    <!-- 헤더 -->
    <div class="lotto-header">
      <div class="crown">👑</div>
      <h1>LOTTO <span class="gold">AI</span></h1>
      <p class="subtitle">최근 1년 빅데이터 기반 AI 번호 추천</p>
      <div class="meta-row">
        <span class="meta-badge">
          📊 {{ dataInfo.startRound }}회 ~ {{ dataInfo.latestRound }}회
        </span>
        <span class="meta-badge" v-if="justUpdated">
          ✨ {{ newRoundsCount }}회차 업데이트
        </span>
        <span class="meta-badge">🗓 {{ formattedDate }}</span>
      </div>
    </div>

    <!-- 컨트롤 패널 -->
    <div class="control-panel glass-card">
      <div class="control-inner">
        <div class="game-count-wrap">
          <label class="control-label">게임 수</label>
          <div class="count-controls">
            <button class="count-btn" @click="gameCount = Math.max(1, gameCount - 1)">−</button>
            <span class="count-display">{{ gameCount }}</span>
            <button class="count-btn" @click="gameCount = Math.min(10, gameCount + 1)">+</button>
          </div>
        </div>

        <button
          class="generate-btn"
          :class="{ loading: generating }"
          :disabled="status !== 'ready' || generating"
          @click="generate"
        >
          <span v-if="!generating">🎲 번호 생성</span>
          <span v-else class="btn-loading">생성 중...</span>
        </button>

        <button v-if="results.length" class="reset-btn" @click="reset">
          ↺ 초기화
        </button>
      </div>
    </div>

    <!-- 생성된 번호 -->
    <transition-group name="card-slide" tag="div" class="results-area">
      <div v-for="(result, idx) in results" :key="idx" class="game-card glass-card">
        <div class="game-badge">
          <span class="game-num">{{ idx + 1 }}</span>
          <span class="game-text">GAME</span>
        </div>
        <div class="balls">
          <div
            v-for="num in result"
            :key="num"
            class="ball"
            :class="getBallColor(num)"
          >
            <span class="ball-inner">{{ num }}</span>
          </div>
        </div>
        <div class="game-stars">
          <span v-for="s in 5" :key="s">⭐</span>
        </div>
      </div>
    </transition-group>

    <!-- 구분선 -->
    <div v-if="results.length" class="gold-divider">
      <span class="divider-line" />
      <span class="divider-icon">✦</span>
      <span class="divider-line" />
    </div>

    <!-- 구간 분포 제약 -->
    <div class="range-section glass-card" v-if="status === 'ready'">
      <h2 class="section-title">🎯 <span class="gold">구간별 출현 제약</span></h2>
      <p class="section-desc">최근 1년 당첨번호 기준 — 생성 시 각 구간에서 이 범위 내 개수만 출현</p>
      <div class="range-list">
        <div v-for="r in rangeStats" :key="r.label" class="range-item">
          <div class="range-nums">
            <div class="range-balls">
              <div class="ball mini" :class="getBallColor(r.start)">
                <span class="ball-inner">{{ r.start }}</span>
              </div>
              <span class="range-sep">~</span>
              <div class="ball mini" :class="getBallColor(r.end)">
                <span class="ball-inner">{{ r.end }}</span>
              </div>
            </div>
          </div>
          <div class="range-bar-wrap">
            <div class="range-track">
              <div
                class="range-fill"
                :class="getBallColor(r.start)"
                :style="{
                  left: (r.min / 6 * 100) + '%',
                  width: ((r.max - r.min) / 6 * 100) + '%',
                }"
              />
              <div class="range-avg-mark" :style="{ left: (r.avg / 6 * 100) + '%' }" />
            </div>
            <div class="range-labels">
              <span>0</span><span>1</span><span>2</span><span>3</span><span>4</span><span>5</span><span>6</span>
            </div>
          </div>
          <div class="range-stat-text">
            <span class="range-min-max">{{ r.min }}~{{ r.max }}개</span>
            <span class="range-avg">avg {{ r.avg.toFixed(1) }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 통계 섹션 -->
    <div class="stats-section glass-card" v-if="status === 'ready'">
      <h2 class="section-title">📊 <span class="gold">빈도 분석</span></h2>
      <p class="section-desc">최근 1년 출현 횟수 — 높을수록 가중치 ↑</p>
      <div class="freq-chart">
        <div v-for="i in 45" :key="i" class="freq-item">
          <div class="freq-bar-wrap">
            <div
              class="freq-bar"
              :class="getBallColor(i)"
              :style="{ height: barHeight(i) + 'px' }"
            >
              <span class="freq-count" v-if="barHeight(i) > 20">
                {{ frequency[String(i)] ?? 0 }}
              </span>
            </div>
          </div>
          <div class="freq-num" :class="getBallColor(i)">{{ i }}</div>
        </div>
      </div>
    </div>

    <!-- TOP 10 -->
    <div class="top-section glass-card" v-if="status === 'ready'">
      <h2 class="section-title">🏆 <span class="gold">HOT 번호 TOP 10</span></h2>
      <div class="top-list">
        <div v-for="(item, idx) in top10" :key="item.num" class="top-item">
          <div class="rank-badge" :class="['rank-' + (idx + 1)]">{{ idx + 1 }}</div>
          <div class="ball small" :class="getBallColor(item.num)">
            <span class="ball-inner">{{ item.num }}</span>
          </div>
          <div class="progress-wrap">
            <div class="progress-bar">
              <div
                class="progress-fill"
                :class="getBallColor(item.num)"
                :style="{ width: Math.round(item.count / maxFreq * 100) + '%' }"
              />
            </div>
          </div>
          <span class="top-count">{{ item.count }}<small>회</small></span>
        </div>
      </div>
    </div>

    <!-- 에러 -->
    <div v-if="status === 'error'" class="error-card glass-card">
      ⚠️ {{ errorMsg || '데이터를 불러올 수 없습니다.' }}
    </div>

    <div class="footer">LOTTO AI · 빅데이터 기반 번호 추천</div>

  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { generateWeightedNumbers, getBallColor, calcRangeStats } from '../utils/weightedRandom'
import type { FrequencyMap, DrawData, RangeStat } from '../utils/weightedRandom'

interface LottoData {
  fetchedAt: string
  latestRound: number
  startRound: number
  totalDraws: number
  frequency: FrequencyMap
  draws: DrawData[]
}
interface RefreshResponse {
  updated: boolean
  newRounds: number
  data: LottoData
}

const status = ref<'loading' | 'ready' | 'error'>('loading')
const errorMsg = ref('')
const justUpdated = ref(false)
const newRoundsCount = ref(0)
const lottoData = ref<LottoData | null>(null)
const frequency = ref<FrequencyMap>({})
const rangeStats = ref<RangeStat[]>([])
const dataInfo = ref({ startRound: 0, latestRound: 0, totalDraws: 0 })
const results = ref<number[][]>([])
const gameCount = ref(5)
const generating = ref(false)

onMounted(async () => {
  try {
    const res = await fetch('/api/refresh', { signal: AbortSignal.timeout(5000) })
    if (!res.ok) throw new Error(`서버 오류 (${res.status})`)
    const json: RefreshResponse = await res.json()
    applyData(json.data)
    if (json.updated) { justUpdated.value = true; newRoundsCount.value = json.newRounds }
    status.value = 'ready'
  } catch {
    try {
      const fb = await fetch('/api/lotto-data', { signal: AbortSignal.timeout(3000) })
      if (fb.ok) { applyData(await fb.json()); status.value = 'ready'; return }
    } catch { /* ignore */ }
    try {
      const s = await import('../assets/lotto-data.json')
      applyData(s.default as LottoData)
      status.value = 'ready'
    } catch { errorMsg.value = '데이터를 불러올 수 없습니다.'; status.value = 'error' }
  }
})

function applyData(data: LottoData) {
  lottoData.value = data
  frequency.value = data.frequency
  rangeStats.value = calcRangeStats(data.draws)
  dataInfo.value = { startRound: data.startRound, latestRound: data.latestRound, totalDraws: data.totalDraws }
}

const formattedDate = computed(() =>
  lottoData.value
    ? new Date(lottoData.value.fetchedAt).toLocaleDateString('ko-KR', { year: 'numeric', month: 'short', day: 'numeric' })
    : ''
)
const maxFreq = computed(() => Math.max(...Object.values(frequency.value).map(Number), 1))
const top10 = computed(() =>
  Object.entries(frequency.value)
    .map(([num, count]) => ({ num: parseInt(num), count: Number(count) }))
    .sort((a, b) => b.count - a.count)
    .slice(0, 10)
)

function barHeight(num: number): number {
  return Math.round((Number(frequency.value[String(num)] ?? 0) / maxFreq.value) * 80) + 4
}

async function generate() {
  generating.value = true
  results.value = []
  await new Promise(r => setTimeout(r, 80))
  const generated: number[][] = []
  for (let i = 0; i < gameCount.value; i++) {
    generated.push(generateWeightedNumbers(frequency.value, rangeStats.value))
    await new Promise(r => setTimeout(r, 100))
    results.value = [...generated]
  }
  generating.value = false
}

function reset() { results.value = [] }
</script>

<style scoped>
/* ── 기본 ── */
.lotto-wrap {
  position: relative;
  z-index: 1;
  max-width: 600px;
  margin: 0 auto;
  padding: 32px 16px 80px;
  min-height: 100vh;
}

.glass-card {
  background: rgba(255,255,255,0.04);
  border: 1px solid rgba(212,175,55,0.2);
  border-radius: 20px;
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  box-shadow: 0 8px 32px rgba(0,0,0,0.4), inset 0 1px 0 rgba(255,255,255,0.08);
}

.gold { color: #d4af37; }

/* ── 로딩 ── */
.loading-overlay {
  position: fixed;
  inset: 0;
  background: rgba(10,10,26,0.92);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 100;
  backdrop-filter: blur(10px);
}
.loading-box {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
  color: #d4af37;
  font-size: 0.95rem;
  letter-spacing: 0.05em;
}
.loader-ring {
  width: 52px;
  height: 52px;
  border: 3px solid rgba(212,175,55,0.2);
  border-top-color: #d4af37;
  border-radius: 50%;
  animation: spin 0.9s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }

/* ── 헤더 ── */
.lotto-header {
  text-align: center;
  margin-bottom: 32px;
  padding-top: 12px;
}
.crown { font-size: 2.5rem; margin-bottom: 8px; animation: crown-bob 2s ease-in-out infinite; }
@keyframes crown-bob { 0%,100% { transform: translateY(0); } 50% { transform: translateY(-6px); } }

.lotto-header h1 {
  font-size: 2.8rem;
  font-weight: 900;
  color: #fff;
  letter-spacing: 0.15em;
  text-shadow: 0 0 30px rgba(212,175,55,0.4);
  margin-bottom: 8px;
}
.subtitle {
  color: rgba(255,255,255,0.5);
  font-size: 0.85rem;
  letter-spacing: 0.08em;
  margin-bottom: 16px;
}
.meta-row {
  display: flex;
  justify-content: center;
  flex-wrap: wrap;
  gap: 8px;
}
.meta-badge {
  background: rgba(212,175,55,0.1);
  border: 1px solid rgba(212,175,55,0.3);
  border-radius: 20px;
  padding: 4px 12px;
  font-size: 0.75rem;
  color: #d4af37;
  letter-spacing: 0.03em;
}

/* ── 컨트롤 ── */
.control-panel {
  margin-bottom: 24px;
  padding: 24px;
}
.control-inner {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 16px;
  flex-wrap: wrap;
}
.control-label {
  display: block;
  font-size: 0.72rem;
  color: rgba(255,255,255,0.4);
  letter-spacing: 0.1em;
  text-transform: uppercase;
  margin-bottom: 8px;
  text-align: center;
}
.count-controls {
  display: flex;
  align-items: center;
  gap: 0;
  background: rgba(255,255,255,0.05);
  border: 1px solid rgba(212,175,55,0.25);
  border-radius: 12px;
  overflow: hidden;
}
.count-btn {
  width: 40px;
  height: 40px;
  background: transparent;
  border: none;
  color: #d4af37;
  font-size: 1.3rem;
  cursor: pointer;
  transition: background 0.2s;
}
.count-btn:hover { background: rgba(212,175,55,0.1); }
.count-display {
  width: 44px;
  text-align: center;
  font-size: 1.2rem;
  font-weight: 700;
  color: #fff;
}
.generate-btn {
  height: 52px;
  padding: 0 32px;
  background: linear-gradient(135deg, #b8860b, #d4af37, #ffd700, #d4af37, #b8860b);
  background-size: 200% auto;
  border: none;
  border-radius: 14px;
  font-size: 1rem;
  font-weight: 700;
  color: #1a1000;
  cursor: pointer;
  letter-spacing: 0.05em;
  transition: all 0.3s;
  box-shadow: 0 4px 20px rgba(212,175,55,0.4);
  animation: shimmer 3s linear infinite;
}
.generate-btn:hover:not(:disabled) {
  background-position: right center;
  box-shadow: 0 6px 28px rgba(212,175,55,0.6);
  transform: translateY(-2px);
}
.generate-btn:disabled { opacity: 0.5; cursor: not-allowed; animation: none; }
@keyframes shimmer { to { background-position: 200% center; } }

.reset-btn {
  height: 52px;
  padding: 0 20px;
  background: transparent;
  border: 1px solid rgba(255,255,255,0.15);
  border-radius: 14px;
  font-size: 0.9rem;
  color: rgba(255,255,255,0.5);
  cursor: pointer;
  transition: all 0.2s;
}
.reset-btn:hover { border-color: rgba(255,255,255,0.3); color: #fff; }

/* ── 결과 카드 ── */
.results-area {
  display: flex;
  flex-direction: column;
  gap: 14px;
  margin-bottom: 8px;
}
.game-card {
  padding: 18px 20px;
  display: flex;
  align-items: center;
  gap: 14px;
  position: relative;
  overflow: hidden;
}
.game-card::before {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(135deg, rgba(212,175,55,0.06) 0%, transparent 60%);
  pointer-events: none;
}
.game-badge {
  display: flex;
  flex-direction: column;
  align-items: center;
  min-width: 36px;
}
.game-num {
  font-size: 1.3rem;
  font-weight: 900;
  color: #d4af37;
  line-height: 1;
}
.game-text {
  font-size: 0.55rem;
  color: rgba(212,175,55,0.6);
  letter-spacing: 0.1em;
}
.balls { display: flex; gap: 8px; flex-wrap: wrap; flex: 1; }
.game-stars { font-size: 0.6rem; opacity: 0.4; writing-mode: vertical-rl; }

/* ── 볼 ── */
.ball {
  width: 46px;
  height: 46px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  box-shadow: 0 4px 12px rgba(0,0,0,0.5), inset 0 -3px 6px rgba(0,0,0,0.3);
  cursor: default;
}
.ball::before {
  content: '';
  position: absolute;
  top: 6px;
  left: 10px;
  width: 40%;
  height: 30%;
  background: rgba(255,255,255,0.4);
  border-radius: 50%;
  filter: blur(3px);
}
.ball-inner {
  font-weight: 800;
  font-size: 0.95rem;
  color: #fff;
  text-shadow: 0 1px 3px rgba(0,0,0,0.5);
  position: relative;
  z-index: 1;
}
.ball.small { width: 36px; height: 36px; }
.ball.small .ball-inner { font-size: 0.8rem; }

.ball-yellow { background: radial-gradient(circle at 35% 35%, #ffe082, #f9a825, #e65100); }
.ball-blue   { background: radial-gradient(circle at 35% 35%, #90caf9, #1976d2, #0d47a1); }
.ball-red    { background: radial-gradient(circle at 35% 35%, #ef9a9a, #e53935, #b71c1c); }
.ball-gray   { background: radial-gradient(circle at 35% 35%, #cfd8dc, #607d8b, #37474f); }
.ball-green  { background: radial-gradient(circle at 35% 35%, #a5d6a7, #43a047, #1b5e20); }

/* ── 애니메이션 ── */
.card-slide-enter-active { transition: all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1); }
.card-slide-enter-from   { opacity: 0; transform: translateY(24px) scale(0.95); }

/* ── 구분선 ── */
.gold-divider {
  display: flex;
  align-items: center;
  gap: 12px;
  margin: 28px 0;
}
.divider-line {
  flex: 1;
  height: 1px;
  background: linear-gradient(to right, transparent, rgba(212,175,55,0.4), transparent);
}
.divider-icon { color: #d4af37; font-size: 0.9rem; }

/* ── 섹션 공통 ── */
.section-title {
  font-size: 1.1rem;
  font-weight: 700;
  color: #fff;
  margin-bottom: 6px;
  letter-spacing: 0.03em;
}
.section-desc {
  font-size: 0.78rem;
  color: rgba(255,255,255,0.35);
  margin-bottom: 20px;
  letter-spacing: 0.03em;
}

/* ── 구간 분포 ── */
.range-section {
  padding: 24px;
  margin-bottom: 16px;
}
.range-list { display: flex; flex-direction: column; gap: 14px; }
.range-item {
  display: grid;
  grid-template-columns: 90px 1fr 80px;
  align-items: center;
  gap: 12px;
}
.range-balls { display: flex; align-items: center; gap: 4px; }
.range-sep { color: rgba(255,255,255,0.3); font-size: 0.8rem; }

.ball.mini { width: 28px; height: 28px; }
.ball.mini .ball-inner { font-size: 0.7rem; }

.range-bar-wrap { display: flex; flex-direction: column; gap: 4px; }
.range-track {
  position: relative;
  height: 10px;
  background: rgba(255,255,255,0.07);
  border-radius: 5px;
  overflow: visible;
}
.range-fill {
  position: absolute;
  top: 0;
  height: 100%;
  border-radius: 5px;
  opacity: 0.75;
  min-width: 4px;
}
.range-avg-mark {
  position: absolute;
  top: -3px;
  width: 3px;
  height: 16px;
  background: rgba(212,175,55,0.9);
  border-radius: 2px;
  transform: translateX(-50%);
  box-shadow: 0 0 6px rgba(212,175,55,0.6);
}
.range-labels {
  display: flex;
  justify-content: space-between;
  font-size: 0.65rem;
  color: rgba(255,255,255,0.2);
}
.range-stat-text {
  text-align: right;
  display: flex;
  flex-direction: column;
  gap: 2px;
}
.range-min-max {
  font-size: 0.85rem;
  font-weight: 700;
  color: #d4af37;
}
.range-avg {
  font-size: 0.7rem;
  color: rgba(255,255,255,0.3);
}

/* ── 빈도 차트 ── */
.stats-section {
  padding: 24px;
  margin-bottom: 16px;
}
.freq-chart {
  display: flex;
  align-items: flex-end;
  gap: 3px;
  overflow-x: auto;
  padding-bottom: 4px;
}
.freq-item { display: flex; flex-direction: column; align-items: center; min-width: 11px; flex: 1; }
.freq-bar-wrap { display: flex; align-items: flex-end; height: 90px; width: 100%; }
.freq-bar {
  width: 100%;
  min-width: 9px;
  border-radius: 3px 3px 0 0;
  display: flex;
  align-items: flex-start;
  justify-content: center;
  transition: height 0.6s ease;
  opacity: 0.85;
}
.freq-bar:hover { opacity: 1; transform: scaleY(1.05); transform-origin: bottom; }
.freq-count { font-size: 8px; font-weight: 700; color: rgba(255,255,255,0.9); margin-top: 2px; }
.freq-num {
  font-size: 8px;
  font-weight: 700;
  color: #fff;
  width: 16px; height: 16px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-top: 3px;
  opacity: 0.8;
}

/* ── TOP 10 ── */
.top-section {
  padding: 24px;
  margin-bottom: 16px;
}
.top-list { display: flex; flex-direction: column; gap: 12px; }
.top-item { display: flex; align-items: center; gap: 12px; }
.rank-badge {
  min-width: 28px;
  height: 28px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.8rem;
  font-weight: 800;
  color: rgba(255,255,255,0.5);
  background: rgba(255,255,255,0.06);
  border: 1px solid rgba(255,255,255,0.1);
}
.rank-1 { background: rgba(255,215,0,0.15); border-color: rgba(255,215,0,0.4); color: #ffd700; }
.rank-2 { background: rgba(192,192,192,0.15); border-color: rgba(192,192,192,0.4); color: #c0c0c0; }
.rank-3 { background: rgba(205,127,50,0.15); border-color: rgba(205,127,50,0.4); color: #cd7f32; }

.progress-wrap { flex: 1; }
.progress-bar {
  height: 8px;
  background: rgba(255,255,255,0.07);
  border-radius: 4px;
  overflow: hidden;
}
.progress-fill {
  height: 100%;
  border-radius: 4px;
  transition: width 0.8s ease;
  opacity: 0.85;
}
.top-count {
  min-width: 38px;
  font-size: 1rem;
  font-weight: 700;
  color: #d4af37;
  text-align: right;
}
.top-count small { font-size: 0.7rem; color: rgba(212,175,55,0.6); margin-left: 2px; }

/* ── 에러 ── */
.error-card { padding: 20px; color: #ff6b6b; font-size: 0.9rem; text-align: center; margin-bottom: 16px; }

/* ── 푸터 ── */
.footer {
  text-align: center;
  font-size: 0.72rem;
  color: rgba(255,255,255,0.15);
  letter-spacing: 0.12em;
  padding-top: 20px;
}
</style>
