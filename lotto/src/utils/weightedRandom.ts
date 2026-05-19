/**
 * 가중치 기반 로또 번호 생성 유틸리티
 */

export interface FrequencyMap {
  [num: string]: number
}

export interface DrawData {
  round: number
  date: string
  numbers: number[]
  bonus: number
}

/** 구간 정보 */
export interface RangeStat {
  start: number   // 구간 시작 번호
  end: number     // 구간 끝 번호
  label: string   // 표시용 라벨
  min: number     // 최근 1년 최소 출현 개수
  max: number     // 최근 1년 최대 출현 개수
  avg: number     // 평균 출현 개수
}

/** 5개 구간 정의 */
const RANGES: [number, number][] = [
  [1, 10],
  [11, 20],
  [21, 30],
  [31, 40],
  [41, 45],
]

/**
 * 최근 1년 당첨 데이터에서 구간별 최소/최대 출현 개수 계산
 */
export function calcRangeStats(draws: DrawData[]): RangeStat[] {
  return RANGES.map(([start, end]) => {
    const counts = draws.map(
      d => d.numbers.filter(n => n >= start && n <= end).length
    )
    const min = Math.min(...counts)
    const max = Math.max(...counts)
    const avg = counts.reduce((a, b) => a + b, 0) / counts.length
    return { start, end, label: `${start}~${end}`, min, max, avg }
  })
}

/**
 * 구간 제약에 맞게 각 구간에서 뽑을 개수 배분
 * - 각 구간: min 이상 max 이하
 * - 합계: 6개
 */
function allocateRanges(stats: RangeStat[]): number[] {
  const alloc = stats.map(r => r.min)
  let remaining = 6 - alloc.reduce((a, b) => a + b, 0)

  // remaining < 0 이면 (min 합이 6 초과) → 비례 축소
  if (remaining < 0) {
    const total = alloc.reduce((a, b) => a + b, 0)
    return alloc.map(v => Math.round(v * 6 / total))
  }

  // remaining 개수를 max 여유가 있는 구간에 무작위 분배
  let safety = 100
  while (remaining > 0 && safety-- > 0) {
    const eligible = stats
      .map((r, i) => ({ i, room: r.max - alloc[i] }))
      .filter(({ room }) => room > 0)

    if (eligible.length === 0) break

    // 여유(room)에 비례한 가중 선택
    const totalRoom = eligible.reduce((s, e) => s + e.room, 0)
    let rand = Math.random() * totalRoom
    for (const { i, room } of eligible) {
      rand -= room
      if (rand <= 0) { alloc[i]++; break }
    }
    remaining--
  }

  return alloc
}

/**
 * 번호별 가중치 계산
 * - 빈도수에 기반하되, 한 번도 안 나온 번호도 최소 가중치 1 부여
 */
export function buildWeights(frequency: FrequencyMap): number[] {
  return Array.from({ length: 45 }, (_, i) => {
    const count = frequency[String(i + 1)] ?? 0
    return count + 1
  })
}

/**
 * 가중치 배열에서 하나의 번호를 뽑기
 */
function pickWeighted(pool: number[], weights: number[]): number {
  const totalWeight = pool.reduce((sum, num) => sum + weights[num - 1], 0)
  let rand = Math.random() * totalWeight
  for (const num of pool) {
    rand -= weights[num - 1]
    if (rand <= 0) return num
  }
  return pool[pool.length - 1]
}

/**
 * 구간 제약 + 가중치 기반으로 6개 번호 생성
 * - 각 구간의 최소/최대 출현 범위를 만족
 * - 구간 내에서는 빈도 가중치로 선택
 */
export function generateWeightedNumbers(
  frequency: FrequencyMap,
  rangeStats?: RangeStat[]
): number[] {
  const weights = buildWeights(frequency)
  const selected: number[] = []

  if (!rangeStats || rangeStats.length === 0) {
    // 구간 제약 없이 기존 방식
    const pool = Array.from({ length: 45 }, (_, i) => i + 1)
    for (let i = 0; i < 6; i++) {
      const remaining = pool.filter(n => !selected.includes(n))
      selected.push(pickWeighted(remaining, weights))
    }
    return selected.sort((a, b) => a - b)
  }

  // 구간별 배분 결정
  const alloc = allocateRanges(rangeStats)

  // 각 구간에서 배분된 개수만큼 뽑기
  for (let ri = 0; ri < rangeStats.length; ri++) {
    const { start, end } = rangeStats[ri]
    const count = alloc[ri]
    for (let j = 0; j < count; j++) {
      const pool = Array.from(
        { length: end - start + 1 },
        (_, k) => start + k
      ).filter(n => !selected.includes(n))
      if (pool.length === 0) break
      selected.push(pickWeighted(pool, weights))
    }
  }

  return selected.sort((a, b) => a - b)
}

/**
 * 번호의 색상 클래스 반환 (실제 로또 색상 기준)
 * 1~10: 노랑, 11~20: 파랑, 21~30: 빨강, 31~40: 회색, 41~45: 초록
 */
export function getBallColor(num: number): string {
  if (num <= 10) return 'ball-yellow'
  if (num <= 20) return 'ball-blue'
  if (num <= 30) return 'ball-red'
  if (num <= 40) return 'ball-gray'
  return 'ball-green'
}
