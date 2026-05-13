# Project Overview

Java Spring Boot backend API server with MyBatis and PostgreSQL/Greenplum.

## Tech Stack

- **Language**: Java 17
- **Framework**: Spring Boot 3.x
- **ORM / SQL Mapper**: MyBatis
- **Database**: PostgreSQL (or Greenplum)
- **Build Tool**: Gradle (or Maven — update as needed)
- **Authentication**: Spring Security + JWT
- **Testing**: JUnit 5 + Mockito
- **API Style**: RESTful JSON API

## Project Structure

```
src/main/java/com/example/app/
├── config/          # Spring config classes (Security, MyBatis, Scheduler, etc.)
├── controller/      # REST controllers (@RestController)
├── service/         # Business logic layer (@Service)
├── mapper/          # MyBatis mapper interfaces (@Mapper)
├── domain/          # Entity / VO / DTO classes
│   ├── entity/      # DB row mapping objects
│   ├── dto/         # Request/Response DTOs
│   └── vo/          # Value Objects
├── common/          # Shared utilities, constants, enums, exceptions
└── scheduler/       # Spring scheduled tasks

src/main/resources/
├── mapper/          # MyBatis XML mapper files (*Mapper.xml)
├── application.yml  # Main config
└── application-{profile}.yml  # Profile-specific config
```

## Code Style & Conventions

### Controllers
- Annotate with `@RestController` + `@RequestMapping("/api/v1/...")`
- No business logic in controllers — delegate entirely to service layer
- Use `@Valid` on request body params; define validation in DTO
- Wrap all responses in a common `ApiResponse<T>` wrapper

### Services
- One `@Service` class per domain feature
- `@Transactional` on write operations; `@Transactional(readOnly = true)` on reads
- Throw custom exceptions (e.g. `BusinessException`) — never raw `RuntimeException`

### MyBatis
- All queries go through mapper XML (`src/main/resources/mapper/`)
- Mapper interfaces use `@Mapper`; never write inline `@Select` / `@Insert` SQL in Java
- Use `<where>`, `<if>`, `<foreach>` for dynamic SQL — no string concatenation
- **Dynamic ORDER BY**: always whitelist column names server-side before injecting into SQL
  ```java
  private static final Set<String> ALLOWED_SORT_COLUMNS =
      Set.of("created_at", "name", "status");
  // validate before passing to mapper
  ```
- Use `useGeneratedKeys="true" keyProperty="id"` for INSERT returning PK

### Domain / DTO
- Immutable where possible — use `@Builder` (Lombok) on DTOs
- Separate Request DTO from Response DTO; never expose entity directly
- Null-safety: annotate with `@NotNull`, `@NotBlank` where appropriate

### Naming
- Classes: `PascalCase`
- Methods & variables: `camelCase`
- Constants: `UPPER_SNAKE_CASE`
- DB columns & XML params: `snake_case`
- Mapper XML file: same name as the interface (e.g. `UserMapper.xml`)

### Exception Handling
- Centralize with `@RestControllerAdvice` in `common/exception/GlobalExceptionHandler`
- Custom exceptions extend a base `BusinessException(ErrorCode, message)`
- Always return a consistent error response shape

## Build & Run Commands

```bash
# Gradle
./gradlew bootRun                        # Run with default profile
./gradlew bootRun --args='--spring.profiles.active=dev'
./gradlew build                          # Build JAR
./gradlew test                           # Run tests
./gradlew clean build -x test            # Build skip tests

# Maven (if applicable)
mvn spring-boot:run -Dspring-boot.run.profiles=dev
mvn clean package -DskipTests
```

## Profile Configuration

| Profile | Purpose |
|---------|---------|
| `local` | Local dev (H2 or local DB) |
| `dev`   | Development server |
| `prod`  | Production |

Active profile: `spring.profiles.active` in env or JVM arg.

## Database Notes

- **Greenplum specific**: No intermediate COMMITs inside PL/pgSQL functions
- **Sequences**: `ALTER SEQUENCE` can cause `tuple concurrently updated` under concurrency — use advisory locks or retry logic if needed
- **GIN indexes**: Statistics may go stale on large tables; run `ANALYZE` after bulk loads
- Batch updates: prefer keyset-based pagination over OFFSET for large tables
- Always check query plan with `EXPLAIN ANALYZE` before deploying heavy queries

## Important Rules

- Do NOT expose stack traces in API responses (handled by `GlobalExceptionHandler`)
- Do NOT put credentials in source code — use `application-{profile}.yml` + env vars
- Do NOT use `SELECT *` in mapper XML — list columns explicitly
- Do NOT call mapper directly from controller — always go through service
- `@Scheduled` tasks must be in a dedicated thread pool; never block the default scheduler thread
- Log at appropriate levels: `DEBUG` for SQL / detail, `INFO` for business events, `ERROR` for exceptions

## Compaction Instructions

When compacting, always preserve:
- Files modified in the current session and what changed
- Any DB schema decisions or migration notes
- Pending TODO items and their priority
- Any Greenplum / PostgreSQL query plan findings
