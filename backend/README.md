# Backend

Spring Boot 3.3 + MyBatis + PostgreSQL

## 요구사항

- Java 21
- PostgreSQL 실행 중 (`localhost:5432`, DB: `postgres`, user: `postgres`, password: `admin`)

## 설정

`src/main/resources/application-local.yml`에 Google OAuth 정보 입력:

```yaml
spring:
  security:
    oauth2:
      client:
        registration:
          google:
            client-id: <Google Client ID>
            client-secret: <Google Client Secret>
```

Google Cloud Console → 사용자 인증 정보 → OAuth 2.0 클라이언트
승인된 리디렉션 URI: `http://localhost:8080/login/oauth2/code/google`

## DB 초기화

```bash
psql -U postgres -d postgres -f src/main/resources/schema.sql
```

## 실행

```bash
./gradlew bootRun
```

서버: `http://localhost:8080`
Swagger: `http://localhost:8080/swagger-ui/index.html`
