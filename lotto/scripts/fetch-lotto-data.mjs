/**
 * data.soledot.com에서 최근 1년치(52회) 로또 당첨번호를 크롤링하여 JSON으로 저장합니다.
 * 실행: node scripts/fetch-lotto-data.mjs
 */

import { writeFileSync } from 'fs'
import { resolve, dirname } from 'path'
import { fileURLToPath } from 'url'

const __dirname = dirname(fileURLToPath(import.meta.url))
const BASE_URL = 'https://data.soledot.com/lottowinnumber/fo/lottowinnumberlist.sd'
const DELAY_MS = 300

function sleep(ms) {
  return new Promise(r => setTimeout(r, ms))
}

/**
 * HTML에서 로또 회차 데이터 파싱
 */
function parsePage(html) {
  const draws = []

  // tbody 내 tr 블록 추출
  const tbodyMatch = html.match(/<tbody>([\s\S]*?)<\/tbody>/)
  if (!tbodyMatch) return draws

  const trBlocks = tbodyMatch[1].match(/<tr[\s\S]*?<\/tr>/g) || []

  for (const tr of trBlocks) {
    // 회차 번호
    const roundMatch = tr.match(/lottowinnumberdetailview\.sd">(\d+)<\/a>/)
    if (!roundMatch) continue
    const round = parseInt(roundMatch[1])

    // 당첨번호 (circleNumber strong 태그 전체)
    const allNums = [...tr.matchAll(/<strong>(\d+)<\/strong>/g)].map(m => parseInt(m[1]))
    if (allNums.length < 7) continue

    const numbers = allNums.slice(0, 6)
    const bonus = allNums[6]

    // 날짜
    const dateMatch = tr.match(/(\d{4}-\d{2}-\d{2})/)
    const date = dateMatch ? dateMatch[1] : ''

    draws.push({ round, date, numbers, bonus })
  }

  return draws
}

/**
 * 특정 페이지 가져오기
 */
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

async function main() {
  console.log('soledot.com에서 최근 1년(52회) 로또 당첨번호 크롤링 시작...\n')

  const allDraws = []
  const TARGET = 52  // 1년치 회차 수

  let page = 1
  while (allDraws.length < TARGET) {
    process.stdout.write(`  ${page}페이지 수집 중...`)
    const html = await fetchPage(page)
    const draws = parsePage(html)

    if (draws.length === 0) {
      console.log(' (데이터 없음, 종료)')
      break
    }

    // TARGET 개수까지만 수집
    const needed = TARGET - allDraws.length
    allDraws.push(...draws.slice(0, needed))
    console.log(` ${draws.slice(0, needed).length}개 수집 (누적 ${allDraws.length}/${TARGET})`)

    if (allDraws.length >= TARGET) break
    page++
    await sleep(DELAY_MS)
  }

  console.log(`\n총 ${allDraws.length}회차 수집 완료!`)

  // 번호별 출현 빈도 계산 (1~45)
  const frequency = {}
  for (let i = 1; i <= 45; i++) frequency[i] = 0
  for (const draw of allDraws) {
    for (const num of draw.numbers) {
      frequency[num]++
    }
  }

  const latestRound = allDraws[0]?.round ?? 0
  const startRound = allDraws[allDraws.length - 1]?.round ?? 0

  const result = {
    fetchedAt: new Date().toISOString(),
    latestRound,
    startRound,
    totalDraws: allDraws.length,
    draws: allDraws,
    frequency,
  }

  const outputPath = resolve(__dirname, '../src/assets/lotto-data.json')
  writeFileSync(outputPath, JSON.stringify(result, null, 2), 'utf-8')
  console.log(`\n저장 완료: ${outputPath}`)

  // TOP 10 출력
  const sorted = Object.entries(frequency)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 10)
  console.log('\n최근 1년 출현 빈도 TOP 10:')
  sorted.forEach(([num, cnt], i) => {
    const bar = '█'.repeat(cnt)
    console.log(`  ${String(i + 1).padStart(2)}위: ${String(num).padStart(2)}번 — ${String(cnt).padStart(2)}회  ${bar}`)
  })
}

main().catch(console.error)
