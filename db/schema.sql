-- ------------------------------------------------- --
--  Cloud Nine Café - Comunidad de Novelas Visuales  --
-- ------------------------------------------------- --
-- Version: 3.0.1
-- Date: 2025-02-03
-- ------------------------------------------------- --

-- ----- Notifications ----- --
CREATE TABLE notifications (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES emailpassword_users(user_id) ON DELETE CASCADE,
    message TEXT NOT NULL CHECK (LENGTH(message) <= 200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read BOOLEAN DEFAULT FALSE
);

-- ----- History ----- --
CREATE TYPE e_type AS ENUM('User', 'TLGroup', 'Post', 'Comment', 'Review');
CREATE TYPE e_type2 AS ENUM('Post', 'Comment', 'Review', 'TLGroup');
CREATE TYPE e_type3 AS ENUM('Post', 'TLGroup');

CREATE TABLE change_history (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    entity_type e_type NOT NULL,
    entity_id INT NOT NULL, -- Affected Entity ID
    field_changed VARCHAR(255) NOT NULL,
    old_value TEXT CHECK (LENGTH(old_value) <= 500),
    new_value TEXT CHECK (LENGTH(new_value) <= 500),
    changed_by UUID REFERENCES emailpassword_users(user_id) ON DELETE SET NULL,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE report_history (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    entity_type e_type NOT NULL,
    entity_id INT NOT NULL,
    reporter_id UUID NOT NULL REFERENCES emailpassword_users(user_id) ON DELETE CASCADE,
    reason TEXT NOT NULL CHECK (LENGTH(reason) <= 250),
    report_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ----- Flags ----- --
CREATE TABLE entity_flags (
    entity_type e_type2 NOT NULL,
    entity_id INT NOT NULL,
    hidden BOOLEAN NOT NULL DEFAULT FALSE,
    locked BOOLEAN NOT NULL DEFAULT FALSE,
    reports SMALLINT NOT NULL DEFAULT 0 CHECK (reports >= 0),
    PRIMARY KEY (entity_type, entity_id)
);

-- ----- Aliases ----- --
CREATE TYPE aliases_action AS ENUM('Añadido', 'Editado', 'Eliminado');

CREATE TABLE aliases (
    entity_type e_type3 NOT NULL,
    entity_id INT NOT NULL,
    alias VARCHAR(100) NOT NULL,
    PRIMARY KEY (entity_type, entity_id, alias)
);

CREATE TABLE aliases_history (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    entity_type e_type3 NOT NULL,
    entity_id INT NOT NULL,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action_type aliases_action NOT NULL,
    old_alias VARCHAR(100),
    new_alias VARCHAR(100)
);

-- ----- Users ----- --
CREATE TYPE user_status AS ENUM('Activo', 'Desactivado', 'Muteado', 'Baneado');

CREATE TABLE user_profiles (
    user_id UUID PRIMARY KEY REFERENCES emailpassword_users(user_id) ON DELETE CASCADE,
    username VARCHAR(50) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    avatar VARCHAR(255) NOT NULL CHECK (avatar LIKE 'https://%'),
    status user_status NOT NULL DEFAULT 'Activo',
    registered TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_preferences (
    user_id UUID PRIMARY KEY REFERENCES emailpassword_users(user_id) ON DELETE CASCADE,
    bio TEXT CHECK (LENGTH(bio) <= 250),
    bio_hidden BOOLEAN NOT NULL DEFAULT FALSE,
    twitter VARCHAR(16),
    twitter_hidden BOOLEAN NOT NULL DEFAULT FALSE,
    discord VARCHAR(14),
    discord_hidden BOOLEAN NOT NULL DEFAULT FALSE,
    web_skin SMALLINT NOT NULL DEFAULT 1,
    CHECK (twitter IS NULL OR twitter LIKE '@%'),
    CHECK (discord IS NULL OR discord LIKE '.gg/%')
);

-- ----- Users' Social Logins ----- --
CREATE TABLE user_social_logins (
  user_id UUID REFERENCES emailpassword_users(user_id) ON DELETE CASCADE,
  provider VARCHAR(20) NOT NULL, -- 'discord', 'google', 'facebook'
  provider_user_id VARCHAR(255) NOT NULL,
  PRIMARY KEY (user_id, provider)
);

-- ----- Users' Roles ----- --
CREATE TABLE roles (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    role_name VARCHAR(255) NOT NULL
);

CREATE TABLE user_role (
    user_id UUID NOT NULL REFERENCES emailpassword_users(user_id) ON DELETE CASCADE,
    role_id INT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

-- ----- Users' Sessions ----- --
CREATE TABLE user_sessions (
  user_id UUID REFERENCES emailpassword_users(user_id) ON DELETE CASCADE,
  session_handle VARCHAR(255) PRIMARY KEY,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ----- Users' History ----- --
CREATE TYPE mod_action AS ENUM('Ban', 'Mute');

CREATE TABLE users_password_hist (
    user_id UUID PRIMARY KEY REFERENCES emailpassword_users(user_id) ON DELETE CASCADE,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users_moderation_logs (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES emailpassword_users(user_id) ON DELETE CASCADE,
    mod_id UUID NOT NULL REFERENCES emailpassword_users(user_id) ON DELETE CASCADE,
    action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action mod_action NOT NULL,
    reason TEXT NOT NULL CHECK (LENGTH(reason) <= 250),
    until TIMESTAMP NULL
);

-- ----- Web Skins ----- --
CREATE TABLE web_skins (
    id SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    skin_name VARCHAR(30) NOT NULL,
    primary_color VARCHAR(7) NOT NULL CHECK (primary_color LIKE '#%'),
    secondary_color VARCHAR(7) NOT NULL CHECK (secondary_color LIKE '#%'),
    accent_color VARCHAR(7) NOT NULL CHECK (accent_color LIKE '#%'),
    background_color VARCHAR(7) NOT NULL CHECK (background_color LIKE '#%'),
    text_color VARCHAR(7) NOT NULL CHECK (text_color LIKE '#%')
);

-- ----- TL Groups ----- --
CREATE TYPE group_status AS ENUM('Activo', 'Q.E.P.D');
CREATE TYPE group_role AS ENUM('Dueño/a', 'Editor/a de imágenes', 'Corrector/a', 'Traductor/a', 'Programador/a');

CREATE TABLE tl_groups (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    owner_id UUID NOT NULL REFERENCES emailpassword_users(user_id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    latin_name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL CHECK (LENGTH(description) <= 500),
    status group_status NOT NULL DEFAULT 'Activo'
);

CREATE TABLE tl_groups_metadata (
    group_id INT PRIMARY KEY REFERENCES tl_groups(id) ON DELETE CASCADE,
    facebook VARCHAR(50),
    twitter VARCHAR(16),
    discord VARCHAR(14),
    website VARCHAR(255),
    language_1 VARCHAR(2) NOT NULL REFERENCES languages(lang_code),
    language_2 VARCHAR(2) REFERENCES languages(lang_code),
    language_3 VARCHAR(2) REFERENCES languages(lang_code),
    CHECK (
        (facebook IS NULL OR facebook LIKE '/%') AND
        (twitter IS NULL OR twitter LIKE '@%') AND
        (discord IS NULL OR discord LIKE '.gg/%') AND
        (website IS NULL OR website LIKE 'http%')
    ),
    CHECK (language_1 IS DISTINCT FROM language_2 AND language_1 IS DISTINCT FROM language_3 AND language_2 IS DISTINCT FROM language_3)
);

CREATE TABLE tl_groups_members (
    group_id INT NOT NULL REFERENCES tl_groups(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES emailpassword_users(user_id) ON DELETE CASCADE,
    member_name VARCHAR(50),
    member_role group_role NOT NULL DEFAULT 'Traductor/a',
    PRIMARY KEY (group_id, user_id)
);

CREATE TABLE tl_groups_updates (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    group_id INT NOT NULL REFERENCES tl_groups(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES emailpassword_users(user_id) ON DELETE CASCADE,
    post_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    content TEXT NOT NULL CHECK (LENGTH(content) <= 1024),
    hidden BOOLEAN NOT NULL DEFAULT FALSE,
    locked BOOLEAN NOT NULL DEFAULT FALSE
);

-- ----- TL Groups' History ----- --
CREATE TYPE member_action AS ENUM('Añadido', 'Editado', 'Eliminado');

CREATE TABLE tl_groups_members_hist (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    group_id INT NOT NULL REFERENCES tl_groups(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES emailpassword_users(user_id) ON DELETE CASCADE,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action member_action NOT NULL,
    member_id INT,
    member_name VARCHAR(50),
    role group_role
);

CREATE TABLE tl_groups_updates_hist (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    update_id INT NOT NULL REFERENCES tl_groups_updates(id) ON DELETE CASCADE,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_content TEXT NOT NULL CHECK (LENGTH(old_content) <= 1024),
    new_content TEXT NOT NULL CHECK (LENGTH(new_content) <= 1024),
    hidden BOOLEAN,
    locked BOOLEAN
);

CREATE TABLE tl_groups_moderation_logs (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    group_id INT NOT NULL REFERENCES tl_groups(id) ON DELETE CASCADE,
    mod_id UUID NOT NULL REFERENCES emailpassword_users(user_id) ON DELETE CASCADE,
    action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT NOT NULL CHECK (LENGTH(reason) <= 250),
    locked BOOLEAN NOT NULL,
    hidden BOOLEAN NOT NULL
);

-- ----- Languages ----- --
CREATE TABLE languages (
    lang_code VARCHAR(2) PRIMARY KEY,
    lang_name VARCHAR(50) NOT NULL
);

-- ----- Posts ----- --
CREATE TYPE post_classification AS ENUM('All ages', '13+', '16+', '18+');
CREATE TYPE post_tl_type AS ENUM('Manual', 'MTL', 'MTL editado');
CREATE TYPE post_status AS ENUM('En progreso', 'Completada', 'Pausada', 'Cancelada');
CREATE TYPE post_tl_scope AS ENUM('Completa', 'Parcial');
CREATE TYPE post_tl_platform AS ENUM('PC', 'Android', 'Otros');
CREATE TYPE post_section AS ENUM('Traduciendo', 'Corrigiendo', 'Editando imágenes', 'Reinsertando', 'Testeando');

CREATE TABLE posts (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    op_id UUID NOT NULL REFERENCES emailpassword_users(user_id) ON DELETE CASCADE,
    publish_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    original_lang VARCHAR(2) NOT NULL REFERENCES languages(lang_code),
    translated_from VARCHAR(2) NOT NULL REFERENCES languages(lang_code),
    cover_image VARCHAR(255) NOT NULL CHECK (cover_image LIKE 'https://%'),
    title VARCHAR(100) UNIQUE NOT NULL,
    download_link VARCHAR(255) NOT NULL CHECK (download_link LIKE 'https://%'),
    download_note TEXT CHECK (LENGTH(download_note) <= 500)
);

CREATE TABLE posts_details (
    post_id INT PRIMARY KEY REFERENCES posts(id) ON DELETE CASCADE,
    sinopsis TEXT NOT NULL CHECK (LENGTH(sinopsis) <= 500) DEFAULT 'Esta novela aún no tiene una sinopsis.',
    game_length SMALLINT REFERENCES game_length(id),
    length_value NUMERIC(4, 1) CHECK (length_value >= 0),
    classification post_classification NOT NULL,
    tl_type post_tl_type NOT NULL,
    tl_status post_status NOT NULL,
    tl_scope post_tl_scope NOT NULL,
    tl_platform post_tl_platform NOT NULL,
    buy_links JSONB
);

CREATE TABLE posts_tl_progress (
    post_id INT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    tl_percentage SMALLINT NOT NULL CHECK (tl_percentage BETWEEN 0 AND 100),
    tl_section post_section NOT NULL
);

-- ----- Visual Novels Length ----- --
-- Range of values
-- null = "Desconocido"
-- >0 - 1.9 = "Muy corto" (Menos de 2 horas)
-- 2 - 9.9 = "Corto" (Entre 2 y 10 horas)
-- 10 - 29.9 = "Medio" (Entre 10 y 30 horas)
-- 30 - 49.9 = "Largo" (Entre 30 y 50 horas)
-- 50 - 999.9 (a big value) = "Muy largo" (Más de 50 horas)
CREATE TABLE game_length (
    id SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    min_hours NUMERIC(4, 1) CHECK (min_hours >= 0), -- Minimum hours for the range
    max_hours NUMERIC(4, 1) CHECK (max_hours > min_hours OR max_hours IS NULL), -- Maximum hours for the range (NULL for "Unknown")
    length_label VARCHAR(50) NOT NULL -- Label for the range
);

-- Insert the predefined ranges and labels
INSERT INTO game_length (min_hours, max_hours, length_label)
VALUES
    (NULL, NULL, 'Desconocido'), -- Unknown length
    (0, 1.9, 'Muy corto'), -- Very short (Less than 2 hours)
    (2, 9.9, 'Corto'), -- Short (Between 2 and 10 hours)
    (10, 29.9, 'Medio'), -- Medium (Between 10 and 30 hours)
    (30, 49.9, 'Largo'), -- Long (Between 30 and 50 hours)
    (50, 999.9, 'Muy largo'); -- Very long (More than 50 hours)

-- ----- Comments ----- --
CREATE TYPE comment_vote AS ENUM('Up', 'Down');

CREATE TABLE comments (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    parent_id INT REFERENCES comments(id) ON DELETE CASCADE,
    post_id INT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES emailpassword_users(user_id) ON DELETE CASCADE,
    content TEXT NOT NULL CHECK (LENGTH(content) <= 250),
    votes INT NOT NULL DEFAULT 0,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE comments_votes (
    comment_id INT NOT NULL REFERENCES comments(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES emailpassword_users(user_id) ON DELETE CASCADE,
    vote comment_vote NOT NULL,
    PRIMARY KEY (comment_id, user_id)
);

-- ----- Comments' History ----- --
CREATE TABLE comments_moderation_logs (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    comment_id INT NOT NULL REFERENCES comments(id) ON DELETE CASCADE,
    mod_id UUID NOT NULL REFERENCES emailpassword_users(user_id) ON DELETE CASCADE,
    action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT NOT NULL CHECK (LENGTH(reason) <= 250),
    hidden BOOLEAN NOT NULL,
    locked BOOLEAN NOT NULL
);

-- ----- Reviews ----- --
CREATE TABLE reviews (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    post_id INT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES emailpassword_users(user_id) ON DELETE CASCADE,
    content TEXT NOT NULL CHECK (LENGTH(content) <= 1024),
    rating SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    votes INT NOT NULL DEFAULT 0,
    attachments JSONB,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE reviews_votes (
    review_id INT NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES emailpassword_users(user_id) ON DELETE CASCADE,
    vote comment_vote NOT NULL,
    PRIMARY KEY (review_id, user_id)
);

-- ----- Reviews' History ----- --
CREATE TYPE attachment_action AS ENUM('Añadido', 'Eliminado');

CREATE TABLE reviews_attachments_hist (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    review_id INT NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action attachment_action NOT NULL,
    attachment VARCHAR(255) NOT NULL CHECK (attachment LIKE 'https://%')
);

CREATE TABLE reviews_moderation_logs (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    review_id INT NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
    mod_id UUID NOT NULL REFERENCES emailpassword_users(user_id) ON DELETE CASCADE,
    action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT NOT NULL CHECK (LENGTH(reason) <= 250),
    hidden BOOLEAN NOT NULL,
    locked BOOLEAN NOT NULL
);

-- ----------------- --
-- ---- Indexes ---- --
-- ----------------- --

CREATE INDEX idx_entity_flags_reports ON entity_flags (reports);
CREATE INDEX idx_comments_post_id ON comments (post_id);
CREATE INDEX idx_comments_parent_id ON comments (parent_id);
CREATE INDEX idx_aliases_alias ON aliases (alias);
CREATE INDEX idx_notifications_user_id ON notifications (user_id);
CREATE INDEX idx_change_history_entity_id ON change_history (entity_id);
CREATE INDEX idx_posts_details_post_id ON posts_details (post_id);
CREATE INDEX idx_tl_groups_members_group_id ON tl_groups_members (group_id);

-- -------------------------------- --
-- ----- Functions & Triggers ----- --
-- -------------------------------- --

-- ----- Get the correspondent label for the length of a Visual Novel ----- --
CREATE OR REPLACE FUNCTION get_length_label(length_value NUMERIC(4, 1))
RETURNS VARCHAR(50) AS $$
DECLARE
    label VARCHAR(50);
BEGIN
    -- Handle the "unknown" case
    IF length_value IS NULL THEN
        RETURN 'Desconocido';
    END IF;

    -- Find the corresponding label for the length_value
    SELECT length_label INTO label
    FROM game_length
    WHERE (min_hours IS NULL OR length_value >= min_hours)
      AND (max_hours IS NULL OR length_value <= max_hours)
    LIMIT 1;

    RETURN label;
END;
$$ LANGUAGE plpgsql;

-- ----- Too lazy to make it inside the table itself, so it goes here. ----- --
ALTER TABLE posts_details
ADD COLUMN formatted_length TEXT GENERATED ALWAYS AS (
    CASE
        WHEN length_value IS NULL THEN 'Desconocido'
        ELSE get_length_label(length_value) || ' (' || length_value::TEXT || 'hs)'
    END
) STORED;

-- ----- Notify the user when a comment they're responding to doesn't exist ----- --
CREATE OR REPLACE FUNCTION validate_parent_comment()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.parent_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM comments WHERE id = NEW.parent_id
    ) THEN
        RAISE EXCEPTION 'El comentario al que intentas responder no existe.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_parent_comment
BEFORE INSERT ON comments
FOR EACH ROW
EXECUTE FUNCTION validate_parent_comment();

-- ----- Verify post aliases ----- --
CREATE OR REPLACE FUNCTION validate_post_aliases()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM posts p
        LEFT JOIN aliases pa ON pa.alias = NEW.alias
        WHERE p.title = NEW.alias OR (pa.alias = NEW.alias AND pa.entity_id != NEW.entity_id)
    ) THEN
        RAISE EXCEPTION 'El alias ya está siendo usado.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_post_aliases
BEFORE INSERT ON aliases
FOR EACH ROW
EXECUTE FUNCTION validate_post_aliases();

-- ----- Report notifications ----- --
CREATE OR REPLACE FUNCTION notify_reports(entity_id INT)
RETURNS VOID AS $$
DECLARE
    role_ids INT[];
    users_to_notify RECORD;
BEGIN
    SELECT ARRAY(SELECT id FROM roles WHERE role_name IN ('Dueño/a', 'Administrador/a', 'Moderador/a'))
    INTO role_ids;

    FOR users_to_notify IN 
        SELECT DISTINCT ur.user_id
        FROM users_role ur
        WHERE ur.role_id = ANY(role_ids)
    LOOP
        IF NOT EXISTS (
            SELECT 1 
            FROM notifications
            WHERE user_id = users_to_notify.user_id
              AND message = 'Un usuario ha alcanzado 5 reportes. Entidad ID: ' || entity_id
        ) THEN
            INSERT INTO notifications (user_id, message)
            VALUES (
                users_to_notify.user_id,
                'Un usuario ha alcanzado 5 reportes. Entidad ID: ' || entity_id
            );
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_and_notify_reports()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.reports = 5 THEN
        PERFORM notify_reports(NEW.entity_id);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER notify_on_five_reports
AFTER UPDATE OF reports ON entity_flags
FOR EACH ROW
WHEN (NEW.reports = 5)
EXECUTE FUNCTION check_and_notify_reports();

-- ----- Prevent comments from having themselves as parents ----- --
ALTER TABLE comments
ADD CONSTRAINT check_parent_not_self
CHECK (parent_id IS NULL OR parent_id != id);

-- ----- Check user username and email ----- --
ALTER TABLE users_profile
ADD CONSTRAINT chk_username_format CHECK (username ~* '^[a-zA-Z0-9._-]+$');
