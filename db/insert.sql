-- --------------------------------------------------------- --
-- Here, we'll insert some important data into the database. --
-- --------------------------------------------------------- --

-- ----- Roles ----- --
INSERT INTO roles (role_name) VALUES
('Dueño/a'),
('Administrador/a'),
('Moderador/a'),
('Afiliado/a'),
('Usuario/a');

-- ----- Permissions ----- --
INSERT INTO perms (perm_name) VALUES 
('absolute:power'), -- Note that this permission is ONLY for the Owner.
('read:any'), 
('edit:posts'), 
('edit:groups'), 
('edit:own'), 
('delete:posts'), 
('delete:groups'), 
('delete:reviews'), 
('delete:comments'), 
('delete:own'), 
('mute:users'), 
('temp-ban:users'), 
('ban:users'), 
('unban:users'), 
('create:posts'), 
('create:groups'), 
('create:reviews'), 
('create:comments'), 
('request:groups');

-- ----- Roles' Permissions ----- --
-- Owner's Permissions
-- Every permission from 1 to 18
INSERT INTO role_perms (role_id, perm_id)
SELECT 1, perm_id FROM perms WHERE perm_id BETWEEN 1 AND 18;

-- Admin's Permissions
-- Every permission from 2 to 18
INSERT INTO role_perms (role_id, perm_id) 
SELECT 2, perm_id FROM perms WHERE perm_id BETWEEN 2 AND 18;

-- Mod's Permissions
-- [2, 5, 6, 8, 9, 10, 11, 12, 15, 17, 18, 19]
INSERT INTO role_perms (role_id, perm_id) 
VALUES 
(3, 2), (3, 5), (3, 6), (3, 8), (3, 9),
(3, 10), (3, 11), (3, 12), (3, 15), (3, 17), (3, 18);

-- Affiliate's Permissions
-- The appeal of affiliates (at least for now) is that they can request groups.
-- [2, 5, 10, 15, 17, 18, 19]
INSERT INTO role_perms (role_id, perm_id)
VALUES 
(4, 2), (4, 5), (4, 10), (4, 15), (4, 17), (4, 18);

-- User's Permissions
-- [2, 5, 10, 15, 17, 18]
INSERT INTO role_perms (role_id, perm_id)
VALUES
(5, 2), (5, 5), (5, 10), (5, 15), (5, 17), (5, 18);

-- ----- Web Skins ----- --
INSERT INTO web_skins (skin_name, primary_color, secondary_color, accent_color, background_color, text_color) VALUES 
('Purple Cloud', '#a4a3d4', '#2f2d74', '#514dc8', '#0f0e19', '#e8e8ef'),
('Alternative Cloud', '#d4a3a4', '#742d2d', '#c84d4d', '#190e0e', '#efe8e8'),
('Peru', '#cd96d5', '#793139', '#c37e6a', '#070307', '#f1e1f3'),
('Down to Earth', '#a8d5af', '#37416f', '#7155ac', '#050a06', '#e0f0e2'),
('Grass', '#a4d4a3', '#2d742d', '#4dc851', '#0e190e', '#e8ef8e'),
('Clear Sky', '#95a1d9', '#1d3084', '#2347e8', '#0b0d15', '#ebecf0');

-- ----- Languages ----- --
-- (Only some of them)
INSERT INTO languages (lang_name, lang_code) VALUES
('Inglés', 'en'),
('Japonés', 'jp'),
('Español', 'es'),
('Chino', 'zh'),
('Coreano', 'ko'), 
('Francés', 'fr'),
('Italiano', 'it'),
('Portugués', 'pt'),
('Ruso', 'ru');

-- ----- Game Length ----- --
INSERT INTO game_lengths (length_name) VALUES
('Muy corto (Menos de 2 horas)'),
('Corto (2 a 10 horas)'),
('Medio (10 a 30 horas)'),
('Largo (30 a 50 horas)'),
('Muy largo (Más de 50 horas)'),
('Desconocido');