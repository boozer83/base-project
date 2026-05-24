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

CREATE TABLE IF NOT EXISTS menus (
    id         BIGSERIAL    PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    path       VARCHAR(255),
    parent_id  BIGINT REFERENCES menus (id),
    sort_order INTEGER      NOT NULL DEFAULT 0,
    roles      VARCHAR(50)  NOT NULL DEFAULT 'ALL',
    is_active  BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO menus (id, name, path, parent_id, sort_order, roles)
SELECT * FROM (VALUES
    (1, '홈',           '/',                        NULL, 1, 'ALL'),
    (2, '커뮤니티',     NULL,                        NULL, 2, 'ALL'),
    (3, '공지사항',     '/community/notice',         2,    1, 'ALL'),
    (4, '샘플',         '/sample',                   NULL, 3, 'USER'),
    (5, '관리',         NULL,                        NULL, 4, 'ADMIN'),
    (6, '공지사항 관리','/community/notice/write',   5,    1, 'ADMIN')
) AS v(id, name, path, parent_id, sort_order, roles)
WHERE NOT EXISTS (SELECT 1 FROM menus WHERE id = v.id);

SELECT setval('menus_id_seq', GREATEST((SELECT MAX(id) FROM menus), 1));
