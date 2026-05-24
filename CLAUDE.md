# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

풀스택 커뮤니티 웹 애플리케이션.
- **Frontend**: `frontend/` — Vue 3 + TypeScript + Vite + Element Plus
- **Backend**: `backend/` — Spring Boot 3.3 + MyBatis + PostgreSQL

## Commands

### Frontend (`frontend/`)
```bash
npm install          # 의존성 설치
npm run dev          # 개발 서버 (http://localhost:5173)
npm run build        # 프로덕션 빌드
npm run typecheck    # TypeScript 타입 체크
```

### Backend (`backend/`)
```bash
# Windows에서 gradlew 없을 시 한 번만 실행
gradle wrapper

./gradlew bootRun                                              # 로컬 실행 (local 프로파일)
./gradlew build -x test                                        # 빌드
./gradlew test                                                 # 테스트
```

## Database

PostgreSQL `localhost:5432`, user: `postgresql`, password: `admin`, DB: `lotto`

초기 스키마는 `backend/src/main/resources/schema.sql` 참고. 직접 실행 필요:
```bash
psql -U postgresql -d lotto -f backend/src/main/resources/schema.sql
```

## Google OAuth 설정

`application-local.yml`의 `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET`을 환경변수로 주입하거나 직접 설정.

[Google Cloud Console](https://console.cloud.google.com/) → OAuth 2.0 클라이언트 생성:
- 승인된 리디렉션 URI: `http://localhost:8080/login/oauth2/code/google`

로그인 플로우: 프론트 "Google 로그인" 클릭 → `http://localhost:8080/oauth2/authorization/google` → Google 인증 → 백엔드가 JWT 발급 → `http://localhost:5173/auth/callback?token=<jwt>` 리디렉트

## Architecture

### 인증
- Spring Security OAuth2 Client로 Google 소셜 로그인 처리
- 성공 시 `OAuth2SuccessHandler`에서 JWT 생성 후 프론트엔드로 리디렉트
- 이후 모든 API 요청은 `Authorization: Bearer <token>` 헤더 사용
- `JwtAuthenticationFilter`가 토큰 검증 후 `SecurityContext`에 `UserPrincipal` 주입

### 권한
- `USER`: 일반 로그인 사용자 (조회만)
- `ADMIN`: 공지사항 CRUD 가능
- 비로그인: 공지사항 조회 가능

### 프론트엔드 상태
- `useAuthStore` (Pinia): token은 `localStorage`에 보관, user 정보는 메모리
- 모든 API 호출은 `src/services/` 경유, `axios` 직접 호출 금지

### 백엔드 레이어
Controller → Service → Mapper (MyBatis XML) 순서. 컨트롤러에 비즈니스 로직 없음.

## One Punch Run (Flutter 게임)

`one_punch/` 폴더에 위치한 Flutter 모바일 게임 프로젝트.

**기획서**: https://www.notion.so/36587ce9f21a80a093edcdca34f0e419

### 주요 구조
- `lib/game/` — Flame 엔진 게임 로직
- `lib/screens/` — 로비, 게임, 결과, 상점 등 화면
- `lib/models/` — 데이터 모델 (PlayerData, GameResult 등)
- `assets/audio/` — 사운드 파일 (WAV)

### 실행 명령 (`one_punch/`)
```bash
flutter pub get
flutter run
```

---

## Key Files

| 파일 | 역할 |
|------|------|
| `backend/src/main/resources/application-local.yml` | DB / OAuth / JWT 설정 |
| `backend/src/main/resources/mapper/*.xml` | MyBatis SQL |
| `frontend/src/stores/useAuthStore.ts` | 인증 상태 관리 |
| `frontend/src/services/http.ts` | Axios 인스턴스 + 인터셉터 |
| `frontend/.env.development` | 프론트 환경변수 |
