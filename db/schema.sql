-- ------------------------------------------------- --
--  Cloud Nine Café - Comunidad de Novelas Visuales  --
-- ------------------------------------------------- --
-- Version: 2.2.0
-- Date: 2024-11-29
-- ------------------------------------------------- --
-- Changelog 2.2.0:
-- - Changed the "users_sessions" table to match JWT usage.
--
-- Changelog 2.1.2:
-- - Missing data type for notifications(id) fixed.
-- - Deleted a function that was not needed.
--
-- Changelog 2.1.1:
-- - Changed all SERIAL columns to GENERATED ALWAYS AS IDENTITY.
-- - Fixed default boolean values being set to 0 instead of FALSE.
--
-- Changelog 2.1.0:
-- - Added the "aliases" and "aliases_history" tables to store aliases for Posts and Groups and their histories.
-- - Removed the "last_login" column from the "users" table since I never added it in the first place.
-- - Fixed some enum values that had wrong names.


-- ----- Notifications ----- --
CREATE TABLE notifications (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INT NOT NULL,
    message TEXT NOT NULL CHECK (LENGTH(message) <= 200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read BOOLEAN DEFAULT FALSE
);

-- ----- History ----- --
-- Most previously made history tables have been replaced by these ones to make management more efficient.

-- Entity types
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
    changed_by INT, -- ID of the user who made the change
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE report_history (
    entity_type e_type NOT NULL,
    entity_id INT NOT NULL,
    reporter_id INT NOT NULL,
    reason TEXT NOT NULL CHECK (LENGTH(reason) <= 250),
    report_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ----- Flags ----- --
-- As I mentioned before, most of the hidden_data tables have been replaced by this one.
CREATE TABLE entity_flags (
    entity_type e_type2 NOT NULL,
    entity_id INT NOT NULL,
    hidden BOOLEAN NOT NULL DEFAULT FALSE,
    locked BOOLEAN NOT NULL DEFAULT FALSE,
    reports SMALLINT NOT NULL DEFAULT 0 CHECK (reports >= 0),
    PRIMARY KEY (entity_type, entity_id)
);

-- ----- Aliases ----- --
-- Made to store post and group aliases instead of having them as columns in the metadata or details of the entities.
CREATE TYPE aliases_action AS ENUM('Añadido', 'Editado', 'Eliminado');

CREATE TABLE aliases (
    entity_type e_type3 NOT NULL,
    entity_id INT NOT NULL,
    alias VARCHAR(100) NOT NULL,
    PRIMARY KEY (entity_type, entity_id, alias)
);

CREATE TABLE aliases_history (
    entity_type e_type3 NOT NULL,
    entity_id INT NOT NULL,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action_type aliases_action NOT NULL,
    old_alias VARCHAR(100),
    new_alias VARCHAR(100)
);

-- ----- Users ----- --

CREATE TYPE user_status AS ENUM('Activo', 'Desactivado', 'Muteado', 'Baneado');

CREATE TABLE users (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    email VARCHAR(128) UNIQUE NOT NULL,
    is_email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    avatar VARCHAR(255) NOT NULL,
    status user_status NOT NULL DEFAULT 'Activo',
    password TEXT NOT NULL, -- This will be obviously hashed and salted, so if you're going to try and hack this, good luck!
    registered TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users_preferences (
    user_id INT PRIMARY KEY,
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

CREATE TABLE users_role (
    user_id INT NOT NULL,
    role_id INT NOT NULL
);

-- ----- Users' history ----- --

CREATE TYPE mod_action AS ENUM('Ban', 'Mute');

CREATE TABLE users_password_hist (
    user_id INT NOT NULL,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users_moderation_logs (
    user_id INT NOT NULL,
    mod_id INT NOT NULL,
    action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action mod_action NOT NULL,
    reason TEXT NOT NULL CHECK (LENGTH(reason) <= 250),
    until TIMESTAMP NULL
);

-- ----- Sessions ----- --
-- How did I even forget this until now?

CREATE TABLE user_sessions (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INT NOT NULL,
    refresh_token TEXT NOT NULL,
    expires TIMESTAMP NULL,
    version_number INT NOT NULL
);


-- ----- Web Skins ----- --

CREATE TABLE web_skins (
    id SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    skin_name VARCHAR(30) NOT NULL,
    primary_color VARCHAR(7) NOT NULL,
    secondary_color VARCHAR(7) NOT NULL,
    accent_color VARCHAR(7) NOT NULL,
    background_color VARCHAR(7) NOT NULL,
    text_color VARCHAR(7) NOT NULL,
    CHECK (primary_color LIKE '#%'),
    CHECK (secondary_color LIKE '#%'),
    CHECK (accent_color LIKE '#%'),
    CHECK (background_color LIKE '#%'),
    CHECK (text_color LIKE '#%')
);

-- ----- Roles ----- --

CREATE TABLE roles (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    role_name VARCHAR(255) NOT NULL
);

CREATE TABLE roles_perms (
    role_id INT NOT NULL,
    perm_id INT NOT NULL
);

-- ----- Permissions ----- --
--
-- Want to know more about the permissions? Check out PERMS.md
--

CREATE TABLE perms (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    perm_name VARCHAR(255) NOT NULL
);

-- ----- TL Groups ----- --

CREATE TYPE group_status AS ENUM('Activo', 'Q.E.P.D');
CREATE TYPE group_role AS ENUM('Dueño/a', 'Editor/a de imágenes', 'Corrector/a', 'Traductor/a', 'Programador/a');

CREATE TABLE tl_groups (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    owner_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    latin_name VARCHAR(100) NOT NULL, -- In case the name uses non-latin characters, This will be the "main name".
    description TEXT NOT NULL CHECK (LENGTH(description) <= 500),
    status group_status NOT NULL DEFAULT 'Activo'
);

CREATE TABLE translations (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    post_id INT NOT NULL,
    group_id INT NOT NULL
);

CREATE TABLE tl_groups_metadata (
    group_id INT PRIMARY KEY,
    facebook VARCHAR(50),
    twitter VARCHAR(16),
    discord VARCHAR(14),
    website VARCHAR(255),
    language_1 VARCHAR(2) NOT NULL,
    language_2 VARCHAR(2),
    language_3 VARCHAR(2),
    CHECK (
        (facebook IS NULL OR facebook LIKE '/%') AND
        (twitter IS NULL OR twitter LIKE '@%') AND
        (discord IS NULL OR discord LIKE '.gg/%') AND
        (website IS NULL OR website LIKE 'http%')
    ),
    CHECK (language_1 IS DISTINCT FROM language_2 AND language_1 IS DISTINCT FROM language_3 AND language_2 IS DISTINCT FROM language_3)
);

CREATE TABLE tl_groups_members (
    group_id INT NOT NULL,
    user_id INT,
    member_name VARCHAR(50), -- In case the member isn't registered
    member_role group_role NOT NULL DEFAULT 'Traductor/a'
);

CREATE TABLE tl_groups_updates (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    group_id INT NOT NULL,
    user_id INT NOT NULL,
    post_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    content TEXT NOT NULL CHECK (LENGTH(content) <= 1024),
    hidden BOOLEAN NOT NULL DEFAULT FALSE,
    locked BOOLEAN NOT NULL DEFAULT FALSE
);

-- ----- Translation Groups' History ----- --

CREATE TYPE member_action AS ENUM('Añadido', 'Editado', 'Eliminado');

CREATE TABLE tl_groups_members_hist (
    group_id INT NOT NULL,
    user_id INT NOT NULL,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action member_action NOT NULL,
    member_id INT,
    member_name VARCHAR(50), -- In case the member is not registered
    role group_role
);

CREATE TABLE tl_groups_updates_hist (
    update_id INT NOT NULL,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_content TEXT NOT NULL CHECK (LENGTH(old_content) <= 1024),
    new_content TEXT NOT NULL CHECK (LENGTH(new_content) <= 1024),
    hidden BOOLEAN,
    locked BOOLEAN
);

CREATE TABLE tl_groups_moderation_logs (
    group_id INT NOT NULL,
    mod_id INT NOT NULL,
    action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT NOT NULL CHECK (LENGTH(reason) <= 250),
    locked BOOLEAN NOT NULL,
    hidden BOOLEAN NOT NULL
);

-- ----- Languages ----- --

CREATE TABLE languages (
    lang_code VARCHAR(2) NOT NULL PRIMARY KEY,
    lang_name VARCHAR(50) NOT NULL
);

-- ----- Posts ----- --
--
-- I stressed an awful lot while thinking about this part in the beginning.
-- You've been warned, I'm not joking.
--

CREATE TYPE post_classification AS ENUM('All ages', '13+', '16+', '18+');
CREATE TYPE post_tl_type AS ENUM('Manual', 'MTL', 'MTL editado');
CREATE TYPE post_status AS ENUM('En progreso', 'Completada', 'Pausada', 'Cancelada');
CREATE TYPE post_tl_scope AS ENUM('Completa', 'Parcial');
CREATE TYPE post_tl_platform AS ENUM('PC', 'Android', 'Otros');
CREATE TYPE post_section AS ENUM('Traduciendo', 'Corrigiendo', 'Editando imágenes', 'Reinsertando', 'Testeando');

CREATE TABLE posts (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    op_id INT NOT NULL,
    publish_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    original_lang VARCHAR(2) NOT NULL,
    translated_from VARCHAR(2) NOT NULL,
    cover_image VARCHAR(255) NOT NULL CHECK (cover_image LIKE 'https://...'),
    title VARCHAR(100) UNIQUE NOT NULL,
    download_link VARCHAR(255) NOT NULL CHECK (download_link LIKE 'https://...'), -- Link to download the translation
    download_note TEXT CHECK (LENGTH(download_note) <= 500) -- Note about the download link
);

CREATE TABLE posts_details (
    post_id INT NOT NULL,
    sinopsis TEXT NOT NULL CHECK (LENGTH(sinopsis) <= 500) DEFAULT 'Esta novela aún no tiene una sinopsis.',
    game_length SMALLINT,
    classification post_classification NOT NULL,
    tl_type post_tl_type NOT NULL,
    tl_status post_status NOT NULL,
    tl_scope post_tl_scope NOT NULL,
    tl_platform post_tl_platform NOT NULL,
    buy_links JSONB -- [{"plataform": "Steam", "link": "https://..."}]
);

CREATE TABLE posts_tl_progress (
    post_id INT NOT NULL,
    tl_percentage SMALLINT NOT NULL CHECK (tl_percentage BETWEEN 0 AND 100),
    tl_section post_section NOT NULL
);

-- ----- Posts' history ----- --
-- This part has been now replaced by the change_history table.

-- ----- Posts' length ----- --

CREATE TABLE game_length ( -- For now, it's 1 - 5. 1 = Very short (Less than 2 hours), 5 = Very long (More than 50 hours)
    -- 1 = "Muy corto" (Menos de 2 horas)
    -- 2 = "Corto" (Entre 2 y 10 horas)
    -- 3 = "Medio" (Entre 10 y 30 horas)
    -- 4 = "Largo" (Entre 30 y 50 horas)
    -- 5 = "Muy largo" (Más de 50 horas)
    id SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    length_name VARCHAR(255) NOT NULL
);

-- ----- Comments ----- --

CREATE TYPE comment_vote AS ENUM('Up', 'Down');

CREATE TABLE comments (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    parent_id INT,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL CHECK (LENGTH(content) <= 250),
    votes INT NOT NULL DEFAULT 0,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE comments_votes (
    comment_id INT NOT NULL,
    user_id INT NOT NULL,
    vote comment_vote NOT NULL,
    PRIMARY KEY(comment_id, user_id)
);

-- ----- Comments' history ----- --

CREATE TABLE comments_moderation_logs (
    comment_id INT NOT NULL,
    mod_id INT NOT NULL,
    action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT NOT NULL CHECK (LENGTH(reason) <= 250),
    hidden BOOLEAN NOT NULL,
    locked BOOLEAN NOT NULL
);

-- ----- Reviews ----- --

CREATE TABLE reviews (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL CHECK (LENGTH(content) <= 1024),
    rating SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5), -- 1 = "Utter bullsh*t" to 5 = "HOLY SH*T THIS IS AMAZING"
    votes INT NOT NULL DEFAULT 0,
    attachments JSONB, -- ["https://...", "https://..."]
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE reviews_votes (
    review_id INT NOT NULL,
    user_id INT NOT NULL,
    vote comment_vote NOT NULL
);

-- ----- Reviews' history ----- --

CREATE TYPE attachment_action AS ENUM('Añadido', 'Eliminado');

CREATE TABLE reviews_attachments_hist (
    review_id INT NOT NULL,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action attachment_action NOT NULL,
    attachment VARCHAR(255) NOT NULL CHECK (attachment LIKE 'https://...')
);

CREATE TABLE reviews_moderation_logs (
    review_id INT NOT NULL,
    mod_id INT NOT NULL,
    action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT NOT NULL CHECK (LENGTH(reason) <= 250),
    hidden BOOLEAN NOT NULL,
    locked BOOLEAN NOT NULL
);

-- ----------------- --
--      Indexes      --
-- ----------------- --
--
-- To make searches faster.
-- 

CREATE INDEX idx_entity_flags_reports ON entity_flags (reports);
CREATE INDEX idx_comments_post_id ON comments (post_id);
CREATE INDEX idx_comments_parent_id ON comments (parent_id);
CREATE INDEX idx_aliases_alias ON aliases (alias);


-- ----------------- --
--  Extra functions  --
-- ----------------- --
--
-- Because we need them, after all.
--

-- ----- History ----- --
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
        LEFT JOIN posts_aliases pa ON pa.alias = NEW.alias
        WHERE p.title = NEW.alias OR (pa.alias = NEW.alias AND pa.post_id != NEW.post_id)
    ) THEN
        RAISE EXCEPTION 'El alias ya está siendo usado.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_post_aliases
BEFORE INSERT ON posts_aliases
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
ALTER TABLE users
ADD CONSTRAINT chk_username_format CHECK (username ~* '^[a-zA-Z0-9._-]+$');
ALTER TABLE users
ADD CONSTRAINT chk_email_format CHECK (email ~* '^[^@]+@[^@]+\.[^@]+$');


-- ----------------- --
--   Foreign Keys    --
-- ----------------- --
--
-- Why, PHPMyAdmin? Why do you make me do this?
--

-- ----- Notifications ----- --
ALTER TABLE notifications ADD FOREIGN KEY (user_id) REFERENCES users(id);

-- ----- History ----- --
ALTER TABLE change_history ADD FOREIGN KEY (changed_by) REFERENCES users(id);

ALTER TABLE report_history ADD FOREIGN KEY (reporter_id) REFERENCES users(id);

-- ----- Users ----- --
ALTER TABLE users_role ADD FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE users_role ADD FOREIGN KEY (role_id) REFERENCES roles(id);

-- ----- User History ----- --
ALTER TABLE users_password_hist ADD FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE users_moderation_logs ADD FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE users_moderation_logs ADD FOREIGN KEY (mod_id) REFERENCES users(id);

-- ----- Sessions ----- --
ALTER TABLE user_sessions ADD FOREIGN KEY (user_id) REFERENCES users(id);

-- ----- Roles ----- --
ALTER TABLE roles_perms ADD FOREIGN KEY (role_id) REFERENCES roles(id);
ALTER TABLE roles_perms ADD FOREIGN KEY (perm_id) REFERENCES perms(id);

-- ----- TL Groups ----- --
ALTER TABLE tl_groups ADD FOREIGN KEY (owner_id) REFERENCES users(id);

ALTER TABLE tl_groups_metadata ADD FOREIGN KEY (group_id) REFERENCES tl_groups(id);
ALTER TABLE tl_groups_metadata ADD FOREIGN KEY (language_1) REFERENCES languages(lang_code);
ALTER TABLE tl_groups_metadata ADD FOREIGN KEY (language_2) REFERENCES languages(lang_code);
ALTER TABLE tl_groups_metadata ADD FOREIGN KEY (language_3) REFERENCES languages(lang_code);

ALTER TABLE tl_groups_members ADD FOREIGN KEY (group_id) REFERENCES tl_groups(id);
ALTER TABLE tl_groups_members ADD FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE tl_groups_updates ADD FOREIGN KEY (group_id) REFERENCES tl_groups(id);
ALTER TABLE tl_groups_updates ADD FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE tl_groups_moderation_logs ADD FOREIGN KEY (group_id) REFERENCES tl_groups(id);
ALTER TABLE tl_groups_moderation_logs ADD FOREIGN KEY (mod_id) REFERENCES users(id);

-- ----- Translations ----- --
ALTER TABLE translations ADD FOREIGN KEY (post_id) REFERENCES posts(id);
ALTER TABLE translations ADD FOREIGN KEY (group_id) REFERENCES tl_groups(id);

-- ----- Posts ----- --
ALTER TABLE posts ADD FOREIGN KEY (op_id) REFERENCES users(id);
ALTER TABLE posts ADD FOREIGN KEY (original_lang) REFERENCES languages(lang_code);
ALTER TABLE posts ADD FOREIGN KEY (translated_from) REFERENCES languages(lang_code);

ALTER TABLE posts_details ADD FOREIGN KEY (post_id) REFERENCES posts(id);
ALTER TABLE posts_details ADD FOREIGN KEY (game_length) REFERENCES game_length(id);

ALTER TABLE posts_tl_progress ADD FOREIGN KEY (post_id) REFERENCES posts(id);

-- ----- Comments ----- --
ALTER TABLE comments ADD FOREIGN KEY (parent_id) REFERENCES comments(id);
ALTER TABLE comments ADD FOREIGN KEY (post_id) REFERENCES posts(id);
ALTER TABLE comments ADD FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE comments_votes ADD FOREIGN KEY (comment_id) REFERENCES comments(id);
ALTER TABLE comments_votes ADD FOREIGN KEY (user_id) REFERENCES users(id);

-- ----- Comments' History ----- --
ALTER TABLE comments_moderation_logs ADD FOREIGN KEY (comment_id) REFERENCES comments(id);
ALTER TABLE comments_moderation_logs ADD FOREIGN KEY (mod_id) REFERENCES users(id);

-- ----- Reviews ----- --
ALTER TABLE reviews ADD FOREIGN KEY (post_id) REFERENCES posts(id);
ALTER TABLE reviews ADD FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE reviews_votes ADD FOREIGN KEY (review_id) REFERENCES reviews(id);
ALTER TABLE reviews_votes ADD FOREIGN KEY (user_id) REFERENCES users(id);

-- ----- Reviews' History ----- --
ALTER TABLE reviews_attachments_hist ADD FOREIGN KEY (review_id) REFERENCES reviews(id);

ALTER TABLE reviews_moderation_logs ADD FOREIGN KEY (review_id) REFERENCES reviews(id);
ALTER TABLE reviews_moderation_logs ADD FOREIGN KEY (mod_id) REFERENCES users(id);