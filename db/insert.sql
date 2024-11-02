-- --------------------------------------------------------- --
-- Here, we'll insert some important data into the database. --
-- --------------------------------------------------------- --

-- ----- Roles ----- --
INSERT INTO roles (role_name) VALUES ('Owner');
INSERT INTO roles (role_name) VALUES ('Administrador/a');
INSERT INTO roles (role_name) VALUES ('Moderador/a');
INSERT INTO roles (role_name) VALUES ('Afiliado/a');
INSERT INTO roles (role_name) VALUES ('Usuario/a');

-- ----- Permissions ----- --
INSERT INTO perms (perm_name) VALUES ('absolute:power'); -- Owner-only permission to change "things" ;)
INSERT INTO perms (perm_name) VALUES ('read:any');
INSERT INTO perms (perm_name) VALUES ('edit:posts');
INSERT INTO perms (perm_name) VALUES ('edit:groups');
INSERT INTO perms (perm_name) VALUES ('edit:own');
INSERT INTO perms (perm_name) VALUES ('delete:posts');
INSERT INTO perms (perm_name) VALUES ('delete:groups');
INSERT INTO perms (perm_name) VALUES ('delete:reviews');
INSERT INTO perms (perm_name) VALUES ('delete:comments');
INSERT INTO perms (perm_name) VALUES ('delete:own');
INSERT INTO perms (perm_name) VALUES ('mute:users');
INSERT INTO perms (perm_name) VALUES ('temp-ban:users');
INSERT INTO perms (perm_name) VALUES ('ban:users');
INSERT INTO perms (perm_name) VALUES ('unban:users');
INSERT INTO perms (perm_name) VALUES ('create:posts');
INSERT INTO perms (perm_name) VALUES ('create:groups');
INSERT INTO perms (perm_name) VALUES ('create:reviews');
INSERT INTO perms (perm_name) VALUES ('create:comments');
INSERT INTO perms (perm_name) VALUES ('request:groups');

-- ----- Roles' Permissions ----- --
-- Owner's Permissions
-- Every permission from 1 to 18
INSERT INTO role_perms (role_id, perm_id) VALUES (1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8), (1, 9), (1, 10), (1, 11), (1, 12), (1, 13), (1, 14), (1, 15), (1, 16), (1, 17), (1, 18);

-- Admin's Permissions
-- Every permission from 2 to 18
INSERT INTO role_perms (role_id, perm_id) VALUES (2, 2), (2, 3), (2, 4), (2, 5), (2, 6), (2, 7), (2, 8), (2, 9), (2, 10), (2, 11), (2, 12), (2, 13), (2, 14), (2, 15), (2, 16), (2, 17), (2, 18);

-- Mod's Permissions
-- [2, 5, 6, 8, 9, 10, 11, 12, 15, 17, 18, 19]
INSERT INTO role_perms (role_id, perm_id) VALUES (3, 2), (3, 5), (3, 6), (3, 8), (3, 9), (3, 10), (3, 11), (3, 12), (3, 15), (3, 17), (3, 18);

-- Affiliate's Permissions
-- The appeal of affiliates is that they can request groups.
-- [2, 5, 10, 15, 17, 18, 19]
INSERT INTO role_perms (role_id, perm_id) VALUES (4, 2), (4, 5), (4, 10), (4, 15), (4, 17), (4, 18);

-- User's Permissions
-- [2, 5, 10, 15, 17, 18]
INSERT INTO role_perms (role_id, perm_id) VALUES (5, 2), (5, 5), (5, 10), (5, 15), (5, 17), (5, 18);

-- ----- Web Skins ----- --
INSERT INTO web_skins (skin_name, primary_color, secondary_color, accent_color, background_color, text_color) VALUES ('Purple Cloud', '#a4a3d4', '#2f2d74', '#514dc8', '#0f0e19', '#e8e8ef');
INSERT INTO web_skins (skin_name, primary_color, secondary_color, accent_color, background_color, text_color) VALUES ('Alternative Cloud', '#d4a3a4', '#742d2d', '#c84d4d', '#190e0e', '#efe8e8');
INSERT INTO web_skins (skin_name, primary_color, secondary_color, accent_color, background_color, text_color) VALUES ('Peru', '#cd96d5', '#793139', '#c37e6a', '#070307', '#f1e1f3');
INSERT INTO web_skins (skin_name, primary_color, secondary_color, accent_color, background_color, text_color) VALUES ('Down to Earth', '#a8d5af', '#37416f', '#7155ac', '#050a06', '#e0f0e2');
INSERT INTO web_skins (skin_name, primary_color, secondary_color, accent_color, background_color, text_color) VALUES ('Grass', '#a4d4a3', '#2d742d', '#4dc851', '#0e190e', '#e8ef8e');
INSERT INTO web_skins (skin_name, primary_color, secondary_color, accent_color, background_color, text_color) VALUES ('Clear Sky', '#95a1d9', '#1d3084', '#2347e8', '#0b0d15', '#ebecf0');

-- ----- Languages ----- --
-- (Only some of them)
INSERT INTO languages (lang_name, lang_code) VALUES ('Inglés', 'en');
INSERT INTO languages (lang_name, lang_code) VALUES ('Japonés', 'jp');
INSERT INTO languages (lang_name, lang_code) VALUES ('Español', 'es');
INSERT INTO languages (lang_name, lang_code) VALUES ('Chino', 'zh');
INSERT INTO languages (lang_name, lang_code) VALUES ('Coreano', 'ko');

-- Adding these just in case, but I doubt anyone will use them.
INSERT INTO languages (lang_name, lang_code) VALUES ('Francés', 'fr');
INSERT INTO languages (lang_name, lang_code) VALUES ('Italiano', 'it');
INSERT INTO languages (lang_name, lang_code) VALUES ('Portugués', 'pt');
INSERT INTO languages (lang_name, lang_code) VALUES ('Ruso', 'ru');

-- ----- Game Length ----- --
INSERT INTO game_lengths (length_name) VALUES ('Muy corto (Menos de 2 horas)');
INSERT INTO game_lengths (length_name) VALUES ('Corto (2 a 10 horas)');
INSERT INTO game_lengths (length_name) VALUES ('Medio (10 a 30 horas)');
INSERT INTO game_lengths (length_name) VALUES ('Largo (30 a 50 horas)');
INSERT INTO game_lengths (length_name) VALUES ('Muy largo (Más de 50 horas)');
INSERT INTO game_lengths (length_name) VALUES ('Desconocido');