-- ------------------------------------------------- --
--  Cloud Nine Café - Comunidad de Novelas Visuales  --
-- ------------------------------------------------- --
-- Version: 1.2.5
-- Date: 2024-11-23
-- ------------------------------------------------- --
-- Changelog 1.2.5:
-- - This is now a thing, so you can see the changes made to the schema.
-- - Added a new table to manage entity flags, reports and changes.
-- - Fusioned most of the history tables into a single one. (change_history)
-- - Fusioned all the reports tables into a single one. (report_history)
-- - Fusioned all the hidden_data tables into a single one. (entity_flags)
-- - Optimized the schema by removing or fusioning tables. (For example, users_extras, users_web_skins and users_privacy_prefs are now part of users_preferences)

-- ----- History ----- --
-- Most previously made history tables have been replaced by these ones to make management more efficient.
CREATE TABLE change_history (
    id INT PRIMARY KEY AUTO_INCREMENT,
    entity_type ENUM('User', 'TLGroup', 'Post', 'Comment', 'Review') NOT NULL,
    entity_id INT NOT NULL, -- Affected Entity ID
    field_changed VARCHAR(255) NOT NULL,
    old_value TEXT,
    new_value TEXT,
    changed_by INT, -- ID of the user who made the change
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE report_history (
    entity_type ENUM('User', 'TLGroup', 'Post', 'Comment', 'Review') NOT NULL,
    entity_id INT NOT NULL,
    reporter_id INT NOT NULL,
    reason TEXT NOT NULL,
    report_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ----- Flags ----- --
-- As I mentioned before, most of the hidden_data tables have been replaced by this one.
CREATE TABLE entity_flags (
    entity_type ENUM('Post', 'Comment', 'Review', 'Group') NOT NULL,
    entity_id INT NOT NULL,
    hidden BOOLEAN NOT NULL DEFAULT 0,
    locked BOOLEAN NOT NULL DEFAULT 0,
    reports SMALLINT NOT NULL DEFAULT 0,
    PRIMARY KEY (entity_type, entity_id)
);

-- ----- Users ----- --

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(255) UNIQUE NOT NULL,
    display_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    is_email_verified BOOLEAN NOT NULL DEFAULT 0,
    avatar VARCHAR(255) NOT NULL,
    status ENUM('Activo', 'Desactivado', 'Muteado', 'Baneado') NOT NULL DEFAULT 'Activo',
    password TEXT NOT NULL, -- This will be obviously hashed and salted, so if you're going to try and hack this, good luck!
    registered TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users_preferences (
    user_id INT PRIMARY KEY,
    bio TEXT,
    bio_hidden BOOLEAN NOT NULL DEFAULT 0,
    twitter VARCHAR(255),
    twitter_hidden BOOLEAN NOT NULL DEFAULT 0,
    discord VARCHAR(255),
    discord_hidden BOOLEAN NOT NULL DEFAULT 0,
    web_skin SMALLINT NOT NULL DEFAULT 1
);

CREATE TABLE users_role (
    user_id INT NOT NULL,
    role_id INT NOT NULL
);

-- ----- Users' history ----- --

CREATE TABLE users_password_hist (
    user_id INT NOT NULL,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users_moderation_logs (
    user_id INT NOT NULL,
    mod_id INT NOT NULL,
    action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    mod_action ENUM('Ban', 'Mute') NOT NULL,
    reason TEXT NOT NULL,
    until TIMESTAMP NULL
);

-- ----- Sessions ----- --
-- How did I even forget this until now?

CREATE TABLE user_sessions (
    user_id INT NOT NULL,
    session_id TEXT NOT NULL,
    expires TIMESTAMP NULL
);


-- ----- Web Skins ----- --

CREATE TABLE web_skins (
    id SMALLINT PRIMARY KEY AUTO_INCREMENT,
    skin_name VARCHAR(30) NOT NULL,
    primary_color VARCHAR(7) NOT NULL,
    secondary_color VARCHAR(7) NOT NULL,
    accent_color VARCHAR(7) NOT NULL,
    background_color VARCHAR(7) NOT NULL,
    text_color VARCHAR(7) NOT NULL
);

-- ----- Roles ----- --

CREATE TABLE roles (
    id INT PRIMARY KEY AUTO_INCREMENT,
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
    id INT PRIMARY KEY AUTO_INCREMENT,
    perm_name VARCHAR(255) NOT NULL
);

-- ----- TL Groups ----- --

CREATE TABLE tl_groups (
    id INT PRIMARY KEY AUTO_INCREMENT,
    owner_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    latin_name VARCHAR(255) NOT NULL, -- In case the name uses non-latin characters, This will be the "main name".
    description TEXT NOT NULL,
    status ENUM('Activo', 'Q.E.P.D') NOT NULL DEFAULT 'Activo'
);

CREATE TABLE translations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    group_id INT NOT NULL
);

CREATE TABLE tl_groups_metadata (
    group_id INT PRIMARY KEY,
    alias_1 VARCHAR(255),
    alias_2 VARCHAR(255),
    alias_3 VARCHAR(255),
    facebook VARCHAR(255),
    twitter VARCHAR(255),
    discord VARCHAR(255),
    website VARCHAR(255),
    language_1 VARCHAR(2) NOT NULL,
    language_2 VARCHAR(2),
    language_3 VARCHAR(2)
);

CREATE TABLE tl_groups_members (
    group_id INT NOT NULL,
    user_id INT,
    name VARCHAR(255),
    role ENUM('Dueño/a', 'Editor/a de imágenes', 'Corrector/a', 'Traductor/a', 'Programador/a') NOT NULL DEFAULT 'Traductor/a'
);

CREATE TABLE tl_groups_updates (
    id INT PRIMARY KEY AUTO_INCREMENT,
    group_id INT NOT NULL,
    user_id INT NOT NULL,
    post_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    content TEXT NOT NULL,
    hidden BOOLEAN NOT NULL DEFAULT 0,
    locked BOOLEAN NOT NULL DEFAULT 0
);

-- ----- Translation Groups' History ----- --

CREATE TABLE tl_groups_alias_hist (
    group_id INT NOT NULL,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_1 VARCHAR(255),
    old_2 VARCHAR(255),
    old_3 VARCHAR(255),
    new_1 VARCHAR(255),
    new_2 VARCHAR(255),
    new_3 VARCHAR(255)
);

CREATE TABLE tl_groups_members_hist (
    group_id INT NOT NULL,
    user_id INT NOT NULL,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action ENUM('Añadido', 'Editado', 'Eliminado') NOT NULL,
    member_id INT,
    member_name VARCHAR(255), -- In case the member is not registered
    role ENUM('Dueño/a', 'Editor/a de imágenes', 'Corrector/a', 'Traductor/a', 'Programador/a') NOT NULL
);

CREATE TABLE tl_groups_updates_hist (
    update_id INT NOT NULL,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_content TEXT,
    new_content TEXT,
    hidden BOOLEAN,
    locked BOOLEAN
);

CREATE TABLE tl_groups_moderation_logs (
    group_id INT NOT NULL,
    mod_id INT NOT NULL,
    action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT NOT NULL,
    locked BOOLEAN NOT NULL,
    hidden BOOLEAN NOT NULL
);

-- ----- Languages ----- --

CREATE TABLE languages (
    lang_code VARCHAR(2) NOT NULL PRIMARY KEY,
    lang_name VARCHAR(255) NOT NULL
);

-- ----- Posts ----- --
--
-- I stressed an awful lot while thinking about this part in the beginning.
-- You've been warned, I'm not joking.
--

CREATE TABLE posts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    op_id INT NOT NULL,
    publish_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    translated_from VARCHAR(2) NOT NULL,
    cover_image VARCHAR(255) NOT NULL,
    title VARCHAR(255) NOT NULL, -- Title of the visual novel (in romaji/latin characters)
    download_link VARCHAR(255) NOT NULL, -- Link to download the translation
    download_note TEXT -- Note about the download link
);

CREATE TABLE posts_aliases (
    post_id INT NOT NULL,
    alias VARCHAR(255) NOT NULL
);

CREATE TABLE posts_details (
    post_id INT NOT NULL,
    sinopsis TEXT,
    game_length SMALLINT,
    classification ENUM('All ages', '13+', '16+', '18+') NOT NULL,
    tl_type ENUM('Manual', 'MTL', 'MTL editado') NOT NULL,
    tl_status ENUM('En progreso', 'Completada', 'Pausada', 'Cancelada') NOT NULL,
    tl_scope ENUM('Completa', 'Parcial') NOT NULL,
    tl_platform ENUM('PC', 'Android', 'Otros') NOT NULL,
    buy_links JSON -- [{"plataforma": "Steam", "link": "https://..."}]
);

CREATE TABLE posts_tl_progress (
    post_id INT NOT NULL,
    tl_percentage SMALLINT NOT NULL,
    tl_section ENUM('Traduciendo', 'Corrigiendo', 'Editando imágenes', 'Reinsertando', 'Testeando') NOT NULL
);

-- ----- Posts' length ----- --

CREATE TABLE game_length ( -- For now, it's 1 - 5. 1 = Very short (Less than 2 hours), 5 = Very long (More than 50 hours)
    -- 1 = "Muy corto" (Menos de 2 horas)
    -- 2 = "Corto" (Entre 2 y 10 horas)
    -- 3 = "Medio" (Entre 10 y 30 horas)
    -- 4 = "Largo" (Entre 30 y 50 horas)
    -- 5 = "Muy largo" (Más de 50 horas)
    id SMALLINT PRIMARY KEY AUTO_INCREMENT,
    length_name VARCHAR(255) NOT NULL
);

-- ----- Posts' history ----- --
-- This part has been now replaced by the change_history table.

-- ----- Comments ----- --

CREATE TABLE comments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    parent_id INT,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    votes INT NOT NULL DEFAULT 0,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE comments_votes (
    comment_id INT NOT NULL,
    user_id INT NOT NULL,
    vote ENUM('Up', 'Down') NOT NULL,
    PRIMARY KEY(comment_id, user_id)
);

-- ----- Comments' history ----- --

CREATE TABLE comments_moderation_logs (
    comment_id INT NOT NULL,
    mod_id INT NOT NULL,
    action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT NOT NULL,
    hidden BOOLEAN NOT NULL,
    locked BOOLEAN NOT NULL
);

-- ----- Reviews ----- --

CREATE TABLE reviews (
    id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    rating SMALLINT NOT NULL, -- 1 = "Utter bullsh*t" to 5 = "HOLY SH*T THIS IS AMAZING"
    votes INT NOT NULL DEFAULT 0,
    attachments JSON, -- ["https://...", "https://..."]
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE reviews_votes (
    review_id INT NOT NULL,
    user_id INT NOT NULL,
    vote ENUM('Up', 'Down') NOT NULL
);

-- ----- Reviews' history ----- --

CREATE TABLE reviews_attachments_hist (
    review_id INT NOT NULL,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action ENUM('Añadido', 'Eliminado') NOT NULL,
    attachment VARCHAR(255) NOT NULL
);

CREATE TABLE reviews_moderation_logs (
    review_id INT NOT NULL,
    mod_id INT NOT NULL,
    action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT NOT NULL,
    hidden BOOLEAN NOT NULL,
    locked BOOLEAN NOT NULL
);


-- ----------------- --
--  Extra functions  --
-- ----------------- --
--
-- So uhh... MariaDB doesn't accept multiple CHECK constraints in a single column, so I had to do this.
-- Also, some things that need to be checked.
--

DELIMITER //

-- ----- Users ----- --
-- Validating user socials handlers
CREATE TRIGGER validate_user_socials
BEFORE INSERT ON users_preferences
FOR EACH ROW BEGIN
    IF (NEW.twitter IS NOT NULL AND NEW.twitter NOT LIKE '@%') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tu handle de Twitter debe comenzar en "@".';
    END IF;

    IF (NEW.discord IS NOT NULL AND NEW.discord NOT LIKE '@%') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tu handle de Discord debe comenzar en "@".';
    END IF;
END//


-- ----- Web Skins ----- --
-- Validating color format
CREATE TRIGGER validate_web_color_schema
BEFORE INSERT ON web_skins
FOR EACH ROW BEGIN
    IF NEW.primary_color NOT LIKE '#%' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El color primario debe comenzar en "#".';
    END IF;

    IF NEW.secondary_color NOT LIKE '#%' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El color secundario debe comenzar en "#".';
    END IF;

    IF NEW.accent_color NOT LIKE '#%' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El color de acento debe comenzar en "#".';
    END IF;

    IF NEW.background_color NOT LIKE '#%' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El color de fondo debe comenzar en "#".';
    END IF;

    IF NEW.text_color NOT LIKE '#%' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El color de texto debe comenzar en "#".';
    END IF;
END//


-- ----- TL Groups ----- --
-- Validating social media handles and website links
CREATE TRIGGER validate_group_socials
BEFORE INSERT ON tl_groups_metadata
FOR EACH ROW BEGIN
    IF (NEW.facebook IS NOT NULL AND NEW.facebook NOT LIKE '/%') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tu handle de Facebook debe comenzar en "/".';
    END IF;

    IF (NEW.twitter IS NOT NULL AND NEW.twitter NOT LIKE '@%') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tu handle de Twitter debe comenzar en "@".';
    END IF;

    IF (NEW.discord IS NOT NULL AND NEW.discord NOT LIKE '.gg/%') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tu handle de Discord debe comenzar en ".gg/".';
    END IF;

    IF (NEW.website IS NOT NULL AND NEW.website NOT LIKE 'http%') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tu link de página web debe comenzar en "http" o "https".';
    END IF;
END//


-- Making sure aliases don't repeat themselves or another group has them as a name. (Aliases can be repeated, what we don't want is someone using an alias that's already being used by another group as their name)
CREATE TRIGGER validate_group_aliases
BEFORE INSERT ON tl_groups_metadata
FOR EACH ROW BEGIN
    IF NEW.alias_1 = NEW.alias_2 OR NEW.alias_1 = NEW.alias_3 OR NEW.alias_2 = NEW.alias_3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Las alias del grupo no pueden ser iguales';
    END IF;

    IF (EXISTS (SELECT 1 FROM tl_groups WHERE (name = NEW.alias_1 OR latin_name = NEW.alias_1) AND id != NEW.group_id) OR
        EXISTS (SELECT 1 FROM tl_groups WHERE (name = NEW.alias_2 OR latin_name = NEW.alias_2) AND id != NEW.group_id) OR
        EXISTS (SELECT 1 FROM tl_groups WHERE (name = NEW.alias_3 OR latin_name = NEW.alias_3) AND id != NEW.group_id)) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Uno de los alias ya está siendo usado como nombre de otro grupo.';
    END IF;
END//


-- ----- Posts ----- --
-- Validating post information
CREATE TRIGGER validate_post_info
BEFORE INSERT ON posts
FOR EACH ROW BEGIN
    IF NEW.cover_image NOT LIKE 'http%' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Link a imagen inválido.';
    END IF;

    IF NEW.download_link NOT LIKE 'http%' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Link de descarga inválido.';
    END IF;
END//


-- Validating posts aliases to prevent different visual novels having the same alias or name.
CREATE TRIGGER validate_post_aliases
BEFORE INSERT ON posts_aliases
FOR EACH ROW BEGIN
    IF (EXISTS (SELECT 1 FROM posts WHERE title = NEW.alias)) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El apodo que intentas agregar está siendo usado por otro post como el nombre de la novela.';
    END IF;

    IF (EXISTS (SELECT 1 FROM posts WHERE id != NEW.post_id AND id IN (SELECT post_id FROM posts_aliases WHERE alias = NEW.alias))) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El apodo que intentas agregar ya está siendo usado por otro post.';
    END IF;
END//


-- Validate post details
CREATE TRIGGER validate_post_details
BEFORE INSERT ON posts_details
FOR EACH ROW BEGIN
    IF NEW.sinopsis IS NULL THEN
        SET NEW.sinopsis = 'Esta novela aún no tiene una sinopsis.';
    END IF;
    
    IF NEW.classification NOT IN ('All ages', '13+', '16+', '18+') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La clasificación de edad no es válida.';
    END IF;

    IF NEW.tl_status NOT IN ('En progreso', 'Completada', 'Pausada', 'Cancelada') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El estado de traducción no es válido.';
    END IF;
END//


-- Validate post translation progress
CREATE TRIGGER validate_post_tl_progress
BEFORE INSERT ON posts_tl_progress
FOR EACH ROW BEGIN
    IF NEW.tl_percentage < 0 OR NEW.tl_percentage > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Porcentaje de traducción inválido.';
    END IF;
END//


-- ----- Comments ----- --
-- Validate parent comment
CREATE TRIGGER validate_parent_comment
BEFORE INSERT ON comments
FOR EACH ROW BEGIN
    IF NEW.parent_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM comments WHERE id = NEW.parent_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El comentario al que intentas responder no existe o fue eliminado.';
    END IF;
END//


-- ----- Reviews ----- --
-- Validate reviews general info
CREATE TRIGGER validate_review_info
BEFORE INSERT ON reviews
FOR EACH ROW BEGIN
    IF NEW.rating < 1 OR NEW.rating > 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La calificación debe estar entre 1 y 5.';
    END IF;
END//

DELIMITER ;

-- ----------------- --
--   Foreign Keys    --
-- ----------------- --
--
-- Why, PHPMyAdmin? Why do you make me do this?
--

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
ALTER TABLE posts ADD FOREIGN KEY (translated_from) REFERENCES languages(lang_code);

ALTER TABLE posts_aliases ADD FOREIGN KEY (post_id) REFERENCES posts(id);

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