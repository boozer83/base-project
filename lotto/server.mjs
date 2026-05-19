/**
 * 로또 번호 생성기 - Express API 서버
 *
 * 역할:
 *  1. GET /api/lotto-data   → 현재 저장된 데이터 반환
 *  2. GET /api/refresh      → soledot.com에서 최신 회차 확인 후 신규 회차 있으면 크롤링
 *  3. 프로덕션: dist/ 정적 파일 서빙
 */

import express from 'express'
import { readFileSync, writeFileSync, existsSync } from 'fs'
import { resolve, dirname } from 'path'
import { fileURLToPath } from 'url'

const __dirname = dirname(fileURLToPath(import.meta.url))
const DATA_PATH = resolve(__dirname, 'src/assets/lotto-data.json')
const BASE_URL = 'https://data.soledot.com/lottowinnumber/fo/lottowinnumberlist.sd'
const PORT = 3001

const app = express()
app.use(express.json())

// CORS (Vite dev server → Express)
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*')
  next()
})

// ──────────────────────────────────────────
// 크롤링 로직
// ──────────────────────────────────────────

function parsePage(html) {
  const draws = []
  const tbodyMatch = html.match(/<tbody>([\s\S]*?)<\/tbody>/)
  if (!tbodyMatch) return draws

  const trBlocks = tbodyMatch[1].match(/<tr[\s\S]*?<\/tr>/g) || []
  for (const tr of trBlocks) {
    const roundMatch = tr.match(/lottowinnumberdetailview\.sd">(\d+)<\/a>/)
    if (!roundMatch) continue
    const round = parseInt(roundMatch[1])

    const allNums = [...tr.matchAll(/<strong>(\d+)<\/strong>/g)].map(m => parseInt(m[1]))
    if (allNums.length < 7) continue

    const numbers = allNums.slice(0, 6)
    const bonus = allNums[6]
    const dateMatch = tr.match(/(\d{4}-\d{2}-\d{2})/)
    const date = dateMatch ? dateMatch[1] : ''

    draws.push({ round, date, numbers, bonus })
  }
  return draws
}

async function fetchPage(pageNum) {
  const body = new URLSearchParams({ s_pagenum: String(pageNum) })
  const res = await fetch(BASE_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
      'Referer': BASE_URL,
    },
    body: body.toString(),
  })
  if (!res.ok) throw new Error(`HTTP ${res.status}`)
  return res.text()
}

/** soledot 1페이지에서 최신 회차 번호 확인 */
async function fetchLatestRound() {
  const html = await fetchPage(1)
  const match = html.match(/lottowinnumberdetailview\.sd">(\d+)<\/a>/)
  return match ? parseInt(match[1]) : null
}

/** 현재 저장된 데이터 로드 (없으면 null) */
function loadStoredData() {
  if (!existsSync(DATA_PATH)) return null
  try {
    return JSON.parse(readFileSync(DATA_PATH, 'utf-8'))
  } catch {
    return null
  }
}

/** 최근 52회 전체 크롤링 */
async function crawlAll() {
  const allDraws = []
  const TARGET = 52

  for (let page = 1; allDraws.length < TARGET; page++) {
    const html = await fetchPage(page)
    const draws = parsePage(html)
    if (!draws.length) break

    const needed = TARGET - allDraws.length
    allDraws.push(...draws.slice(0, needed))
    await new Promise(r => setTimeout(r, 300))
  }

  return allDraws
}

/** 신규 회차만 앞에 추가하는 부분 크롤링 */
async function crawlNewRounds(storedLatest) {
  const newDraws = []
  let page = 1

  outer: while (true) {
    const html = await fetchPage(page)
    const draws = parsePage(html)
    if (!draws.length) break

    for (const draw of draws) {
      if (draw.round <= storedLatest) break outer
      newDraws.push(draw)
    }
    page++
    await new Promise(r => setTimeout(r, 300))
  }

  return newDraws
}

/** 데이터 저장 */
function saveData(draws) {
  const frequency = {}
  for (let i = 1; i <= 45; i++) frequency[i] = 0
  for (const draw of draws) {
    for (const num of draw.numbers) frequency[num]++
  }

  const data = {
    fetchedAt: new Date().toISOString(),
    latestRound: draws[0]?.round ?? 0,
    startRound: draws[draws.length - 1]?.round ?? 0,
    totalDraws: draws.length,
    draws,
    frequency,
  }
  writeFileSync(DATA_PATH, JSON.stringify(data, null, 2), 'utf-8')
  return data
}

// ──────────────────────────────────────────
// API 엔드포인트
// ──────────────────────────────────────────

/** GET /api/lotto-data — 저장된 데이터 반환 */
app.get('/api/lotto-data', (req, res) => {
  const data = loadStoredData()
  if (!data) return res.status(404).json({ error: '데이터 없음. /api/refresh 먼저 호출 필요' })
  res.json(data)
})

/** GET /api/refresh — 최신 회차 확인 후 필요 시 크롤링 */
app.get('/api/refresh', async (req, res) => {
  try {
    console.log('[refresh] soledot.com에서 최신 회차 확인 중...')
    const latestRound = await fetchLatestRound()

    if (!latestRound) {
      return res.status(500).json({ error: '최신 회차 확인 실패' })
    }

    const stored = loadStoredData()
    const storedLatest = stored?.latestRound ?? 0

    // 최신 회차와 동일하면 업데이트 불필요
    if (storedLatest >= latestRound) {
      console.log(`[refresh] 이미 최신 상태 (${latestRound}회차)`)
      return res.json({ updated: false, newRounds: 0, data: stored })
    }

    // 신규 회차 수
    const newCount = latestRound - storedLatest
    console.log(`[refresh] 신규 ${newCount}회차 발견 (${storedLatest + 1}~${latestRound}회) — 크롤링 시작`)

    let updatedDraws

    if (!stored || newCount >= 52) {
      // 처음이거나 오래된 경우 전체 재수집
      updatedDraws = await crawlAll()
    } else {
      // 신규 회차만 앞에 추가, 52회 초과분은 뒤에서 제거
      const newDraws = await crawlNewRounds(storedLatest)
      updatedDraws = [...newDraws, ...stored.draws].slice(0, 52)
    }

    const data = saveData(updatedDraws)
    console.log(`[refresh] 완료 — ${data.latestRound}회차 기준 ${data.totalDraws}개 저장`)

    res.json({ updated: true, newRounds: newCount, data })
  } catch (err) {
    console.error('[refresh] 오류:', err.message)
    res.status(500).json({ error: err.message })
  }
})

// ──────────────────────────────────────────
// 프로덕션: 빌드된 Vue 앱 서빙
// ──────────────────────────────────────────
const distPath = resolve(__dirname, 'dist')
if (existsSync(distPath)) {
  app.use(express.static(distPath))
  app.get('*', (req, res) => res.sendFile(resolve(distPath, 'index.html')))
}

app.listen(PORT, () => {
  console.log(`[server] API 서버 실행 중 → http://localhost:${PORT}`)
  console.log(`[server] /api/refresh  — 최신 회차 확인 및 업데이트`)
  console.log(`[server] /api/lotto-data — 저장된 데이터 조회`)
})
