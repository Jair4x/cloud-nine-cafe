# Base de Datos / Database

# Español

#### [English ver.](#English)

## Información General

Antes de nada, vamos a aclarar un par de cosas que seguro deberías saber:

1. **El motor de base de datos que usará el proyecto es ~~MariaDB~~ PostgreSQL**. ~~Originalmente, tenía planeado que fuera PostgreSQL, pero por limitaciones con el Hosting, me vi obligado a pasarlo todo para MySQL.~~ <u>Sorpresivamente, obtuve una VPS de Oracle con capacidad y potencia suficiente para poder hostear las APIs y la base de datos sin problema alguno.</u>
2. En las APIs, la base de datos será manejada mediante Sequelize, una librería ORM (Object-Relational Mapping). ¿No sabes lo que es? Yo tampoco, pero sirve para manejar bases de datos mediante código. 👍

## Modelos
**Nota**: Cada modelo tiene una propiedad `hidden` y una propiedad `locked`, las cuales son inspiradas en el schema oficial de VNDB, que usa estas propiedades.

Moderación/Aprobación pendiente:
`hidden` = true
`locked` = false

Bloqueado/a:
`hidden` = false
`locked` = true

Eliminado/a:
`hidden` = true
`locked` = true

Normal (accesible por todos):
`hidden` = false
`locked` = false

### Historiales y Flags

En lugar de tener tablas redundantes como extra de cada modelo, se hizo un modelo específico para el manejo de los historiales y las flags de una entidad.

**Tablas**
```
change_history:
id - int
entity_type - enum ('User', 'TLGroup', 'Post', 'Comment', 'Review')
entity_id - id (ID de la entidad afectada)
field_changed - varchar
old_value - text
new_value - text
changed_by - int (de la tabla users)
change_date - date

report_history:
entity_type - enum ('User', 'TLGroup', 'Post', 'Comment', 'Review')
entity_id - int (ID de la entidad reportada)
reporter_id - int (de la tabla users)
reason - text
report_date - date

entity_flags:
entity_type - enum ('Post', 'Comment', 'Review', 'Group')
entity_id - int (ID de la entidad)
hidden - boolean
locked - boolean
reports - smallint -- No sé si voy a dejar esto, realmente. Es algo que probablemente pueda buscar con una consulta a report_history, pero por ahora dejémoslo ahí.
```


### Usuarios (users)

Cada usuario tiene un perfil, cuyo URL base es `/u{ID}`.
*(Por ejemplo: `cafecloudnine.com/u420`*)

`/u{ID}/preferences`  es la página de configuración del usuario y solo puede ser accedido por el dueño de la cuenta con ese ID.
Las secciones de las preferencias serán puestas como `/u{ID}/preferences?s={section}`.

**Tablas**
```
users:
id - int
username - varchar
display_name - varchar
email - varchar
is_email_verified - boolean
avatar - varchar
status - enum
password - text
registered - date

users_preferences:
user_id - int (de la tabla users)
bio - text
bio_hidden - boolean
tl_group - int (de la tabla tl_groups)
twitter - varchar (tiene que verse como `@user`)
twitter_hidden - boolean
discord - varchar (tiene que verse como `@user`)
discord_hidden - boolean
web_skin - smallint (de la tabla web_skins)

users_role:
user_id - int (de la tabla users)
role_id - int (de la tabla roles)
```

**Historiales específicos**
```
user_password_hist:
user_id - int (de la tabla users)
change_date - date

users_moderation_logs:
user_id - int (de la tabla users)
mod_id - int (de la tabla users)
mod_action - enum
reason - text
until - date -- En caso de muteos o bans temporales
action_date - date
```

### Sesiones (sessions)

Este proyecto manejará JWT (Json Web Tokens), si no sabes lo que son, puedes ser feliz.

**Tabla**
```
users_sessions:
user_id - int (de la tabla users)
session_id - text
expires - date
```

#### Skins de Página (web_skins)

La página tendrá algunos esquemas de colores que el usuario puede elegir al usar la plataforma.
Es del lado del cliente, así que los demás no sabrán qué esquema de colores usas.

**Tabla**
```
web_skins:
id - int
name - varchar
primary_color - varchar (debe verse como `#rrggbb`)
secondary_color - varchar (debe verse como `#rrggbb`)
accent_color - varchar (debe verse como `#rrggbb`)
background_color - varchar (debe verse como `#rrggbb`)
text_color - varchar (debe verse como `#rrggbb`)
```

#### Roles (roles)

Es bastante obvio que la plataforma va a necesitar moderación y otras cosas para prevenir cosas que no queremos que pasen, así que agregaremos roles.

**Tablas**
```
roles:
id - int
role_name - varchar

roles_perms:
role_id - int (de la tabla roles)
perm_id - int (de la tabla perms)
```

#### Permisos (perms)

Si tenemos roles, necesitamos permisos, sin ellos, la plataforma probablemente sería un desastre.

**Tabla**
```
perms:
id - int
perm_name - varchar
```

### Grupos de Traducción (tl_groups)

Cada grupo tiene un perfil, cuyo URL base es `/g{ID}`.
*(Por ejemplo: `cafecloudnine.com/g69`*)

Sin embargo, las mismas tienen un apartado `g{ID}/config` que contiene la configuración del grupo como los aliases, los idiomas que traducen o los miembros del grupo.
La misma, al igual que con los usuarios, tiene un apartado `g{ID}/config?s={section}`, donde estará la configuración de la sección en específico.

**Tablas**
```
tl_groups:
id - int
owner_id - int
name - varchar
latin_name - varchar -- En caso de que el nombre use caracteres no provenientes del latin, será el nombre que se mostrará de todas formas.
description - text
status - enum ("Activo" o "Q.E.P.D")

translations:
id - int
post_id - int (de la tabla posts)
group_id - int (de la tabla tl_groups)

tl_groups_metadata:
group_id - int (de la tabla tl_groups)
alias_1 - varchar
alias_2 - varchar
alias_3 - varchar
facebook - varchar (debe verse como `/group`)
twitter - varchar (debe verse como `@user`)
discord - varchar (debe verse como `.gg/invite`)
website - varchar (debe ser una URL)
language_1 - varchar (de la tabla languages)
language_2 - varchar (de la tabla languages)
language_3 - varchar (de la tabla languages)

tl_groups_members:
group_id - int (de la tabla tl_groups)
user_id - int (de la tabla users) -- Si es un usuario registrado
name - varchar -- Si no está registrado en la plataforma
role - enum ('Dueño/a', 'Editor/a de imágenes', 'Corrector/a', 'Traductor/a', 'Programador/a') -- El dueño debe estar registrado sí o sí.

-- Actualizaciones en la página del grupo en la plataforma
tl_groups_updates:
id - int
group_id - int (de la tabla tl_groups)
user_id - int (de la tabla users)
post_date - date
content - text
hidden - boolean
locked - boolean
```

**Historiales específicos**
```
tl_groups_alias_hist:
group_id - int (de la tabla tl_groups)
change_date - date
old_1 - varchar
old_2 - varchar
old_3 - varchar
new_1 - varchar
new_2 - varchar
new_3 - varchar

tl_groups_members_hist:
group_id - int (de la tabla tl_groups)
user_id - int (de la tabla users)
change_date - date
action - enum ('Añadido', 'Editado', 'Eliminado')
member_id - int (de la tabla users) -- Si es un usuario registrado
member_name - varchar -- Si no está registrado en la plataforma
role - enum ('Dueño/a', 'Editor/a de imágenes', 'Corrector/a', 'Traductor/a', 'Programador/a') -- El dueño debe estar registrado sí o sí.

tl_groups_updates_hist:
update_id - int (de la tabla tl_groups_updates)
change_date - date
old_content - text
new_content - text
hidden - boolean
locked - boolean

tl_groups_moderation_logs:
group_id - int (de la tabla tl_groups)
mod_id - int (de la tabla users)
action_date - date
reason - text
locked - boolean
hidden - boolean
```

#### Lenguajes (languages)

Para organizar los lenguajes para futuras actualizaciones.

**Tabla**
```
languages:
lang_code - varchar
lang_name - varchar
```

##### Largo de la novela (game_length)
Por ahora, el largo de las novelas se miden en 5 valores:

1 = "Muy corto" (Menos de 2 horas)
2 = "Corto" (Entre 2 y 10 horas)
3 = "Medio" (Entre 10 y 30 horas)
4 = "Largo" (Entre 30 y 50 horas)
5 = "Muy largo" (Más de 50 horas)

**Tabla**
```
game_length:
id - int
length_name - varchar
```

### Posts (posts)

URL base: `/p{ID}`.
Ejemplo: `cafecloudnine.com/p321`

**Tablas**
```
posts:
id - int
op_id - int (de la tabla users)
publish_date - date
translated_from - varchar (de la tabla languages)
cover_image - varchar
title - varchar
download_link - varchar
download_note - text

posts_aliases:
post_id - int (de la tabla posts)
alias - varchar

posts_details:
post_id - int (de la tabla posts)
sinopsis - text
game_length - smallint (de la tabla game_length)
classification - enum -- "All ages", "13+", "16+" o "18+"
tl_type - enum -- "MTL", "MTL editado" or "Manual"
tl_status - enum -- "En progreso", "Completada", "Pausada" o "Cancelada"
tl_scope - enum -- "Completa" or "Parcial"
tl_platform - enum -- "PC", "Android" u "Otros"
buy_link - JSON ("plataforma": "Steam", "link": "https://...") -- "Steam", "Itch.io", "DLSite", "Mangagamer", etc...

posts_tl_progress:
post_id - int (de la tabla posts)
tl_percentage - smallint
tl_section - enum -- "Traduciendo", "Corrigiendo", "Corrigiendo", "Reinsertando" o "Testeando"
```

**Historiales específicos**
```
No hay.
```

### Comentarios (comments)

Estos pueden estar dentro de:
- Posts
- Reseñas
- Actualizaciones de grupos
URL base: `/p{ID]/c{ID]`
Ejemplo: `cafecloudnine.com/p420/c69`

**Tablas**
```
comments:
id - int
parent_id - int (de la tabla comments)
post_id - int (de la tabla posts)
poster_id - int (de la tabla users)
content - varchar -- Limitado a alrededor de 250 caracteres
votes - int -- Basado en un conteo de votos de comments_votes
date - date

comments_votes:
comment_id - int (de la tabla comments)
user_id - int (de la tabla users)
vote - enum -- "Up" o "Down"
```

**Historiales específicos**
```
comments_moderation_logs:
comment_id - int (de la tabla comments)
mod_id - int (de la tabla users)
action_date - date
reason - text
locked - boolean
hidden - boolean
```

### Reseñas (reviews)

Estas **no** son reseñas sobre las traducciones, sino de las novelas en sí.
URL base: `/p{ID}/r{ID}`
Ejemplo: `cafecloudnine.com/p69/r420`

**Tablas**
```
reviews:
id - int
post_id - int (de la tabla posts)
user_id - int (de la tabla users)
content - text
rating - smallint -- 1 ("Una mierd*") to 5 ("A LA MIERD*, ES BUENÍSIMO")
votes - int
attachments - JSON -- ["https://...", "https://..."]
date - date

reviews_votes:
review_id - int (de la tabla reviews)
user_id - int (de la tabla users)
vote - enum -- "Up" o "Down"
```

**Historiales específicos**
```
reviews_attachments_hist:
review_id - int (de la tabla reviews)
change_date - date
action - enum -- "Agregado" o "Eliminado"
attachment - varchar

reviews_moderation_logs:
review_id - int (de la tabla reviews)
mod_id - int (de la tabla users)
action_date - date
reason - text
hidden - boolean
locked - boolean
```

# English

#### [Ver. Español](#Español)

## General Information

Before anything, let's get some things straight that you should know:

1. **The database engine this project will use is ~~MariaDB~~ PostgreSQL**. ~~Now, originally, it was planned to use PostgreSQL, but because of Hosting limitations, I was forced to change everything to MariaDB.~~ Surprisingly, I got ahold of a VPS from Oracle after some fighting for it. So now I host the database in there with PostgreSQL and the APIs without any problem.
2. In the APIs, the database'll be managed using Sequelize, an ORM library (Object-Relational Mapping). What? You don't know what that is? Me neither, but it works as something to manage databases using code. 👍

## Models

Values here (specially for ENUMs) are on english for the sake of documentation and for english readers to understand. However, the SQL will be using the spanish values for ENUMs and other values.

Another thing to **note**, though: Every model has a `locked` and `hidden` property, inspired by the official schema of VNDB, which uses the same properties.

Moderation/Approval needed:
`hidden` = true
`locked` = false

Locked:
`hidden` = false
`locked` = true

Deleted:
`hidden` = true
`locked` = true

Normal (accessible by anyone):
`hidden` = false
`locked` = false

### Histories and Flags

Instead of making a lot of tables as an extra in each model, a specific model was made to manage an entity's history and flags.

**Tables**
```
change_history:
id - int
entity_type - enum ('User', 'TLGroup', 'Post', 'Comment', 'Review')
entity_id - id (Affected Entity ID)
field_changed - varchar
old_value - text
new_value - text
changed_by - int (from the users table)
change_date - date

report_history:
entity_type - enum ('User', 'TLGroup', 'Post', 'Comment', 'Review')
entity_id - int (Reported Entity ID)
reporter_id - int (from the users table)
reason - text
report_date - date

entity_flags:
entity_type - enum ('Post', 'Comment', 'Review', 'Group')
entity_id - int (Entity ID)
hidden - boolean
locked - boolean
reports - smallint -- I don't know if I'll leave this, really. It's something that can probably be obtained by a query to the report_history table, but for now, let's leave it as is.
```


### Users (users)

Users have some details that I'll explain here.

First, each user has a profile, whose base url is `/u{ID}`.
_(Example: `cafecloudnine.com/u420`)_

`/u{ID}/preferences` can only be accessed by the owner of the account with that ID.
The same goes for the subroutes `/u{ID}/preferences?s={section}`.

**Tables**
```
users:
id - int
username - varchar
display_name - varchar
email - varchar
is_email_verified - boolean
avatar - varchar
status - enum
password - text
registered - date

users_preferences:
user_id - int (from the users table)
bio - text
bio_hidden - boolean
tl_group - int (from the tl_groups table)
twitter - varchar (has to be like `@user`)
twitter_hidden - boolean
discord - varchar (has to be like `@user`)
discord_hidden - boolean
web_skin - smallint (from the web_skins table)

users_role:
user_id - int (from the users table)
role_id - int (from the roles table)
```

**Specific History tables**
```
user_password_hist:
user_id - int (de la tabla users)
change_date - date

users_moderation_logs:
user_id - int (de la tabla users)
mod_id - int (de la tabla users)
mod_action - enum
reason - text
until - date -- In case of mutes or temporary bans
action_date - date
```

#### Website Skins (web_skins)

The website will have some color schemes the user can choose when using the platform.
This is client-side, so the others won't know what color scheme you use.

**Table**
```
web_skins:
id - int
name - varchar
primary_color - varchar (must look like `#rrggbb`)
secondary_color - varchar (must look like `#rrggbb`)
accent_color - varchar (must look like `#rrggbb`)
background_color - varchar (must look like `#rrggbb`)
text_color - varchar (must look like `#rrggbb`)
```

#### Roles (roles)

It's fairly obvious that the platform will need moderation and other stuff to prevent things we don't want to happen, so we'll add roles.

**Tables**
```
roles:
id - int
name - varchar

roles_perms:
role_id - int (from roles table)
perm_id - int (from perms table)
```

#### Permissions (perms)

If we have roles, we need permissions, without them, the platform would probably be a disaster.

**Table**
```
perms:
id - int
name - varchar
```

### Translation Groups (tl_groups)

Every group has a profile, whose base URL is `/g{ID}`.
*(For example: `cafecloudnine.com/g69`*)

However, the groups have a section `g{ID}/config` that has config for the group, such as the aliases, the languages they translate from and the group members.
Same as the users, it has subroutes from `g{ID}/config?s={section}`, where a specific section is located.

**Tables**
```
tl_groups:
id - int
owner_id - int
name - varchar
latin_name - varchar -- In case the name uses non-latin characters. Will be the first name shown regardless.
description - text
status - enum -- "Active" or "R.I.P"

translations:
id - int
post_id - int (from posts table)
group_id - int (from tl_groups table)

-- Groups can only have 3 aliases at most for now.
tl_groups_metadata:
group_id - int (from tl_groups table)
alias_1 - varchar
alias_2 - varchar
alias_3 - varchar
facebook - varchar (must look like `/group`)
twitter - varchar (must look like `@user`)
discord - varchar (must look like `.gg/invite`)
website - varchar (must be URL)
language1 - varchar (from languages table)
language_2 - varchar (from languages table)
language_3 - varchar (from languages table)

tl_groups_members:
group_id - int (from tl_groups table)
user_id - int (from users table) -- If it's a registered user
name - varchar -- In case the member didn't register in the platform
role - enum -- 'Owner', 'Image Editor', 'Editor', 'Translator' or 'Programmer'. // Owners need to be registered.

-- Updates on the timeline of the group
tl_groups_updates:
id - int
group_id - int (from tl_groups table)
user_id - int (from users table)
post_date - date
content - text
hidden - boolean
locked - boolean
```

**Specific Histories**
```
tl_groups_alias_hist:
group_id - int (from tl_groups table)
when - date
old_1 - varchar
old_2 - varchar
old_3 - varchar
new_1 - varchar
new_2 - varchar
new_3 - varchar

tl_groups_members_hist:
group_id - int (from tl_groups table)
user_id - int (from users table)
change_date - date
action - enum
member_id - int (from users table) -- If it's a registered user
member_name - varchar -- If it isn't a registered user
role - enum -- 'Dueño/a', 'Editor/a de imágenes', 'Corrector/a', 'Traductor/a' or 'Programador/a'. // Dueños/as need to be registered.

tl_groups_updates_hist:
update_id - int (from tl_groups_updates table)
change_date - date
old_content - text
new_content - text
hidden - boolean
locked - boolean

tl_groups_moderation_logs:
group_id - int (from tl_groups table)
mod_id - int (from users table)
action_date - date
reason - text
locked - boolean
hidden - boolean
```

#### Languages (languages)

Languages for posts and groups.

**Tables**
```
languages:
id - int
name - varchar
```

##### Novel's length (game_length)
For now, the length of a novel is measured in 5 values:

1 = "Very short" (Less than 2 hours)
2 = "Short" (Between 2 and 10 hours)
3 = "Medium" (Between 10 and 30 hours)
4 = "Long" (Between 30 and 50 hours)
5 = "Very long" (More than 50 hours)
```
game_length:
id - int
name - varchar
```

### Posts (posts)

Base URL: `/p{ID]`
Example: `cafecloudnine.com/p420`

**Tables**
```
posts:
id - int
op_id - int (from users table)
published - date
translated_from - varchar (from languages table)
cover_image - varchar
title - varchar
download_link - varchar
download_note - text

posts_aliases:
post_id - int (from posts table)
alias - varchar

posts_details:
post_id - int (from posts table)
sinopsis - text
game_length - smallint (from game_length table)
classification - enum -- 'All ages', '13+', '16+' or '18+'
tl_type - enum -- "MTL", "Edited MTL" or "Manual Translation"
tl_status - enum -- "In progress", "Completed", "Paused" or "Cancelled"
tl_scope - enum -- "Complete Translation" or "Partial Translation"
tl_platform - enum -- "PC", "Android" or "Others"
buy_link - JSON -- Something like [{"platform":"Steam", "link":"https://..."}, {"platform":"Itch.io", "link":"https://..."}]

posts_tl_progress:
post_id - int (from posts table)
tl_percentage - smallint
tl_section - enum -- "Translating", "Editing", "Images and Menu", "Reinserting" or "Testing"
```

**Specific Histories**
```
There isn't.
```

### Comments (comments)

These can be inside:
- Posts
- Reviews
- Group updates
Base URL: `/{p/u/r}{ID}/c{ID]`
Examples: `cafecloudnine.com/p420/c69`, `cafecloudnine.com/u42/c70`

**Tables**
```
comments:
id - int
parent_id - int (from comments table)
post_id - int (from posts table)
poster_id - int (from users table)
content - varchar -- Limited at around 250 characters
votes - int
date - date

comments_votes:
comment_id - int (from comments table)
user_id - int (from users table)
vote - enum -- "Up" or "Down"
```

**Specific Histories**
```
comments_moderation_logs:
comment_id - int (from comments table)
mod_id - int (from users table)
action_date - date
reason - text
locked - boolean
hidden - boolean
```

### Reviews (reviews)

Note: These are **not** translation reviews, but rather reviews for the visual novels themselves.
Base URL: `/p{ID}/r{ID}`
Example: `cafecloudnine.com/p69/r420`

**Tables**
```
reviews:
id - int
post_id - int (from posts table)
user_id - int (from users table)
content - text
rating - smallint -- 1 ("Utter bullsh*t") to 5 ("HOLY SH*T THIS IS AMAZING")
votes - int

reviews_votes:
review_id - int (from reviews table)
user_id - int (from users table)
vote - enum -- "Up" or "Down"
```

**Specific Histories**
```
reviews_attachments_hist:
review_id - int (from reviews table)
change_date - date
action - enum -- "Added" or "Deleted"
attachment - varchar

reviews_moderation_logs:
review_id - int (from reviews table)
mod_id - int (from users table)
action_date - date
reason - text
hidden - boolean
locked - boolean
```
