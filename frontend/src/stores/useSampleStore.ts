import { defineStore } from 'pinia'
import { reactive } from 'vue'

export interface TableRow {
  id: number
  name: string
  status: 'active' | 'inactive' | 'pending'
  category: string
  amount: number
  date: string
}

export interface CardItem {
  id: number
  title: string
  description: string
  tag: string
  likes: number
  liked: boolean
  avatar: string
}

export const useSampleStore = defineStore('sample', () => {
  const tableData = reactive<TableRow[]>([
    { id: 1, name: '사용자 A', status: 'active',   category: '프리미엄', amount: 125000, date: '2026-05-01' },
    { id: 2, name: '사용자 B', status: 'pending',  category: '기본',     amount: 35000,  date: '2026-05-03' },
    { id: 3, name: '사용자 C', status: 'inactive', category: '프리미엄', amount: 98000,  date: '2026-05-07' },
    { id: 4, name: '사용자 D', status: 'active',   category: '기본',     amount: 42000,  date: '2026-05-10' },
    { id: 5, name: '사용자 E', status: 'active',   category: 'VIP',      amount: 315000, date: '2026-05-12' },
    { id: 6, name: '사용자 F', status: 'pending',  category: 'VIP',      amount: 278000, date: '2026-05-13' },
  ])

  const cardItems = reactive<CardItem[]>([
    { id: 1, title: 'Vue 3 Composition API',    description: 'setup()을 활용한 모던 Vue 개발 패턴과 반응형 시스템의 핵심을 알아봅니다.',        tag: 'Vue',        likes: 42, liked: false, avatar: 'V' },
    { id: 2, title: 'TypeScript 고급 타입',      description: 'Conditional, Mapped, Template Literal Types 등 고급 타입 활용법.',            tag: 'TypeScript', likes: 38, liked: true,  avatar: 'T' },
    { id: 3, title: 'Pinia 상태관리',            description: 'Vuex를 대체하는 Pinia의 Store 설계 패턴과 DevTools 연동 방법.',                tag: 'Pinia',      likes: 57, liked: false, avatar: 'P' },
    { id: 4, title: 'Element Plus 커스터마이징', description: 'CSS 변수와 SCSS를 활용해 Element Plus 컴포넌트를 브랜드에 맞게 수정하는 방법.', tag: 'UI',         likes: 29, liked: false, avatar: 'E' },
    { id: 5, title: 'Vite 빌드 최적화',          description: '청크 분할, 트리쉐이킹, 코드 스플리팅으로 번들 사이즈를 줄이는 실전 전략.',      tag: 'Vite',       likes: 63, liked: true,  avatar: 'V' },
    { id: 6, title: 'Spring Boot + Vue 연동',    description: 'CORS 설정, JWT 인증, API 프록시 구성으로 풀스택 프로젝트 완성하기.',            tag: 'Full Stack', likes: 81, liked: false, avatar: 'S' },
  ])

  function toggleCardLike(id: number) {
    const item = cardItems.find((c) => c.id === id)
    if (!item) return
    item.liked = !item.liked
    item.likes += item.liked ? 1 : -1
  }

  return { tableData, cardItems, toggleCardLike }
})
