<script setup lang="ts">
import { nextTick, ref } from 'vue'
import { ElMessage, ElNotification } from 'element-plus'
import {
  Plus, Search, Delete, Edit, Download, Upload, Star, StarFilled,
  Bell, Check, Warning, InfoFilled, CircleCloseFilled,
} from '@element-plus/icons-vue'
import { useSampleStore, type TableRow } from '@/stores/useSampleStore'

const store = useSampleStore()

const tagInputRef = ref<HTMLInputElement | null>(null)

async function showTagInput() {
  store.tagInputVisible = true
  await nextTick()
  tagInputRef.value?.focus()
}

function handleTagConfirm() {
  store.addTag(store.tagInputValue)
}

const statusMap = {
  active: { type: 'success' as const, label: '활성' },
  inactive: { type: 'danger' as const, label: '비활성' },
  pending: { type: 'warning' as const, label: '대기' },
}

function formatAmount(val: number) {
  return val.toLocaleString('ko-KR') + '원'
}

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
      <h3 class="section-title">달력 (Date Picker)</h3>
      <div class="row">
        <div class="col">
          <p class="label">단일 날짜</p>
          <el-date-picker
            v-model="store.singleDate"
            type="date"
            placeholder="날짜 선택"
            format="YYYY-MM-DD"
            value-format="YYYY-MM-DD"
            style="width: 220px"
          />
          <span class="value-badge" v-if="store.singleDate">{{ store.singleDate }}</span>
        </div>
        <div class="col">
          <p class="label">날짜 범위 (시작 ~ 종료)</p>
          <el-date-picker
            v-model="store.dateRange"
            type="daterange"
            range-separator="~"
            start-placeholder="시작일"
            end-placeholder="종료일"
            format="YYYY-MM-DD"
            value-format="YYYY-MM-DD"
            style="width: 320px"
          />
          <span class="value-badge" v-if="store.dateRange">
            {{ store.dateRange[0] }} ~ {{ store.dateRange[1] }}
          </span>
        </div>
        <div class="col">
          <p class="label">날짜 + 시간</p>
          <el-date-picker
            v-model="store.datetimeValue"
            type="datetime"
            placeholder="날짜/시간 선택"
            format="YYYY-MM-DD HH:mm"
            value-format="YYYY-MM-DD HH:mm"
            style="width: 240px"
          />
          <span class="value-badge" v-if="store.datetimeValue">{{ store.datetimeValue }}</span>
        </div>
      </div>
    </section>

    <!-- ── 2. Select ── -->
    <section class="section">
      <h3 class="section-title">셀렉트 (Select)</h3>
      <div class="row">
        <div class="col">
          <p class="label">단일 선택</p>
          <el-select v-model="store.singleSelect" placeholder="프레임워크 선택" clearable style="width: 200px">
            <el-option
              v-for="opt in store.selectOptions"
              :key="opt.value"
              :label="opt.label"
              :value="opt.value"
            />
          </el-select>
          <span class="value-badge" v-if="store.singleSelect">{{ store.singleSelect }}</span>
        </div>
        <div class="col">
          <p class="label">멀티 선택</p>
          <el-select
            v-model="store.multiSelect"
            multiple
            collapse-tags
            collapse-tags-tooltip
            placeholder="여러 항목 선택"
            style="width: 280px"
          >
            <el-option
              v-for="opt in store.selectOptions"
              :key="opt.value"
              :label="opt.label"
              :value="opt.value"
            />
          </el-select>
          <span class="value-badge" v-if="store.multiSelect.length">{{ store.multiSelect.join(', ') }}</span>
        </div>
        <div class="col">
          <p class="label">그룹 셀렉트</p>
          <el-select v-model="store.groupSelect" placeholder="카테고리 선택" clearable style="width: 200px">
            <el-option-group label="프론트엔드">
              <el-option label="Vue.js" value="vue" />
              <el-option label="React" value="react" />
            </el-option-group>
            <el-option-group label="백엔드">
              <el-option label="Spring Boot" value="spring" />
              <el-option label="Node.js" value="node" />
            </el-option-group>
          </el-select>
          <span class="value-badge" v-if="store.groupSelect">{{ store.groupSelect }}</span>
        </div>
      </div>
    </section>

    <!-- ── 3. 인풋 ── -->
    <section class="section">
      <h3 class="section-title">인풋 (Input)</h3>
      <div class="row wrap">
        <div class="col">
          <p class="label">기본 텍스트</p>
          <el-input v-model="store.textInput" placeholder="텍스트 입력" clearable style="width: 220px" />
        </div>
        <div class="col">
          <p class="label">비밀번호</p>
          <el-input v-model="store.passwordInput" type="password" placeholder="비밀번호" show-password style="width: 220px" />
        </div>
        <div class="col">
          <p class="label">검색 인풋</p>
          <el-input v-model="store.searchInput" placeholder="검색어" :prefix-icon="Search" style="width: 220px" />
        </div>
        <div class="col">
          <p class="label">숫자 입력</p>
          <el-input-number v-model="store.numberInput" :min="0" :max="100" :step="5" style="width: 180px" />
        </div>
        <div class="col" style="flex-basis: 100%">
          <p class="label">텍스트에어리어</p>
          <el-input
            v-model="store.textareaInput"
            type="textarea"
            :rows="3"
            placeholder="여러 줄 입력..."
            style="width: 480px; max-width: 100%"
          />
        </div>
      </div>
    </section>

    <!-- ── 4. 토큰(태그) 인풋 ── -->
    <section class="section">
      <h3 class="section-title">토큰 입력 (Tag Input)</h3>
      <div class="tag-input-area">
        <el-tag
          v-for="tag in store.tags"
          :key="tag"
          closable
          :disable-transitions="false"
          @close="store.removeTag(tag)"
          class="tag-item"
        >
          {{ tag }}
        </el-tag>
        <el-input
          v-if="store.tagInputVisible"
          ref="tagInputRef"
          v-model="store.tagInputValue"
          size="small"
          style="width: 100px"
          @keyup.enter="handleTagConfirm"
          @blur="handleTagConfirm"
        />
        <el-button v-else size="small" :icon="Plus" @click="showTagInput">태그 추가</el-button>
      </div>
      <p class="hint">Enter 또는 포커스 해제 시 태그 등록</p>
    </section>

    <!-- ── 5. 버튼 ── -->
    <section class="section">
      <h3 class="section-title">버튼 (Button)</h3>
      <div class="row wrap gap-sm">
        <el-button>기본</el-button>
        <el-button type="primary">Primary</el-button>
        <el-button type="success">Success</el-button>
        <el-button type="warning">Warning</el-button>
        <el-button type="danger">Danger</el-button>
        <el-button type="info">Info</el-button>
      </div>
      <div class="row wrap gap-sm mt-sm">
        <el-button plain>Plain</el-button>
        <el-button type="primary" plain>Primary Plain</el-button>
        <el-button type="success" round>Round</el-button>
        <el-button type="danger" round>Round Danger</el-button>
        <el-button type="primary" :icon="Edit" circle />
        <el-button type="success" :icon="Check" circle />
        <el-button type="danger" :icon="Delete" circle />
      </div>
      <div class="row wrap gap-sm mt-sm">
        <el-button size="large" type="primary">Large</el-button>
        <el-button type="primary">Default</el-button>
        <el-button size="small" type="primary">Small</el-button>
        <el-button type="primary" :icon="Download">다운로드</el-button>
        <el-button type="primary" :icon="Upload">업로드</el-button>
        <el-button type="primary" loading>로딩 중</el-button>
        <el-button disabled>비활성</el-button>
      </div>
    </section>

    <!-- ── 6. 라디오 & 체크박스 ── -->
    <section class="section">
      <h3 class="section-title">라디오 & 체크박스</h3>
      <div class="row wrap">
        <div class="col">
          <p class="label">라디오</p>
          <el-radio-group v-model="store.radioValue">
            <el-radio value="option1">옵션 1</el-radio>
            <el-radio value="option2">옵션 2</el-radio>
            <el-radio value="option3">옵션 3</el-radio>
          </el-radio-group>
        </div>
        <div class="col">
          <p class="label">라디오 버튼</p>
          <el-radio-group v-model="store.radioValue">
            <el-radio-button value="option1">옵션 1</el-radio-button>
            <el-radio-button value="option2">옵션 2</el-radio-button>
            <el-radio-button value="option3">옵션 3</el-radio-button>
          </el-radio-group>
        </div>
        <div class="col">
          <p class="label">체크박스</p>
          <el-checkbox-group v-model="store.checkboxGroup">
            <el-checkbox value="a">항목 A</el-checkbox>
            <el-checkbox value="b">항목 B</el-checkbox>
            <el-checkbox value="c">항목 C</el-checkbox>
            <el-checkbox value="d">항목 D</el-checkbox>
          </el-checkbox-group>
        </div>
        <div class="col">
          <p class="label">스위치</p>
          <el-switch v-model="store.switchValue" active-text="켜짐" inactive-text="꺼짐" />
        </div>
      </div>
    </section>

    <!-- ── 7. 슬라이더 & 평점 & 진행률 ── -->
    <section class="section">
      <h3 class="section-title">슬라이더 · 평점 · 진행률</h3>
      <div class="row wrap">
        <div class="col wide">
          <p class="label">슬라이더 — {{ store.sliderValue }}%</p>
          <el-slider v-model="store.sliderValue" style="width: 300px" />
        </div>
        <div class="col">
          <p class="label">평점 (Rate)</p>
          <el-rate v-model="store.rateValue" :texts="['최악', '나쁨', '보통', '좋음', '최고']" show-text />
        </div>
        <div class="col wide">
          <p class="label">진행률 — {{ store.progressValue }}%</p>
          <div class="progress-row">
            <el-progress :percentage="store.progressValue" style="flex: 1" />
            <el-button size="small" @click="store.progressValue = Math.min(100, store.progressValue + 10)">+10</el-button>
            <el-button size="small" @click="store.progressValue = Math.max(0, store.progressValue - 10)">-10</el-button>
          </div>
          <el-progress type="circle" :percentage="store.progressValue" :width="80" class="mt-sm" />
        </div>
      </div>
    </section>

    <!-- ── 8. 탭 ── -->
    <section class="section">
      <h3 class="section-title">탭 (Tabs)</h3>
      <el-tabs v-model="store.activeTab" type="border-card">
        <el-tab-pane label="기본 정보" name="info">
          <p>기본 정보 탭 내용입니다. 사용자의 프로필과 기본 설정을 표시합니다.</p>
        </el-tab-pane>
        <el-tab-pane label="상세 설정" name="settings">
          <p>상세 설정 탭 내용입니다. 알림, 보안, 연동 서비스를 관리합니다.</p>
        </el-tab-pane>
        <el-tab-pane label="활동 내역" name="activity">
          <p>활동 내역 탭 내용입니다. 최근 로그인, 게시글, 댓글 이력을 보여줍니다.</p>
        </el-tab-pane>
        <el-tab-pane label="통계" name="stats" :disabled="false">
          <p>통계 탭 내용입니다. 방문 수, 클릭 수, 전환율 등의 지표를 표시합니다.</p>
        </el-tab-pane>
      </el-tabs>
    </section>

    <!-- ── 9. 메시지 & 알림 ── -->
    <section class="section">
      <h3 class="section-title">메시지 & 알림 (Message / Notification)</h3>
      <div class="row wrap gap-sm">
        <el-button type="success" :icon="Check" @click="showMessage('success')">Success 메시지</el-button>
        <el-button type="warning" :icon="Warning" @click="showMessage('warning')">Warning 메시지</el-button>
        <el-button type="danger" :icon="CircleCloseFilled" @click="showMessage('error')">Error 메시지</el-button>
        <el-button type="info" :icon="InfoFilled" @click="showMessage('info')">Info 메시지</el-button>
      </div>
      <div class="row wrap gap-sm mt-sm">
        <el-button :icon="Bell" @click="showNotification('success')">Success 알림</el-button>
        <el-button :icon="Bell" @click="showNotification('warning')">Warning 알림</el-button>
        <el-button :icon="Bell" @click="showNotification('error')">Error 알림</el-button>
        <el-button :icon="Bell" @click="showNotification('info')">Info 알림</el-button>
      </div>
      <div class="alert-area mt-sm">
        <el-alert title="성공 알럿 — 작업이 완료되었습니다." type="success" :closable="false" />
        <el-alert title="경고 알럿 — 주의가 필요합니다." type="warning" show-icon />
        <el-alert title="오류 알럿 — 처리 중 오류가 발생했습니다." type="error" show-icon />
        <el-alert title="정보 알럿 — 참고해 주세요." type="info" description="자세한 내용은 문서를 확인하세요." show-icon />
      </div>
    </section>

    <!-- ── 10. 다이얼로그 ── -->
    <section class="section">
      <h3 class="section-title">다이얼로그 (Dialog)</h3>
      <el-button type="primary" @click="store.dialogVisible = true">다이얼로그 열기</el-button>
      <el-dialog v-model="store.dialogVisible" title="샘플 다이얼로그" width="480px">
        <p>다이얼로그 본문 영역입니다. 확인이 필요한 내용이나 폼을 표시합니다.</p>
        <el-form label-width="80px" class="mt-sm">
          <el-form-item label="이름">
            <el-input placeholder="이름 입력" />
          </el-form-item>
          <el-form-item label="이메일">
            <el-input placeholder="이메일 입력" />
          </el-form-item>
        </el-form>
        <template #footer>
          <el-button @click="store.dialogVisible = false">취소</el-button>
          <el-button type="primary" @click="store.dialogVisible = false; showMessage('success')">확인</el-button>
        </template>
      </el-dialog>
    </section>

    <!-- ── 11. 그리드 (테이블) ── -->
    <section class="section">
      <h3 class="section-title">그리드 (Table)</h3>
      <div class="table-toolbar">
        <el-input
          v-model="store.tableSearch"
          placeholder="이름 또는 카테고리 검색"
          :prefix-icon="Search"
          clearable
          style="width: 260px"
        />
        <el-button type="primary" :icon="Plus">신규 등록</el-button>
      </div>
      <el-table :data="store.filteredTableData" stripe border style="width: 100%" class="mt-sm">
        <el-table-column type="index" label="#" width="50" align="center" />
        <el-table-column prop="name" label="이름" min-width="100" />
        <el-table-column prop="category" label="카테고리" width="110" align="center" />
        <el-table-column prop="status" label="상태" width="90" align="center">
          <template #default="{ row }: { row: TableRow }">
            <el-tag :type="statusMap[row.status].type" size="small">
              {{ statusMap[row.status].label }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="amount" label="금액" width="130" align="right">
          <template #default="{ row }">{{ formatAmount(row.amount) }}</template>
        </el-table-column>
        <el-table-column prop="date" label="등록일" width="110" align="center" />
        <el-table-column label="액션" width="120" align="center">
          <template #default>
            <el-button size="small" :icon="Edit" type="primary" plain />
            <el-button size="small" :icon="Delete" type="danger" plain />
          </template>
        </el-table-column>
      </el-table>
      <div class="pagination-wrap">
        <el-pagination
          v-model:current-page="store.tableCurrentPage"
          v-model:page-size="store.tablePageSize"
          :page-sizes="[5, 10, 20]"
          :total="store.filteredTableData.length"
          layout="total, sizes, prev, pager, next"
          background
        />
      </div>
    </section>

    <!-- ── 12. 카드 목록 ── -->
    <section class="section">
      <h3 class="section-title">카드 목록 (Card List)</h3>
      <div class="card-grid">
        <el-card
          v-for="item in store.cardItems"
          :key="item.id"
          class="card-item"
          shadow="hover"
        >
          <div class="card-header">
            <el-avatar :size="36" class="card-avatar">{{ item.avatar }}</el-avatar>
            <el-tag size="small" type="primary">{{ item.tag }}</el-tag>
          </div>
          <h4 class="card-title">{{ item.title }}</h4>
          <p class="card-desc">{{ item.description }}</p>
          <div class="card-footer">
            <el-button
              text
              :type="item.liked ? 'danger' : 'default'"
              :icon="item.liked ? StarFilled : Star"
              @click="store.toggleCardLike(item.id)"
            >
              {{ item.likes }}
            </el-button>
            <el-button text type="primary" :icon="Edit">편집</el-button>
          </div>
        </el-card>
      </div>
    </section>

    <!-- ── 13. 툴팁 & 팝오버 ── -->
    <section class="section">
      <h3 class="section-title">툴팁 & 팝오버 (Tooltip / Popover)</h3>
      <div class="row wrap gap-sm">
        <el-tooltip content="위쪽 툴팁" placement="top">
          <el-button>Top 툴팁</el-button>
        </el-tooltip>
        <el-tooltip content="아래쪽 툴팁" placement="bottom">
          <el-button>Bottom 툴팁</el-button>
        </el-tooltip>
        <el-popover placement="right" title="팝오버 제목" :width="200" trigger="click" content="팝오버 내용입니다. 클릭하면 나타납니다.">
          <template #reference>
            <el-button type="primary">팝오버 (클릭)</el-button>
          </template>
        </el-popover>
        <el-popover placement="top" title="호버 팝오버" :width="200" trigger="hover" content="마우스를 올리면 나타납니다.">
          <template #reference>
            <el-button type="success">팝오버 (호버)</el-button>
          </template>
        </el-popover>
      </div>
    </section>

    <!-- ── 14. 타임라인 & 뱃지 & 아바타 ── -->
    <section class="section">
      <h3 class="section-title">타임라인 · 뱃지 · 아바타</h3>
      <div class="row wrap">
        <div class="col wide">
          <p class="label">타임라인</p>
          <el-timeline>
            <el-timeline-item timestamp="2026-05-01" placement="top" type="primary">
              프로젝트 킥오프 및 요구사항 정의
            </el-timeline-item>
            <el-timeline-item timestamp="2026-05-07" placement="top" type="success">
              백엔드 API 개발 완료
            </el-timeline-item>
            <el-timeline-item timestamp="2026-05-12" placement="top" type="warning">
              프론트엔드 통합 테스트 진행 중
            </el-timeline-item>
            <el-timeline-item timestamp="2026-05-20" placement="top">
              배포 예정
            </el-timeline-item>
          </el-timeline>
        </div>
        <div class="col">
          <p class="label">뱃지 (Badge)</p>
          <div class="badge-row">
            <el-badge :value="5" class="badge-item">
              <el-button>댓글</el-button>
            </el-badge>
            <el-badge :value="99" :max="50" class="badge-item">
              <el-button>알림</el-button>
            </el-badge>
            <el-badge is-dot class="badge-item">
              <el-button :icon="Bell">메시지</el-button>
            </el-badge>
          </div>
          <p class="label mt-sm">아바타 (Avatar)</p>
          <div class="avatar-row">
            <el-avatar :size="48" src="https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png" />
            <el-avatar :size="48" style="background-color: #409eff">AB</el-avatar>
            <el-avatar :size="48" :icon="Star" style="background-color: #67c23a" />
            <el-avatar-group>
              <el-avatar src="https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png" />
              <el-avatar style="background-color: #409eff">B</el-avatar>
              <el-avatar style="background-color: #e6a23c">C</el-avatar>
              <el-avatar style="background-color: #f56c6c">+3</el-avatar>
            </el-avatar-group>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>
.sample-page {
  max-width: 1100px;
}

.page-title {
  margin-bottom: 32px;
}
.page-title h2 {
  font-size: 24px;
  font-weight: 700;
  margin: 0 0 4px;
}
.page-desc {
  color: #909399;
  font-size: 14px;
  margin: 0;
}

.section {
  background: #fff;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  padding: 24px;
  margin-bottom: 24px;
}

.section-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  margin: 0 0 20px;
  padding-bottom: 12px;
  border-bottom: 1px solid #ebeef5;
}

.row {
  display: flex;
  align-items: flex-start;
  gap: 24px;
  flex-wrap: nowrap;
}
.row.wrap { flex-wrap: wrap; }

.col {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.col.wide { min-width: 340px; }

.label {
  font-size: 13px;
  color: #606266;
  margin: 0;
  font-weight: 500;
}

.value-badge {
  display: inline-block;
  background: #ecf5ff;
  color: #409eff;
  border-radius: 4px;
  font-size: 12px;
  padding: 2px 8px;
  margin-top: 4px;
}

.hint {
  font-size: 12px;
  color: #c0c4cc;
  margin: 8px 0 0;
}

/* 태그 인풋 */
.tag-input-area {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  border: 1px dashed #dcdfe6;
  border-radius: 6px;
  min-height: 48px;
}
.tag-item { cursor: default; }

/* 버튼 */
.gap-sm { gap: 8px; }
.mt-sm { margin-top: 12px; }

/* 진행률 */
.progress-row {
  display: flex;
  align-items: center;
  gap: 12px;
}

/* 알림 */
.alert-area {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-top: 16px;
}

/* 테이블 */
.table-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.pagination-wrap {
  margin-top: 16px;
  display: flex;
  justify-content: flex-end;
}

/* 카드 그리드 */
.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 16px;
}
.card-item { transition: transform 0.2s; }
.card-item:hover { transform: translateY(-2px); }
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}
.card-avatar { background-color: #409eff; color: #fff; font-weight: 700; }
.card-title {
  font-size: 15px;
  font-weight: 600;
  margin: 0 0 8px;
  color: #303133;
}
.card-desc {
  font-size: 13px;
  color: #606266;
  line-height: 1.6;
  margin: 0 0 12px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
.card-footer {
  display: flex;
  justify-content: space-between;
  border-top: 1px solid #f0f0f0;
  padding-top: 10px;
}

/* 뱃지 & 아바타 */
.badge-row { display: flex; gap: 16px; align-items: center; }
.badge-item { display: inline-block; }
.avatar-row { display: flex; gap: 12px; align-items: center; flex-wrap: wrap; }
</style>
