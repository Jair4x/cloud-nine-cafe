-----------------------------------------------------
-- Cloud Nine Café - Comunidad de Novelas Visuales --
-----------------------------------------------------


------- Users -------

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(255) UNIQUE NOT NULL,
    display_name VARCHAR(255) NOT NULL,
    is_email_verified BOOLEAN NOT NULL DEFAULT 0,
    avatar VARCHAR(255) NOT NULL,
    status ENUM('Activo', 'Desactivado', 'Muteado', 'Baneado') NOT NULL DEFAULT 'Activo',
    registered TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users_extras (
    user_id INT NOT NULL,
    bio TEXT,
    tl_group INT,
    twitter VARCHAR(255),
    discord VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (tl_group) REFERENCES tl_groups(id)
);

CREATE TABLE users_web_prefs (
    user_id INT NOT NULL,
    web_skin SMALLINT NOT NULL DEFAULT 1,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (web_skin) REFERENCES web_skins(id)
);

CREATE TABLE users_role (
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (role_id) REFERENCES roles(id)
);

CREATE TABLE users_hidden_info (
    user_id INT NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password TEXT NOT NULL, -- This will be obviously hashed and salted, so if you're going to try and hack this, good luck!
    reports SMALLINT NOT NULL DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(id),
);

CREATE TABLE users_reports (
    user_id INT NOT NULL,
    reporter_id INT NOT NULL,
    when TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (reporter_id) REFERENCES users(id)
);

CREATE TABLE users_extras_privacy (
    user_id INT NOT NULL,
    bio_hidden BOOLEAN NOT NULL DEFAULT 0,
    twitter_hidden BOOLEAN NOT NULL DEFAULT 0,
    discord_hidden BOOLEAN NOT NULL DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

------- Users' history -------

CREATE TABLE users_email_hist (
    user_id INT NOT NULL,
    when TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old VARCHAR(255) NOT NULL,
    new VARCHAR(255) NOT NULL,
);

CREATE TABLE users_username_hist (
    user_id INT NOT NULL,
    when TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old VARCHAR(255) NOT NULL,
    new VARCHAR(255) NOT NULL,
);

CREATE TABLE users_password_hist (
    user_id INT NOT NULL,
    when TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
);

CREATE TABLE users_mod_hist (
    user_id INT NOT NULL,
    mod_id INT NOT NULL,
    when TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    mod_action ENUM('Ban', 'Mute') NOT NULL,
    reason TEXT NOT NULL,
    until TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (mod_id) REFERENCES users(id)
);

------- Web Skins -------

CREATE TABLE web_skins (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(30) NOT NULL,
    primary_color VARCHAR(7) NOT NULL,
    secondary_color VARCHAR(7) NOT NULL,
    accent_color VARCHAR(7) NOT NULL,
    background_color VARCHAR(7) NOT NULL,
    text_color VARCHAR(7) NOT NULL
);

------- Roles -------

CREATE TABLE roles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE roles_perms (
    role_id INT NOT NULL,
    perm_id INT NOT NULL,
    FOREIGN KEY (role_id) REFERENCES roles(id),
    FOREIGN KEY (perm_id) REFERENCES perms(id)
);

------- Permissions -------
--
-- Want to know more about the permissions? Check out PERMS.md
--

CREATE TABLE perms (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL
);

------- TL Groups -------

CREATE TABLE tl_groups (
    id INT PRIMARY KEY AUTO_INCREMENT,
    owner_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    latin_name VARCHAR(255) NOT NULL, -- In case the name uses non-latin characters, This will be the "main name".
    description TEXT NOT NULL,
    status ENUM('Activo', 'Q.E.P.D') NOT NULL DEFAULT 'Activo',
    FOREIGN KEY (owner_id) REFERENCES users(id)
);

CREATE TABLE tl_groups_alias (
    group_id UNIQUE INT NOT NULL,
    alias_1 VARCHAR(255),
    alias_2 VARCHAR(255),
    alias_3 VARCHAR(255),
    FOREIGN KEY (group_id) REFERENCES tl_groups(id)
);

CREATE TABLE tl_groups_socials (
    group_id UNIQUE INT NOT NULL,
    facebook VARCHAR(255),
    twitter VARCHAR(255),
    discord VARCHAR(255),
    website VARCHAR(255),
    FOREIGN KEY (group_id) REFERENCES tl_groups(id)
);

CREATE TABLE tl_groups_languages (
    group_id UNIQUE INT NOT NULL,
    language_id_1 INT NOT NULL,
    language_id_2 INT NOT NULL,
    language_id_3 INT NOT NULL,
    FOREIGN KEY (group_id) REFERENCES tl_groups(id),
    FOREIGN KEY (language_id_1) REFERENCES languages(id),
    FOREIGN KEY (language_id_2) REFERENCES languages(id),
    FOREIGN KEY (language_id_3) REFERENCES languages(id)
);

CREATE TABLE tl_groups_members (
    group_id INT NOT NULL,
    user_id INT,
    name VARCHAR(255),
    role ENUM('Dueño/a', 'Editor/a de imágenes', 'Corrector/a', 'Traductor/a', 'Programador/a') NOT NULL DEFAULT 'Traductor/a',
    FOREIGN KEY (group_id) REFERENCES tl_groups(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE tl_groups_translations (
    group_id INT NOT NULL,
    post_id INT NOT NULL,
    FOREIGN KEY (group_id) REFERENCES tl_groups(id),
    FOREIGN KEY (post_id) REFERENCES posts(id)
);

CREATE TABLE tl_groups_updates (
    id INT PRIMARY KEY AUTO_INCREMENT,
    group_id INT NOT NULL,
    user_id INT NOT NULL,
    when TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    content TEXT NOT NULL,
    hidden BOOLEAN NOT NULL DEFAULT 0,
    locked BOOLEAN NOT NULL DEFAULT 0,
    FOREIGN KEY (group_id) REFERENCES tl_groups(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE tl_groups_hidden_data (
    group_id INT NOT NULL,
    reports SMALLINT NOT NULL DEFAULT 0,
    locked BOOLEAN NOT NULL DEFAULT 0,
    hidden BOOLEAN NOT NULL DEFAULT 0,
    FOREIGN KEY (group_id) REFERENCES tl_groups(id)
);

CREATE TABLE tl_groups_reports (
    group_id INT NOT NULL,
    reporter_id INT NOT NULL,
    when TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT NOT NULL,
    FOREIGN KEY (group_id) REFERENCES tl_groups(id),
    FOREIGN KEY (reporter_id) REFERENCES users(id)
);

------- Translation Groups' History -------

CREATE TABLE tl_groups_name_hist (
    group_id INT NOT NULL,
    when TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old VARCHAR(255) NOT NULL,
    new VARCHAR(255) NOT NULL,
    FOREIGN KEY (group_id) REFERENCES tl_groups(id)
);

CREATE TABLE tl_groups_latin_name_hist (
    group_id INT NOT NULL,
    when TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old VARCHAR(255) NOT NULL,
    new VARCHAR(255) NOT NULL,
    FOREIGN KEY (group_id) REFERENCES tl_groups(id)
);

CREATE TABLE tl_groups_alias_hist (
    group_id INT NOT NULL,
    when TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_1 VARCHAR(255),
    old_2 VARCHAR(255),
    old_3 VARCHAR(255),
    new_1 VARCHAR(255),
    new_2 VARCHAR(255),
    new_3 VARCHAR(255),
    FOREIGN KEY (group_id) REFERENCES tl_groups(id)
);

CREATE TABLE tl_groups_description_hist (
    group_id INT NOT NULL,
    when TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old TEXT NOT NULL,
    new TEXT NOT NULL,
    FOREIGN KEY (group_id) REFERENCES tl_groups(id)
);

CREATE TABLE tl_groups_language_hist (
    group_id INT NOT NULL,
    when TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_1 INT,
    old_2 INT,
    old_3 INT,
    new_1 INT,
    new_2 INT,
    new_3 INT,
    FOREIGN KEY (group_id) REFERENCES tl_groups(id),
    FOREIGN KEY (old_1) REFERENCES languages(id),
    FOREIGN KEY (old_2) REFERENCES languages(id),
    FOREIGN KEY (old_3) REFERENCES languages(id),
    FOREIGN KEY (new_1) REFERENCES languages(id),
    FOREIGN KEY (new_2) REFERENCES languages(id),
    FOREIGN KEY (new_3) REFERENCES languages(id)
);

CREATE TABLE tl_groups_status_hist (
    group_id INT NOT NULL,
    when TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old ENUM('Activo', 'Q.E.P.D') NOT NULL,
    new ENUM('Activo', 'Q.E.P.D') NOT NULL,
    FOREIGN KEY (group_id) REFERENCES tl_groups(id)
);

CREATE TABLE tl_groups_members_hist (
    group_id INT NOT NULL,
    user_id INT NOT NULL,
    when TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action ENUM('Añadido', 'Editado', 'Eliminado') NOT NULL,
    member_id INT,
    member_name VARCHAR(255), -- In case the member is not registered (nr = non-registered)
    FOREIGN KEY (group_id) REFERENCES tl_groups(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (member_id) REFERENCES users(id)
);

CREATE TABLE tl_groups_translations_hist (
    group_id INT NOT NULL,
    user_id INT NOT NULL,
    when TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action ENUM('Añadido', 'Eliminado') NOT NULL,
    post_id INT NOT NULL,
    FOREIGN KEY (group_id) REFERENCES tl_groups(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (post_id) REFERENCES posts(id)
);

CREATE TABLE tl_groups_updates_hist (
    update_id INT NOT NULL,
    when TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_content TEXT,
    new_content TEXT,
    hidden BOOLEAN,
    locked BOOLEAN,
    FOREIGN KEY (update_id) REFERENCES tl_groups_updates(id)
);

CREATE TABLE tl_groups_mod_hist (
    group_id INT NOT NULL,
    mod_id INT NOT NULL,
    when TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT NOT NULL,
    locked BOOLEAN NOT NULL,
    hidden BOOLEAN NOT NULL,
    FOREIGN KEY (group_id) REFERENCES tl_groups(id),
    FOREIGN KEY (mod_id) REFERENCES users(id)
);

------- Languages -------

CREATE TABLE languages (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
);

------- Posts -------
--
-- I'm going to cry an awful lot while thinking about this part.
-- You've been warned, I'm not joking.
--

CREATE TABLE posts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    op_id INT NOT NULL,
    published TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    translated_from INT NOT NULL,
    cover_image VARCHAR(255) NOT NULL,
    title VARCHAR(255) NOT NULL, -- Title of the visual novel (in romaji/latin characters)
    download_link VARCHAR(255) NOT NULL, -- Link to download the translation
    download_note TEXT, -- Note about the download link
    FOREIGN KEY (op_id) REFERENCES users(id),
    FOREIGN KEY (translated_from) REFERENCES languages(id)
);

CREATE TABLE posts_translators (
    post_id INT NOT NULL,
    group_id INT NOT NULL,
    FOREIGN KEY (post_id) REFERENCES posts(id),
    FOREIGN KEY (group_id) REFERENCES tl_groups(id)
);

CREATE TABLE posts_aliases (
    post_id INT NOT NULL,
    alias VARCHAR(255) NOT NULL,
    FOREIGN KEY (post_id) REFERENCES posts(id)
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
    FOREIGN KEY (post_id) REFERENCES posts(id),
    FOREIGN KEY (game_length) REFERENCES game_length(id)
);

CREATE TABLE posts_buy_links (
    post_id INT NOT NULL,
    platform ENUM('Steam', 'Itch.io', 'DLSite', 'Mangagamer', 'JAST USA', 'Others') NOT NULL,
    link VARCHAR(255) NOT NULL,
    FOREIGN KEY (post_id) REFERENCES posts(id)
);

CREATE TABLE posts_tl_progress (
    post_id INT NOT NULL,
    tl_percentage SMALLINT NOT NULL,
    tl_section ENUM('Traduciendo', 'Corrigiendo', 'Editando imágenes', 'Reinsertando', 'Testeando') NOT NULL,
    FOREIGN KEY (post_id) REFERENCES posts(id)
);

CREATE TABLE posts_hidden_data (
    post_id INT NOT NULL,
    locked BOOLEAN NOT NULL DEFAULT 0,
    hidden BOOLEAN NOT NULL DEFAULT 0,
    reports SMALLINT NOT NULL DEFAULT 0,
    FOREIGN KEY (post_id) REFERENCES posts(id)
);

CREATE TABLE posts_reports (
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    reason TEXT NOT NULL,
    FOREIGN KEY (post_id) REFERENCES posts(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

------- Posts' length -------

CREATE TABLE game_length ( -- For now, it's 1 - 5. 1 = Very short (Less than 2 hours), 5 = Very long (More than 50 hours)
    -- 1 = "Muy corto" (Menos de 2 horas)
    -- 2 = "Corto" (Entre 2 y 10 horas)
    -- 3 = "Medio" (Entre 10 y 30 horas)
    -- 4 = "Largo" (Entre 30 y 50 horas)
    -- 5 = "Muy largo" (Más de 50 horas)
    id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

------- Posts' history -------

CREATE TABLE posts_title_hist (
    post_id INT NOT NULL,
    when TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old VARCHAR(255) NOT NULL,
    new VARCHAR(255) NOT NULL,
    FOREIGN KEY (post_id) REFERENCES posts(id)
);

CREATE TABLE posts_download_link_hist (
    post_id INT NOT NULL,
    when TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old VARCHAR(255) NOT NULL,
    new VARCHAR(255) NOT NULL,
    FOREIGN KEY (post_id) REFERENCES posts(id)
);

CREATE TABLE posts_cover_image_hist (
    post_id INT NOT NULL,
    when TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old VARCHAR(255) NOT NULL,
    new VARCHAR(255) NOT NULL,
    FOREIGN KEY (post_id) REFERENCES posts(id)
);

CREATE TABLE posts_sinopsis_hist (
    post_id INT NOT NULL,
    when TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old TEXT NOT NULL,
    new TEXT NOT NULL,
    FOREIGN KEY (post_id) REFERENCES posts(id)
);

CREATE TABLE posts_length_hist (
    post_id INT NOT NULL,
    when TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old SMALLINT NOT NULL,
    new SMALLINT NOT NULL,
    FOREIGN KEY (post_id) REFERENCES posts(id),
    FOREIGN KEY (old) REFERENCES game_length(id),
    FOREIGN KEY (new) REFERENCES game_length(id)
);

CREATE TABLE posts_buy_links_hist (
    post_id INT NOT NULL,
    when TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action ENUM('Añadido', 'Editado', 'Eliminado') NOT NULL,
    platform ENUM('Steam', 'Itch.io', 'DLSite', 'Mangagamer', 'JAST USA', 'Others') NOT NULL,
    link VARCHAR(255) NOT NULL,
    FOREIGN KEY (post_id) REFERENCES posts(id)
);

------- Comments -------

CREATE TABLE comments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    parent_id INT,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    votes INT NOT NULL DEFAULT 0,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES comments(id),
    FOREIGN KEY (post_id) REFERENCES posts(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE comments_votes (
    comment_id INT NOT NULL,
    user_id INT NOT NULL,
    vote ENUM('Up', 'Down') NOT NULL,
    FOREIGN KEY (comment_id) REFERENCES comments(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
); 

CREATE TABLE comments_hidden_data (
    comment_id INT NOT NULL,
    locked BOOLEAN NOT NULL DEFAULT 0,
    hidden BOOLEAN NOT NULL DEFAULT 0,
    reports SMALLINT NOT NULL DEFAULT 0,
    FOREIGN KEY (comment_id) REFERENCES comments(id)
);

CREATE TABLE comments_reports (
    comment_id INT NOT NULL,
    user_id INT NOT NULL,
    FOREIGN KEY (comment_id) REFERENCES comments(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

------- Comments' history -------

CREATE TABLE comments_content_hist (
    comment_id INT NOT NULL,
    when TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old TEXT NOT NULL,
    new TEXT NOT NULL,
    FOREIGN KEY (comment_id) REFERENCES comments(id)
);

CREATE TABLE comments_mod_hist (
    comment_id INT NOT NULL,
    mod_id INT NOT NULL,
    when TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT NOT NULL,
    hidden BOOLEAN NOT NULL,
    locked BOOLEAN NOT NULL,
    FOREIGN KEY (comment_id) REFERENCES comments(id),
    FOREIGN KEY (mod_id) REFERENCES users(id)
);

------- Reviews -------

CREATE TABLE reviews (
    id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    rating SMALLINT NOT NULL, -- 1 = "Utter bullsh*t" to 5 = "HOLY SH*T THIS IS AMAZING"
    votes INT NOT NULL DEFAULT 0,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE reviews_attachments (
    review_id INT NOT NULL,
    attachment VARCHAR(255) NOT NULL,
    FOREIGN KEY (review_id) REFERENCES reviews(id)
);

CREATE TABLE reviews_votes (
    review_id INT NOT NULL,
    user_id INT NOT NULL,
    vote ENUM('Up', 'Down') NOT NULL,
    FOREIGN KEY (review_id) REFERENCES reviews(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE reviews_hidden_data (
    review_id INT NOT NULL,
    hidden BOOLEAN NOT NULL DEFAULT 0,
    locked BOOLEAN NOT NULL DEFAULT 0,
    reports SMALLINT NOT NULL DEFAULT 0,
    FOREIGN KEY (review_id) REFERENCES reviews(id)
);

CREATE TABLE reviews_reports (
    review_id INT NOT NULL,
    user_id INT NOT NULL,
    reason TEXT,
    FOREIGN KEY (review_id) REFERENCES reviews(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

------- Reviews' history -------

CREATE TABLE reviews_content_hist (
    review_id INT NOT NULL,
    when TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old TEXT NOT NULL,
    new TEXT NOT NULL,
    FOREIGN KEY (review_id) REFERENCES reviews(id)
);

CREATE TABLE reviews_rating_hist (
    review_id INT NOT NULL,
    when TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old SMALLINT NOT NULL,
    new SMALLINT NOT NULL,
    FOREIGN KEY (review_id) REFERENCES reviews(id)
);

CREATE TABLE reviews_attachments_hist (
    review_id INT NOT NULL,
    when TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action ENUM('Añadido', 'Eliminado') NOT NULL,
    attachment VARCHAR(255) NOT NULL,
    FOREIGN KEY (review_id) REFERENCES reviews(id)
);

CREATE TABLE reviews_mod_hist (
    review_id INT NOT NULL,
    mod_id INT NOT NULL,
    when TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT NOT NULL,
    hidden BOOLEAN NOT NULL,
    locked BOOLEAN NOT NULL,
    FOREIGN KEY (review_id) REFERENCES reviews(id),
    FOREIGN KEY (mod_id) REFERENCES users(id)
);


---------------------
-- Extra functions --
---------------------
--
-- So uhh... MariaDB doesn't accept multiple CHECK constraints in a single column, so I had to do this.
-- Also, some things that need to be checked.
--

------- Users -------
-- Validating user socials handlers
CREATE TRIGGER validate_user_socials
BEFORE INSERT ON users_extras
FOR EACH ROW BEGIN
    IF (NEW.twitter IS NOT NULL AND NEW.twitter NOT LIKE '@%') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tu handle de Twitter debe comenzar en "@".';
    END IF;

    IF (NEW.discord IS NOT NULL AND NEW.discord NOT LIKE '@%') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tu handle de Discord debe comenzar en "@".';
    END IF;
END;


-- Validating user hidden data
CREATE TRIGGER validate_user_hidden_data
BEFORE INSERT ON users_hidden_info
FOR EACH ROW BEGIN
    IF NEW.email NOT LIKE '%_@__%.__%' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El email no es válido.';
    END IF;

    IF NEW.reports < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Los reportes no pueden ser menores a 0.';
    END IF;
END;


-- Validating reports made to users
CREATE TRIGGER validate_user_reports
BEFORE INSERT ON users_reports
FOR EACH ROW BEGIN
    IF NEW.user_id = NEW.reporter_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No puedes reportarte a ti mismo.';
    END IF;
END;


------- Web Skins -------
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
END;


------- TL Groups -------
-- Validating social media handles and website links
CREATE TRIGGER validate_group_socials
BEFORE INSERT ON tl_groups_socials
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
END;


-- Making sure aliases don't repeat themselves or another group has them as a name. (Aliases can be repeated, what we don't want is someone using an alias that's already being used by another group as their name)
CREATE TRIGGER validate_group_aliases
BEFORE INSERT ON tl_groups_alias
FOR EACH ROW BEGIN
    IF NEW.alias1 = NEW.alias2 OR NEW.alias1 = NEW.alias3 OR NEW.alias2 = NEW.alias3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Las alias del grupo no pueden ser iguales';
    END IF;

    IF (EXISTS (SELECT 1 FROM tl_groups WHERE (name = NEW.alias1 OR latin_name = NEW.alias1) AND id != NEW.group_id) OR
        EXISTS (SELECT 1 FROM tl_groups WHERE (name = NEW.alias2 OR latin_name = NEW.alias2) AND id != NEW.group_id) OR
        EXISTS (SELECT 1 FROM tl_groups WHERE (name = NEW.alias3 OR latin_name = NEW.alias3) AND id != NEW.group_id)) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Uno de los alias ya está siendo usado como nombre de otro grupo.';
    END IF;
END;


-- Validating a group's hidden data
CREATE TRIGGER validate_group_hidden_data
BEFORE INSERT ON tl_groups_hidden_data
FOR EACH ROW BEGIN
    IF NEW.reports < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Los reportes no pueden ser menores a 0.';
    END IF;
END;


------- Posts -------
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
END;


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
END;


-- Validate post details
CREATE TRIGGER validate_post_details
BEFORE INSERT ON posts_details
FOR EACH ROW BEGIN
    IF sinopsis IS NULL THEN
        sinopsis = 'Esta novela aún no tiene una sinopsis.';
    END IF;
    
    IF NEW.classification NOT IN ('All ages', '13+', '16+', '18+') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La clasificación de edad no es válida.';
    END IF;

    IF NEW.tl_status NOT IN ('En progreso', 'Completada', 'Pausada', 'Cancelada') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El estado de traducción no es válido.';
    END IF;
END;


-- Validate post buy links
CREATE TRIGGER validate_post_buy_links
BEFORE INSERT ON posts_buy_links
FOR EACH ROW BEGIN
    IF NEW.link NOT LIKE 'http%' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Link de compra inválido.';
    END IF;
END;


-- Validate post translation progress
CREATE TRIGGER validate_post_tl_progress
BEFORE INSERT ON posts_tl_progress
FOR EACH ROW BEGIN
    IF NEW.tl_percentage < 0 OR NEW.tl_percentage > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Porcentaje de traducción inválido.';
    END IF;
END;


-- Validate post hidden data
CREATE TRIGGER validate_post_hidden_data
BEFORE INSERT ON posts_hidden_data
FOR EACH ROW BEGIN
    IF NEW.reports < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Los reportes no pueden ser menores a 0.';
    END IF;
END;


------- Comments -------
-- Validate parent comment
CREATE TRIGGER validate_parent_comment
BEFORE INSERT ON comments
FOR EACH ROW BEGIN
    IF NEW.parent_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM comments WHERE id = NEW.parent_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El comentario al que intentas responder no existe o fue eliminado.';
    END IF;
END;


-- Validate comment hidden data
CREATE TRIGGER validate_comment_hidden_data
BEFORE INSERT ON comments_hidden_data
FOR EACH ROW BEGIN
    IF NEW.reports < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Los reportes no pueden ser menores a 0.';
    END IF;
END;


------- Reviews -------
-- Validate reviews general info
CREATE TRIGGER validate_review_info
BEFORE INSERT ON reviews
FOR EACH ROW BEGIN
    IF NEW.rating < 1 OR NEW.rating > 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La calificación debe estar entre 1 y 5.';
    END IF;
END;


-- Validate review attachments
CREATE TRIGGER validate_review_attachments
BEFORE INSERT ON reviews_attachments
FOR EACH ROW BEGIN
    IF NEW.attachment NOT LIKE 'http%' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Link de imagen inválido.';
    END IF;
END;


-- Validate review hidden data
CREATE TRIGGER validate_review_hidden_data
BEFORE INSERT ON reviews_hidden_data
FOR EACH ROW BEGIN
    IF NEW.reports < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Los reportes no pueden ser menores a 0.';
    END IF;
END;