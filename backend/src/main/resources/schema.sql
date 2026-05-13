CREATE TABLE IF NOT EXISTS users (
    id         BIGSERIAL PRIMARY KEY,
    google_id  VARCHAR(255) UNIQUE,
    email      VARCHAR(255) UNIQUE NOT NULL,
    name       VARCHAR(255),
    picture    VARCHAR(500),
    role       VARCHAR(50)  NOT NULL DEFAULT 'USER',
    created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS notices (
    id          BIGSERIAL PRIMARY KEY,
    title       VARCHAR(500) NOT NULL,
    content     TEXT         NOT NULL,
    author_id   BIGINT REFERENCES users (id),
    author_name VARCHAR(255),
    is_pinned   BOOLEAN      NOT NULL DEFAULT FALSE,
    view_count  INTEGER      NOT NULL DEFAULT 0,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);
