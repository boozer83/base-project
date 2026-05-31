CREATE TABLE IF NOT EXISTS users (
    id         BIGSERIAL PRIMARY KEY,
    google_id  VARCHAR(255) UNIQUE,
    email      VARCHAR(255) UNIQUE NOT NULL,
    name       VARCHAR(255),
    picture    VARCHAR(500),
    created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS roles (
    id          VARCHAR(50)  PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    description VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS permissions (
    id          VARCHAR(100) PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    description VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS role_permission (
    role_id       VARCHAR(50)  NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permission_id VARCHAR(100) NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE IF NOT EXISTS role_user (
    user_id BIGINT      NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id VARCHAR(50) NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
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
    permission VARCHAR(100),
    is_active  BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Seed: roles
INSERT INTO roles (id, name, description)
SELECT * FROM (VALUES
    ('ROLE_USER',  'Role User',  '일반 사용자'),
    ('ROLE_ADMIN', 'Role Admin', '관리자')
) AS v(id, name, description)
WHERE NOT EXISTS (SELECT 1 FROM roles WHERE id = v.id);

-- Seed: permissions
INSERT INTO permissions (id, name, description)
SELECT * FROM (VALUES
    ('NOTICE_WRITE',  'Notice Write',  '공지사항 작성/수정/삭제'),
    ('SAMPLE_ACCESS', 'Sample Access', '샘플 페이지 접근'),
    ('ADMIN_ACCESS',  'Admin Access',  '관리 메뉴 접근')
) AS v(id, name, description)
WHERE NOT EXISTS (SELECT 1 FROM permissions WHERE id = v.id);

-- Seed: role_permission
--   ROLE_USER  → SAMPLE_ACCESS
--   ROLE_ADMIN → NOTICE_WRITE, SAMPLE_ACCESS, ADMIN_ACCESS
INSERT INTO role_permission (role_id, permission_id)
SELECT * FROM (VALUES
    ('ROLE_USER',  'SAMPLE_ACCESS'),
    ('ROLE_ADMIN', 'NOTICE_WRITE'),
    ('ROLE_ADMIN', 'SAMPLE_ACCESS'),
    ('ROLE_ADMIN', 'ADMIN_ACCESS')
) AS v(role_id, permission_id)
WHERE NOT EXISTS (
    SELECT 1 FROM role_permission WHERE role_id = v.role_id AND permission_id = v.permission_id
);

-- Seed: menus (permission = NULL means visible to all)
INSERT INTO menus (id, name, path, parent_id, sort_order, permission)
SELECT * FROM (VALUES
    (1, '홈',           '/',                       NULL::BIGINT, 1, NULL::VARCHAR),
    (2, '커뮤니티',     NULL,                       NULL,         2, NULL),
    (3, '공지사항',     '/community/notice',        2,            1, NULL),
    (4, '샘플',         '/sample',                  NULL,         3, 'SAMPLE_ACCESS'),
    (5, '관리',         NULL,                       NULL,         4, 'ADMIN_ACCESS'),
    (6, '공지사항 관리','/community/notice/write',  5,            1, 'NOTICE_WRITE')
) AS v(id, name, path, parent_id, sort_order, permission)
WHERE NOT EXISTS (SELECT 1 FROM menus WHERE id = v.id);
SELECT setval('menus_id_seq', GREATEST((SELECT MAX(id) FROM menus), 1));
