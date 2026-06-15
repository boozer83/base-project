<script setup lang="ts">
import { ref, computed } from 'vue'
import { ElMessage, ElNotification } from 'element-plus'
import { Edit, Delete, Download, Upload, Check, Warning, CircleCloseFilled, InfoFilled, Bell, Star, StarFilled } from '@element-plus/icons-vue'
import {
  CommonCalendar, CommonCalendarRange,
  CommonSelect, CommonSelectMultiple,
  CommonInput, CommonInputNumber,
  CommonTagInput, CommonSwitch,
  CommonSlider, CommonRate, CommonProgress,
  CommonButton, CommonDialog,
  CommonRadioGroup, CommonCheckboxGroup,
  CommonTabs, CommonAlert,
  CommonTooltip, CommonPopover,
  CommonBadge, CommonAvatar, CommonAvatarGroup, CommonTimeline,
  CommonTable, CommonCardList, CommonTag,
  CommonForm, CommonFormItem, CommonPagination,
} from '@/components/common'
import type { SelectOption, TableColumn, TimelineItem, TabItem } from '@/components/common'
import { useSampleStore } from '@/stores/useSampleStore'
import type { TableRow } from '@/stores/useSampleStore'

const store = useSampleStore()

// 달력
const singleDate    = ref('')
const datetimeValue = ref('')
const dateRange     = ref<[string, string] | null>(null)

// 셀렉트
const selectOptions: SelectOption[] = [
  { value: 'vue', label: 'Vue.js' }, { value: 'react', label: 'React' },
  { value: 'angular', label: 'Angular' }, { value: 'svelte', label: 'Svelte' },
  { value: 'nuxt', label: 'Nuxt.js' }, { value: 'next', label: 'Next.js' },
]
const groupOptions = [
  { label: '프론트엔드', options: [{ value: 'vue', label: 'Vue.js' }, { value: 'react', label: 'React' }] },
  { label: '백엔드', options: [{ value: 'spring', label: 'Spring Boot' }, { value: 'node', label: 'Node.js' }] },
]
const singleSelect = ref<string | number>('')
const multiSelect  = ref<(string | number)[]>([])
const groupSelect  = ref<string | number>('')

// 인풋
const textInput     = ref('')
const passwordInput = ref('')
const searchInput   = ref('')
const textareaInput = ref('')
const numberInput   = ref(0)

// 태그
const tags = ref(['Vue', 'TypeScript'])

// 라디오 / 체크박스 / 스위치
const radioOptions = [
  { value: 'option1', label: '옵션 1' },
  { value: 'option2', label: '옵션 2' },
  { value: 'option3', label: '옵션 3' },
]
const checkboxOptions = [
  { value: 'a', label: '항목 A' }, { value: 'b', label: '항목 B' },
  { value: 'c', label: '항목 C' }, { value: 'd', label: '항목 D' },
]
const radioValue    = ref('option1')
const checkboxGroup = ref<(string | number)[]>(['a', 'c'])
const switchValue   = ref(true)

// 슬라이더 / 평점 / 진행률
const sliderValue   = ref(40)
const rateValue     = ref(3)
const progressValue = ref(65)

// 탭
const activeTab = ref('info')
const tabs: TabItem[] = [
  { name: 'info',     label: '기본 정보' },
  { name: 'settings', label: '상세 설정' },
  { name: 'activity', label: '활동 내역' },
  { name: 'stats',    label: '통계' },
]

// 다이얼로그
const dialogVisible = ref(false)

// 타임라인
const timelineItems: TimelineItem[] = [
  { content: '프로젝트 킥오프 및 요구사항 정의', timestamp: '2026-05-01', type: 'primary' },
  { content: '백엔드 API 개발 완료',             timestamp: '2026-05-07', type: 'success' },
  { content: '프론트엔드 통합 테스트 진행 중',   timestamp: '2026-05-12', type: 'warning' },
  { content: '배포 예정',                         timestamp: '2026-05-20' },
]

// 테이블
const tableColumns: TableColumn[] = [
  { prop: 'index',    label: '#',      type: 'index', width: 50 },
  { prop: 'name',     label: '이름',   minWidth: 100 },
  { prop: 'category', label: '카테고리', width: 110, align: 'center' },
  { prop: 'status',   label: '상태',   width: 90,  align: 'center', slot: true },
  { prop: 'amount',   label: '금액',   width: 130, align: 'right',  slot: true },
  { prop: 'date',     label: '등록일', width: 110, align: 'center' },
  { prop: 'action',   label: '액션',   width: 120, align: 'center', slot: true },
]
const statusMap: Record<TableRow['status'], { type: 'success' | 'danger' | 'warning'; label: string }> = {
  active:   { type: 'success', label: '활성' },
  inactive: { type: 'danger',  label: '비활성' },
  pending:  { type: 'warning', label: '대기' },
}
function formatAmount(val: number) {
  return val.toLocaleString('ko-KR') + '원'
}

// 페이지네이션
const page1 = ref(1)
const page2 = ref(1)
const page3 = ref(1)
const pageSize3 = ref(5)
const page4 = ref(1)
const pageSize4 = ref(5)

const demoItems = Array.from({ length: 53 }, (_, i) => ({
  id: i + 1,
  name: `항목 ${String(i + 1).padStart(2, '0')}`,
  desc: `설명 텍스트 ${i + 1}`,
}))
const demoPageSize = ref(8)
const demoCurrentPage = ref(1)
const demoPageData = computed(() => {
  const start = (demoCurrentPage.value - 1) * demoPageSize.value
  return demoItems.slice(start, start + demoPageSize.value)
})

// 메시지 / 알림
function showMessage(type: 'success' | 'warning' | 'error' | 'info') {
  ElMessage({ type, message: `${type} 메시지입니다.`, showClose: true })
}
function showNotification(type: 'success' | 'warning' | 'error' | 'info') {
  ElNotification({ type, title: '알림', message: `${type} 알림이 도착했습니다.`, duration: 3000 })
}
</script>

<template>
  <div class="sample-page">
    <div class="page-title">
      <h2>컴포넌트 샘플</h2>
      <p class="page-desc">Element Plus 주요 컴포넌트 모음 · 상태관리: Pinia</p>
    </div>

    <!-- ── 1. 달력 ── -->
    <section class="section">
      <h3 class="section-title">달력 (CommonCalendar / CommonCalendarRange)</h3>
      <div class="row">
        <div class="col">
          <p class="label">단일 날짜</p>
          <CommonCalendar v-model="singleDate" />
          <span v-if="singleDate" class="badge">{{ singleDate }}</span>
        </div>
        <div class="col">
          <p class="label">날짜 + 시간</p>
          <CommonCalendar v-model="datetimeValue" type="datetime" />
          <span v-if="datetimeValue" class="badge">{{ datetimeValue }}</span>
        </div>
        <div class="col">
          <p class="label">날짜 범위</p>
          <CommonCalendarRange v-model="dateRange" />
          <span v-if="dateRange" class="badge">{{ dateRange[0] }} ~ {{ dateRange[1] }}</span>
        </div>
      </div>
    </section>

    <!-- ── 2. 셀렉트 ── -->
    <section class="section">
      <h3 class="section-title">셀렉트 (CommonSelect / CommonSelectMultiple)</h3>
      <div class="row">
        <div class="col">
          <p class="label">단일 선택</p>
          <CommonSelect v-model="singleSelect" :options="selectOptions" clearable style="width: 200px" />
          <span v-if="singleSelect" class="badge">{{ singleSelect }}</span>
        </div>
        <div class="col">
          <p class="label">멀티 선택</p>
          <CommonSelectMultiple v-model="multiSelect" :options="selectOptions" style="width: 280px" />
          <span v-if="multiSelect.length" class="badge">{{ multiSelect.join(', ') }}</span>
        </div>
        <div class="col">
          <p class="label">그룹 셀렉트</p>
          <CommonSelect v-model="groupSelect" :groups="groupOptions" clearable style="width: 200px" />
          <span v-if="groupSelect" class="badge">{{ groupSelect }}</span>
        </div>
      </div>
    </section>

    <!-- ── 3. 인풋 ── -->
    <section class="section">
      <h3 class="section-title">인풋 (CommonInput / CommonInputNumber)</h3>
      <div class="row">
        <div class="col">
          <p class="label">텍스트</p>
          <CommonInput v-model="textInput" placeholder="텍스트 입력" clearable style="width: 200px" />
        </div>
        <div class="col">
          <p class="label">비밀번호</p>
          <CommonInput v-model="passwordInput" type="password" placeholder="비밀번호" style="width: 200px" />
        </div>
        <div class="col">
          <p class="label">검색</p>
          <CommonInput v-model="searchInput" type="search" placeholder="검색어" style="width: 200px" />
        </div>
        <div class="col">
          <p class="label">숫자 입력</p>
          <CommonInputNumber v-model="numberInput" :min="0" :max="100" :step="5" style="width: 180px" />
        </div>
        <div class="col full">
          <p class="label">텍스트에어리어</p>
          <CommonInput v-model="textareaInput" type="textarea" placeholder="여러 줄 입력..." :rows="3" style="width: 480px; max-width: 100%" />
        </div>
      </div>
    </section>

    <!-- ── 4. 태그 인풋 ── -->
    <section class="section">
      <h3 class="section-title">토큰 입력 (CommonTagInput)</h3>
      <CommonTagInput v-model="tags" />
      <p class="hint">Enter 또는 포커스 해제 시 등록 · 동일 태그 중복 불가</p>
    </section>

    <!-- ── 5. 버튼 ── -->
    <section class="section">
      <h3 class="section-title">버튼 (CommonButton)</h3>
      <div class="btn-group">
        <div class="row">
          <CommonButton>기본</CommonButton>
          <CommonButton type="primary">Primary</CommonButton>
          <CommonButton type="success">Success</CommonButton>
          <CommonButton type="warning">Warning</CommonButton>
          <CommonButton type="danger">Danger</CommonButton>
          <CommonButton type="info">Info</CommonButton>
        </div>
        <div class="row">
          <CommonButton plain>Plain</CommonButton>
          <CommonButton type="primary" plain>Primary Plain</CommonButton>
          <CommonButton type="success" round>Round</CommonButton>
          <CommonButton type="primary" :icon="Edit" circle />
          <CommonButton type="success" :icon="Check" circle />
          <CommonButton type="danger" :icon="Delete" circle />
        </div>
        <div class="row">
          <CommonButton size="large" type="primary">Large</CommonButton>
          <CommonButton type="primary">Default</CommonButton>
          <CommonButton size="small" type="primary">Small</CommonButton>
          <CommonButton type="primary" :icon="Download">다운로드</CommonButton>
          <CommonButton type="primary" :icon="Upload">업로드</CommonButton>
          <CommonButton type="primary" loading>로딩 중</CommonButton>
          <CommonButton disabled>비활성</CommonButton>
        </div>
      </div>
    </section>

    <!-- ── 6. 라디오 & 체크박스 ── -->
    <section class="section">
      <h3 class="section-title">라디오 & 체크박스 (CommonRadioGroup / CommonCheckboxGroup)</h3>
      <div class="row">
        <div class="col">
          <p class="label">라디오</p>
          <CommonRadioGroup v-model="radioValue" :options="radioOptions" />
        </div>
        <div class="col">
          <p class="label">라디오 버튼</p>
          <CommonRadioGroup v-model="radioValue" :options="radioOptions" button-style />
        </div>
        <div class="col">
          <p class="label">체크박스</p>
          <CommonCheckboxGroup v-model="checkboxGroup" :options="checkboxOptions" />
        </div>
        <div class="col">
          <p class="label">스위치</p>
          <CommonSwitch v-model="switchValue" active-text="켜짐" inactive-text="꺼짐" />
        </div>
      </div>
    </section>

    <!-- ── 7. 슬라이더 · 평점 · 진행률 ── -->
    <section class="section">
      <h3 class="section-title">슬라이더 · 평점 · 진행률 (CommonSlider / CommonRate / CommonProgress)</h3>
      <div class="row">
        <div class="col wide">
          <p class="label">슬라이더 — {{ sliderValue }}%</p>
          <CommonSlider v-model="sliderValue" style="width: 300px" />
        </div>
        <div class="col">
          <p class="label">평점</p>
          <CommonRate v-model="rateValue" :texts="['최악','나쁨','보통','좋음','최고']" show-text />
        </div>
        <div class="col wide">
          <p class="label">진행률 — {{ progressValue }}%</p>
          <div class="progress-row">
            <CommonProgress :percentage="progressValue" style="flex: 1" />
            <CommonButton size="small" @click="progressValue = Math.min(100, progressValue + 10)">+10</CommonButton>
            <CommonButton size="small" @click="progressValue = Math.max(0,   progressValue - 10)">-10</CommonButton>
          </div>
          <CommonProgress type="circle" :percentage="progressValue" :width="80" style="margin-top: 12px" />
        </div>
      </div>
    </section>

    <!-- ── 8. 탭 ── -->
    <section class="section">
      <h3 class="section-title">탭 (CommonTabs)</h3>
      <CommonTabs v-model="activeTab" :tabs="tabs" type="border-card">
        <template #info>프로필과 기본 설정을 표시합니다.</template>
        <template #settings>알림, 보안, 연동 서비스를 관리합니다.</template>
        <template #activity>최근 로그인, 게시글, 댓글 이력을 보여줍니다.</template>
        <template #stats>방문 수, 클릭 수, 전환율 등의 지표를 표시합니다.</template>
      </CommonTabs>
    </section>

    <!-- ── 9. 메시지 & 알림 ── -->
    <section class="section">
      <h3 class="section-title">메시지 & 알림 (CommonAlert)</h3>
      <div class="btn-group">
        <div class="row">
          <CommonButton type="success"  :icon="Check"             @click="showMessage('success')">Success</CommonButton>
          <CommonButton type="warning"  :icon="Warning"           @click="showMessage('warning')">Warning</CommonButton>
          <CommonButton type="danger"   :icon="CircleCloseFilled" @click="showMessage('error')">Error</CommonButton>
          <CommonButton type="info"     :icon="InfoFilled"        @click="showMessage('info')">Info</CommonButton>
          <CommonButton :icon="Bell" @click="showNotification('success')">알림 (success)</CommonButton>
          <CommonButton :icon="Bell" @click="showNotification('error')">알림 (error)</CommonButton>
        </div>
        <div class="alert-stack">
          <CommonAlert title="성공" type="success" :closable="false" />
          <CommonAlert title="경고" type="warning" show-icon />
          <CommonAlert title="오류" type="error" show-icon />
          <CommonAlert title="정보" description="자세한 내용은 문서를 참고하세요." type="info" show-icon />
        </div>
      </div>
    </section>

    <!-- ── 10. 다이얼로그 ── -->
    <section class="section">
      <h3 class="section-title">다이얼로그 (CommonDialog)</h3>
      <CommonButton type="primary" @click="dialogVisible = true">다이얼로그 열기</CommonButton>
      <CommonDialog v-model="dialogVisible" title="샘플 다이얼로그" width="480px">
        <p>확인이 필요한 내용이나 폼을 표시합니다.</p>
        <CommonForm label-width="80px" style="margin-top: 16px">
          <CommonFormItem label="이름"><CommonInput placeholder="이름 입력" /></CommonFormItem>
          <CommonFormItem label="이메일"><CommonInput placeholder="이메일 입력" /></CommonFormItem>
        </CommonForm>
        <template #footer>
          <CommonButton @click="dialogVisible = false">취소</CommonButton>
          <CommonButton type="primary" @click="dialogVisible = false; showMessage('success')">확인</CommonButton>
        </template>
      </CommonDialog>
    </section>

    <!-- ── 11. 테이블 ── -->
    <section class="section">
      <h3 class="section-title">그리드 (CommonTable)</h3>
      <CommonTable
        :columns="tableColumns"
        :data="(store.tableData as Record<string, unknown>[])"
        searchable
        :page-sizes="[5, 10, 20]"
        :default-page-size="5"
        search-placeholder="이름 또는 카테고리 검색"
      >
        <template #toolbar-right>
          <CommonButton type="primary" :icon="Edit">신규 등록</CommonButton>
        </template>
        <template #status="{ row }">
          <CommonTag :type="statusMap[(row as TableRow).status].type" size="small">
            {{ statusMap[(row as TableRow).status].label }}
          </CommonTag>
        </template>
        <template #amount="{ row }">{{ formatAmount((row as TableRow).amount) }}</template>
        <template #action>
          <CommonButton size="small" :icon="Edit"   type="primary" plain />
          <CommonButton size="small" :icon="Delete" type="danger"  plain />
        </template>
      </CommonTable>
    </section>

    <!-- ── 12. 카드 목록 ── -->
    <section class="section">
      <h3 class="section-title">카드 목록 (CommonCardList)</h3>
      <CommonCardList :items="(store.cardItems as Record<string, unknown>[])">
        <template #default="{ item }">
          <div class="card-header">
            <CommonAvatar :size="36" class="card-avatar">{{ (item as any).avatar }}</CommonAvatar>
            <CommonTag size="small" type="primary">{{ (item as any).tag }}</CommonTag>
          </div>
          <h4 class="card-title">{{ (item as any).title }}</h4>
          <p class="card-desc">{{ (item as any).description }}</p>
          <div class="card-footer">
            <CommonButton
              text
              :type="(item as any).liked ? 'danger' : 'default'"
              :icon="(item as any).liked ? StarFilled : Star"
              @click="store.toggleCardLike((item as any).id)"
            >
              {{ (item as any).likes }}
            </CommonButton>
            <CommonButton text type="primary" :icon="Edit">편집</CommonButton>
          </div>
        </template>
      </CommonCardList>
    </section>

    <!-- ── 13. 툴팁 & 팝오버 ── -->
    <section class="section">
      <h3 class="section-title">툴팁 & 팝오버 (CommonTooltip / CommonPopover)</h3>
      <div class="row">
        <CommonTooltip content="위쪽 툴팁" placement="top">
          <CommonButton>Top</CommonButton>
        </CommonTooltip>
        <CommonTooltip content="아래쪽 툴팁" placement="bottom">
          <CommonButton>Bottom</CommonButton>
        </CommonTooltip>
        <CommonPopover placement="right" title="팝오버" :width="200" trigger="click" content="클릭하면 나타납니다.">
          <template #reference><CommonButton type="primary">팝오버 (클릭)</CommonButton></template>
        </CommonPopover>
        <CommonPopover placement="top" title="호버 팝오버" :width="200" trigger="hover" content="마우스를 올리면 나타납니다.">
          <template #reference><CommonButton type="success">팝오버 (호버)</CommonButton></template>
        </CommonPopover>
      </div>
    </section>

    <!-- ── 14. 타임라인 · 뱃지 · 아바타 ── -->
    <section class="section">
      <h3 class="section-title">타임라인 · 뱃지 · 아바타 (CommonTimeline / CommonBadge / CommonAvatar)</h3>
      <div class="row">
        <div class="col">
          <p class="label">타임라인</p>
          <CommonTimeline :items="timelineItems" />
        </div>
        <div class="col">
          <p class="label">뱃지</p>
          <div class="row" style="gap: 16px">
            <CommonBadge :value="5"><CommonButton>댓글</CommonButton></CommonBadge>
            <CommonBadge :value="99" :max="50"><CommonButton>알림</CommonButton></CommonBadge>
            <CommonBadge is-dot><CommonButton :icon="Bell">메시지</CommonButton></CommonBadge>
          </div>
          <p class="label" style="margin-top: 20px">아바타</p>
          <div class="row" style="gap: 12px; align-items: center">
            <CommonAvatar :size="48" src="https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png" />
            <CommonAvatar :size="48" style="background-color: #409eff">AB</CommonAvatar>
            <CommonAvatarGroup>
              <CommonAvatar style="background-color: #409eff">B</CommonAvatar>
              <CommonAvatar style="background-color: #e6a23c">C</CommonAvatar>
              <CommonAvatar style="background-color: #f56c6c">+3</CommonAvatar>
            </CommonAvatarGroup>
          </div>
        </div>
      </div>
    </section>
    <!-- ── 15. 페이지네이션 ── -->
    <section class="section">
      <h3 class="section-title">페이지네이션 (CommonPagination)</h3>

      <div class="pagi-group">
        <p class="label">기본</p>
        <CommonPagination
          v-model:current-page="page1"
          :total="100"
          :page-size="10"
          layout="prev, pager, next"
        />

        <p class="label" style="margin-top: 20px">배경색 + 전체 건수 표시</p>
        <CommonPagination
          v-model:current-page="page2"
          :total="100"
          :page-size="10"
          background
          layout="prev, pager, next, total"
        />

        <p class="label" style="margin-top: 20px">Small 사이즈</p>
        <CommonPagination
          v-model:current-page="page3"
          v-model:page-size="pageSize3"
          :total="100"
          :page-sizes="[5, 10, 20]"
          small
          background
          layout="sizes, prev, pager, next, total"
        />

        <p class="label" style="margin-top: 20px">전체 레이아웃 (sizes · pager · jumper · total)</p>
        <CommonPagination
          v-model:current-page="page4"
          v-model:page-size="pageSize4"
          :total="253"
          :page-sizes="[5, 10, 20, 50]"
          background
          layout="total, sizes, prev, pager, next, jumper"
        />
      </div>

      <div style="margin-top: 28px">
        <p class="label">실제 데이터 연동 예시 — 총 {{ demoItems.length }}건 / 현재 페이지 {{ demoCurrentPage }}</p>
        <div class="demo-list">
          <div v-for="item in demoPageData" :key="item.id" class="demo-item">
            <span class="demo-id">#{{ item.id }}</span>
            <span class="demo-name">{{ item.name }}</span>
            <span class="demo-desc">{{ item.desc }}</span>
          </div>
        </div>
        <CommonPagination
          v-model:current-page="demoCurrentPage"
          v-model:page-size="demoPageSize"
          :total="demoItems.length"
          :page-sizes="[5, 8, 15]"
          background
          layout="total, sizes, prev, pager, next"
          style="margin-top: 12px"
        />
      </div>
    </section>
  </div>
</template>

<style scoped>
.sample-page { max-width: 1100px; }
.page-title { margin-bottom: 32px; }
.page-title h2 { font-size: 24px; font-weight: 700; margin: 0 0 4px; }
.page-desc { color: #909399; font-size: 14px; margin: 0; }

.section { background: #fff; border: 1px solid #e4e7ed; border-radius: 8px; padding: 24px; margin-bottom: 24px; }
.section-title { font-size: 16px; font-weight: 600; color: #303133; margin: 0 0 20px; padding-bottom: 12px; border-bottom: 1px solid #ebeef5; }

.row  { display: flex; align-items: flex-start; gap: 24px; flex-wrap: wrap; }
.col  { display: flex; flex-direction: column; gap: 8px; }
.col.wide { min-width: 340px; }
.col.full { flex-basis: 100%; }
.label { font-size: 13px; color: #606266; margin: 0; font-weight: 500; }
.badge { display: inline-block; background: #ecf5ff; color: #409eff; border-radius: 4px; font-size: 12px; padding: 2px 8px; }
.hint  { font-size: 12px; color: #c0c4cc; margin: 8px 0 0; }

.btn-group    { display: flex; flex-direction: column; gap: 12px; }
.progress-row { display: flex; align-items: center; gap: 12px; }
.alert-stack  { display: flex; flex-direction: column; gap: 8px; }

.card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; }
.card-avatar { background-color: #409eff; color: #fff; font-weight: 700; }
.card-title  { font-size: 15px; font-weight: 600; margin: 0 0 8px; color: #303133; }
.card-desc   { font-size: 13px; color: #606266; line-height: 1.6; margin: 0 0 12px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
.card-footer { display: flex; justify-content: space-between; border-top: 1px solid #f0f0f0; padding-top: 10px; }

.pagi-group { display: flex; flex-direction: column; gap: 4px; }

.demo-list { display: flex; flex-direction: column; gap: 6px; margin-top: 10px; }
.demo-item { display: flex; align-items: center; gap: 16px; padding: 8px 12px; background: #f5f7fa; border-radius: 6px; font-size: 13px; }
.demo-id   { width: 36px; color: #909399; font-size: 12px; }
.demo-name { width: 80px; font-weight: 600; color: #303133; }
.demo-desc { color: #606266; }
</style>
