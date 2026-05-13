# Project Overview

Vue 3 frontend application using Composition API and TypeScript.

## Tech Stack

- **Framework**: Vue 3 (Composition API, `<script setup>`)
- **Language**: TypeScript
- **Build Tool**: Vite
- **State Management**: Pinia
- **Router**: Vue Router 4
- **HTTP Client**: Axios
- **UI Library**: [e.g. Element Plus / Vuetify / PrimeVue — update as needed]
- **Styling**: SCSS / Tailwind CSS
- **Testing**: Vitest + Vue Test Utils

## Project Structure

```
src/
├── assets/          # Static assets (images, fonts, global styles)
├── components/      # Shared/reusable components
├── composables/     # Reusable Composition API logic (use*.ts)
├── layouts/         # Page layout components
├── pages/           # Route-level page components
├── router/          # Vue Router config (index.ts)
├── stores/          # Pinia stores (use*Store.ts)
├── services/        # API call modules (axios wrappers)
├── types/           # Global TypeScript types/interfaces
└── utils/           # Pure utility functions
```

## Code Style & Conventions

### Components
- Use `<script setup lang="ts">` — never Options API
- One component per file; filename in PascalCase (e.g. `UserCard.vue`)
- Props defined with `defineProps<{...}>()`, emits with `defineEmits<{...}>()`
- Always type all props and emits explicitly

### Composables
- Prefix with `use` (e.g. `useAuth.ts`, `useTableFilter.ts`)
- Return only what callers need; keep internal state private
- Handle loading / error state inside the composable

### Pinia Stores
- Filename pattern: `useXxxStore.ts`
- Use `defineStore('id', () => { ... })` (Setup Store style)
- No direct mutation from outside the store — expose actions

### API / Services
- All API calls go through `src/services/`
- Wrap axios in a typed function; never call `axios` directly in components
- Handle error responses centrally (axios interceptor in `src/services/http.ts`)

### TypeScript
- No `any` — use `unknown` and narrow types explicitly
- Define API response shapes in `src/types/`
- Prefer `interface` for object shapes, `type` for unions/aliases

### Naming
- Variables & functions: `camelCase`
- Components & types: `PascalCase`
- Constants: `UPPER_SNAKE_CASE`
- CSS classes: `kebab-case`

## Build & Dev Commands

```bash
npm install          # Install dependencies
npm run dev          # Start dev server (http://localhost:5173)
npm run build        # Production build
npm run preview      # Preview production build
npm run test         # Run unit tests (Vitest)
npm run lint         # ESLint check
npm run typecheck    # TypeScript type check
```

## Environment Variables

- Env files: `.env`, `.env.development`, `.env.production`
- All custom vars must be prefixed with `VITE_`
- Never commit `.env.local` or `.env.*.local`

```env
VITE_API_BASE_URL=http://localhost:8080/api
VITE_APP_TITLE=MyApp
```

## Important Rules

- Do NOT use `<script>` (non-setup) or Options API in new files
- Do NOT use `var` — only `const` / `let`
- Do NOT import from `vue` inside `*.ts` files that are not composables — keep concerns separated
- Always handle async errors with try/catch or `.catch()` — no unhandled promise rejections
- Keep components under ~200 lines; extract logic into composables if longer

## Compaction Instructions

When compacting, always preserve:
- The list of files modified in the current session
- Any API contract decisions (request/response shapes)
- Pending TODO items and their priority
