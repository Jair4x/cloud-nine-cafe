# Base de Datos / Database

# Español

#### [English ver.](#English)

## Información General

Antes de nada, vamos a aclarar un par de cosas que seguro deberías saber:

1. **El motor de base de datos que usará el proyecto es MariaDB (MySQL)**. Originalmente, tenía planeado que fuera PostgreSQL, pero por limitaciones con el Hosting (Hostinger no acepta PostgreSQL como motor de base de datos en un plan de hosting web), me vi obligado a pasarlo todo para MySQL.
2. En las APIs, la base de datos será manejada mediante Sequelize, una librería ORM (Object-Relational Mapping). ¿No sabes lo que es? Yo tampoco, pero sirve para manejar bases de datos mediante código. 👍

## Modelos

¿Cómo deberían ser los modelos?
Los cuatro (o cinco) principales actualmente son:

-   Usuarios
-   Grupos de traducción (Conjunto de usuarios y no usuarios)
-   Posts (Parches de Novelas Visuales)
-   Comentarios
-   Reseñas (Dentro de dichos posts, son sobre las novelas, no de las traducciones)

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

### Usuarios (users)

Los usuarios tienen algunos detales que voy a explicar aquí.

Primero, cada usuario tiene un perfil, cuyo URL base es `/u{ID}`.
*(Por ejemplo: `cafecloudnine.com/u420`*

`/u{ID}/preferences` solo puede ser accedido por el dueño de la cuenta con ese ID exacto.
Lo mismo va con las subrutas `/u{ID}/preferences/{section}`.

**Definir cosas**
```
users:
id - int
username - varchar
display_name - varchar
email_verified - boolean
avatar - varchar
status - enum
registered - date

users_extras:
user_id - int (de la tabla users)
bio - text
tl_group - int (de la tabla tl_groups)
twitter - varchar (tiene que verse como `@user`)
discord - varchar (tiene que verse como `@user`)

users_web_prefs:
user_id - int (de la tabla users)
web_skin - smallint (de la tabla web_skins)

users_role:
user_id - int (de la tabla users)
role - int (de la tabla roles)

users_hidden_info:
user_id - int (de la tabla users)
email - varchar
password - text (encriptada y salteada)
reports - smallint 

users_reports:
user_id - int (de la tabla users)
reporter_id - int (de la tabla users)
when - date
reason - text

users_extras_privacy:
user_id - int
bio_hidden - boolean
twitter_hidden - boolean
discord_hidden - boolean
```

**Historial de cambios en la cuenta**
```
users_email_hist:
id - int
when - date
old - varchar
new - varchar

user_username_hist:
id - int
when - date
old - varchar
new - varchar

user_password_hist:
id - int
when - date

users_bans:
id - int
reason - text
when - date
until - date -- null si es permanente
```

#### Skins de Página (web_skins)
La página tendrá algunos esquemas de colores que el usuario puede elegir al usar la plataforma.
Es del lado del cliente, así que los demás no sabrán qué esquema de colores usas.
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
```
roles:
id - int
name - varchar

roles_perms:
role_id - int (de la tabla roles)
perm_id - int (de la tabla perms)
```

#### Permisos (perms)
Si tenemos roles, necesitamos permisos, sin ellos, la plataforma probablemente sería un desastre.
```
perms:
id - int
name - varchar
```


### Grupos de Traducción (tl_groups)
**Definir cosas**
```
tl_groups:
id - int
owner_id - int
name - varchar
latin_name - varchar -- En caso de que el nombre use caracteres no provenientes del latin, será el nombre que se mostrará de todas formas.
description - text
status - enum ("Activo" o "Q.E.P.D")

-- Los grupos pueden tener 3 aliases máximo por ahora.
tl_groups_alias:
group_id - int (de la tabla tl_groups)
alias_1 - varchar
alias_2 - varchar
alias_3 - varchar

tl_groups_socials:
group_id - int (de la tabla tl_groups)
facebook - varchar (debe verse como `/group`)
twitter - varchar (debe verse como `@user`)
discord - varchar (debe verse como `.gg/invite`)
website - varchar (debe ser una URL)

tl_groups_languages:
group_id - int (de la tabla tl_groups)
language_id_1 - int (de la tabla languages)
language_id_2 - int (de la tabla languages)
language_id_3 - int (de la tabla languages)

tl_groups_members:
group_id - int (de la tabla tl_groups)
user_id - int (de la tabla users) -- Si es un usuario registrado
name - varchar -- Si no está registrado en la plataforma
role - enum

tl_groups_translations:
group_id - int (de la tabla tl_groups)
post_id - int (de la tabla posts)

-- Actualizaciones en la página del grupo en la plataforma
tl_groups_updates:
id - int
group_id - int (de la tabla tl_groups)
user_id - int (de la tabla users)
when - date
content - text
hidden - boolean
locked - boolean

tl_groups_hidden_data:
group_id - int (de la tabla tl_groups)
reports - smallint
hidden - boolean
locked - boolean

tl_groups_reports:
group_id - int (de la tabla tl_groups)
reporter_id - int (de la tabla users)
when - date
reason - text
```

**Historial de cambios de Grupo**
```
tl_groups_name_hist:
group_id - int (de la tabla tl_groups)
when - date
old - varchar
new - varchar

tl_groups_latin_name_hist:
group_id - int (de la tabla tl_groups)
when - date
old - varchar
new - varchar

tl_groups_alias_hist:
group_id - int (de la tabla tl_groups)
when - date
old_1 - varchar
old_2 - varchar
old_3 - varchar
new_1 - varchar
new_2 - varchar
new_3 - varchar

tl_groups_description_hist:
group_id - int (de la tabla tl_groups)
when - date
old - text
new - text

tl_groups_language_hist:
group_id - int (de la tabla tl_groups)
when - date
old_1 - varchar
old_2 - varchar
old_3 - varchar
new_1 - varchar
new_2 - varchar
new_3 - varchar

tl_groups_status_hist:
group_id - int (de la tabla tl_groups)
when - date
old - enum
new - enum

tl_groups_members_hist:
group_id - int (de la tabla tl_groups)
user_id - int (de la tabla users)
when - date
action - enum
member_id - int (de la tabla users) -- Si es un usuario registrado
member_name - varchar -- Si no está registrado en la plataforma

tl_groups_translations_hist:
group_id - int (de la tabla tl_groups)
when - date
type - varchar (agregar, eliminar)
post_id - int

tl_groups_updates_hist:
update_id - int (de la tabla tl_groups_updates)
when - date
old_content - text
new_content - text
hidden - boolean
locked - boolean

tl_groups_mod_hist:
group_id - int (de la tabla tl_groups)
mod_id - int (de la tabla users)
when - date
reason - text
locked - boolean
hidden - boolean
```

#### Lenguajes (languages)
Para organizar los lenguajes para futuras actualizaciones.
```
languages:
id - int
name - varchar
```


### Posts (posts)

**Definir cosas**
```
posts:
id - int
op_id - int (de la tabla users)
published - date
translated_from - int (de la tabla languages)
cover_image - varchar
title - varchar
download_link - varchar
download_note - text

posts_translators:
post_id - int (de la tabla posts)
group_id - int (de la tabla  tl_groups)

posts_aliases:
post_id - int (de la tabla posts)
alias - varchar

posts_details:
post_id - int (de la tabla posts)
sinopsis - text
game_length - smallint (de la tabla game_length)
classification - enum
tl_type - enum -- "MTL", "MTL editado" or "Manual"
tl_status - enum -- "En progreso", "Completada", "Pausada" or "Cancelada"
tl_scope - enum -- "Completa" or "Parcial"
tl_platform - enum -- "PC", "Android" u "Otros"

posts_buy_links:
post_id - int (de la tabla posts)
platform - enum -- "Steam", "Itch.io", "DLSite", "Mangagamer", etc...
link - varchar

posts_tl_progress:
post_id - int (de la tabla posts)
tl_percentage - smallint
tl_section - enum -- "Traduciendo", "Corrigiendo", "Corrigiendo", "Reinsertando" or "Testeando"

posts_hidden_data:
post_id - int (de la tabla posts)
locked - boolean
hidden - boolean
reports - smallint

posts_reports:
post_id - int (de la tabla posts)
user_id - int (de la tabla users)
reason - text
```

##### Largo de la novela (game_length)
Por ahora, el largo de las novelas se miden en 5 valores:

1 = "Muy corto" (Menos de 2 horas)
2 = "Corto" (Entre 2 y 10 horas)
3 = "Medio" (Entre 10 y 30 horas)
4 = "Largo" (Entre 30 y 50 horas)
5 = "Muy largo" (Más de 50 horas)
```
game_length:
id - int
name - varchar
```


**Historial de cambios en Posts**
```
posts_title_hist:
post_id - int (de la tabla posts)
when - date
old - varchar
new - varchar

posts_download_link_hist:
post_id - int (de la tabla posts)
when - date
old - varchar
new - varchar

posts_cover_image_hist:
post_id - int (de la tabla posts)
when - date
old - varchar
new - varchar

posts_sinopsis_hist:
post_id - int (de la tabla posts)
when - date
old - text
new - text

posts_length_hist:
post_id - int (de la tabla posts)
when - date
old - smallint (de la tabla game_length)
new - smallint (de la tabla game_length)

posts_buy_links_hist:
post_id - int (de la tabla posts)
when - date
action - enum 
platform - enum
link - varchar
```

### Comentarios (comments)

**Definir cosas**
```
comments:
id - int
parent_id - int (de la tabla comments)
post_id - int (de la tabla posts)
poster_id - int (de la tabla users)
content - varchar -- Limitado a alrededor de 250 caracteres
votes - int
date - date

comments_votes:
comment_id - int (de la tabla comments)
user_id - int (de la tabla users)
vote - enum -- "Up" o "Down"

comments_hidden_data:
comment_id - int (de la tabla comments)
locked - boolean
hidden - boolean
reports - smallint

comments_reports:
comment_id - int (de la tabla comments)
user_id - int (de la tabla users)
```

**Historial de cambios de comentario**
```
comments_content_hist:
comment_id - int (de la tabla comments)
when - date
old - text
new - text

comments_mod_hist:
comment_id - int (de la tabla comments)
mod_id - int (de la tabla users)
when - date
reason - text
locked - boolean
hidden - boolean
```

### Reseñas (reviews)
Nota: Estas **no** son reseñas sobre las traducciones, sino de las novelas en sí.

**Definir**
```
reviews:
id - int
post_id - int (de la tabla posts)
user_id - int (de la tabla users)
content - text
rating - smallint -- 1 ("Una mierd*") to 5 ("A LA MIERD*, ES BUENÍSIMO")
votes - int

reviews_attachments:
review_id - int (de la tabla reviews)
attachment - varchar

reviews_votes:
review_id - int (de la tabla reviews)
user_id - int (de la tabla users)
vote - enum -- "Up" o "Down"

reviews_hidden_data:
review_id - int (de la tabla reviews)
locked - boolean
hidden - boolean
reports - smallint

reviews_reports:
review_id - int (de la tabla reviews)
user_id - int (de la tabla users)
reason - text
```

**Historial de cambios de reseña**
```
reviews_content_hist:
review_id - int (de la tabla reviews)
when - date
old - varchar
new - varchar

reviews_rating_hist:
review_id - int (de la tabla reviews)
date - date
old - smallint
new - smallint

reviews_attachments_hist:
review_id - int (de la tabla reviews)
when - date
action - enum -- "Agregado" o "Eliminado"
attachment - varchar

reviews_mod_hist:
review_id - int (de la tabla reviews)
mod_id - int (de la tabla users)
when - date
reason - text
hidden - boolean
locked - boolean
```

# English

#### [Ver. Español](#Español)

## General Information

Before anything, let's get some things straight that you should know:

1. **The database engine this project will use is MariaDB (MySQL)**. Now, originally, it was planned to use PostgreSQL, but because of Hosting limitation (Hostinger doesn't let you use PostgreSQL as a database engine for web hosting plans) I was forced to change everything to MySQL.
2. In the APIs, the database'll be managed using Sequelize, an ORM library (Object-Relational Mapping). What? You don't know what that is? Me neither, but it works as something to manage databases using code. 👍

## Models

Right now, the five main models are:

-   Users
-   Translation Groups (Has users and not-users)
-   Posts (Visual Novel Patches)
-   Comments
-   Reviews (Inside posts, about the visual novel, not the translation)

One thing to **note**, though: Every model has a `locked` and `hidden` property, inspired by the official schema of VNDB, which uses the same properties.

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

### Users (users)

Users have some details that I'll explain here.

First, each user has a profile, whose base url is `/u{ID}`.
_(Example: `cafecloudnine.com/u420`)_

`/u{ID}/preferences` can only be accessed by the owner of the account with that exact ID. The same goes for the subroutes `/u{ID}/preferences/{section}`.

**Define stuff**
```
users:
id - int
username - varchar
display_name - varchar
email_verified - boolean
avatar - varchar
status - enum
registered - date

users_extras:
user_id - int (from users table)
bio - text
tl_group - int (from tl_groups table)
twitter - varchar (must look like `@user`)
discord - varchar (must look like `@user`)

users_web_prefs:
user_id - int (from users table)
web_skin - smallint (from web_skins table)

users_role:
user_id - int (from users table)
role - int (from roles table)

users_hidden_info:
user_id - int (from users table)
email - varchar
password - text (encrypted and salted)
reports - smallint 

users_reports:
user_id - int (from users table)
reporter_id - int (from users table)
when - date
reason - text

users_extras_privacy:
user_id - int
bio_hidden - boolean
twitter_hidden - boolean
discord_hidden - boolean
```

**Account changes history**
```
users_email_hist:
id - int
when - date
old - varchar
new - varchar

user_username_hist:
id - int
when - date
old - varchar
new - varchar

user_password_hist:
id - int
when - date

users_bans:
id - int
reason - text
when - date
until - date -- null if permanent
```


#### Website Skins (web_skins)
The website will have some color schemes the user can choose when using the platform.
This is client-side, so the others won't know what color scheme you use.
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
```
roles:
id - int
name - varchar

roles_perms:
role_id - int (from roles table)
perm_id - int (from perms table)
```

#### Permissions (perms)
If we have roles, we need permissions, without them, the platform would proably be a disaster.
```
perms:
id - int
name - varchar
```


### Translation Groups (tl_groups)
**Define stuff**
```
tl_groups:
id - int
owner_id - int
name - varchar
latin_name - varchar -- In case the name uses non-latin characters. Will be the first name shown regardless.
description - text
status - enum ("Activo" or "Q.E.P.D")

-- Groups can only have 3 aliases at most for now.
tl_groups_alias:
group_id - int (from tl_groups table)
alias_1 - varchar
alias_2 - varchar
alias_3 - varchar

tl_groups_socials:
group_id - int (from tl_groups table)
facebook - varchar (must look like `/group`)
twitter - varchar (must look like `@user`)
discord - varchar (must look like `.gg/invite`)
website - varchar (must be URL)

tl_groups_languages:
group_id - int (from tl_groups table)
language_id_1 - int (from languages table)
language_id_2 - int (from languages table)
language_id_3 - int (from languages table)

tl_groups_members:
group_id - int (from tl_groups table)
user_id - int (from users table) -- If it's a registered user
name - varchar -- In case the member didn't register in the platform
role - enum

tl_groups_translations:
group_id - int (from tl_groups table)
post_id - int (from posts table)

-- Updates on the timeline of the group
tl_groups_updates:
id - int
group_id - int (from tl_groups table)
user_id - int (from users table)
when - date
content - text
hidden - boolean
locked - boolean

tl_groups_hidden_data:
group_id - int (from tl_groups table)
reports - smallint
hidden - boolean
locked - boolean

tl_groups_reports:
group_id - int (from tl_groups table)
reporter_id - int (from users table)
when - date
reason - text
```

**Group changes history**
```
tl_groups_name_hist:
group_id - int (from tl_groups table)
when - date
old - varchar
new - varchar

tl_groups_latin_name_hist:
group_id - int (from tl_groups table)
when - date
old - varchar
new - varchar

tl_groups_alias_hist:
group_id - int (from tl_groups table)
when - date
old_1 - varchar
old_2 - varchar
old_3 - varchar
new_1 - varchar
new_2 - varchar
new_3 - varchar

tl_groups_description_hist:
group_id - int (from tl_groups table)
when - date
old - text
new - text

tl_groups_language_hist:
group_id - int (from tl_groups table)
when - date
old_1 - varchar
old_2 - varchar
old_3 - varchar
new_1 - varchar
new_2 - varchar
new_3 - varchar

tl_groups_status_hist:
group_id - int (from tl_groups table)
when - date
old - enum
new - enum

tl_groups_members_hist:
group_id - int (from tl_groups table)
user_id - int (from users table)
when - date
action - enum
member_id - int (from users table) -- If it's a registered user
member_name - varchar -- If it isn't a registered user

tl_groups_translations_hist:
group_id - int (from tl_groups table)
when - date
type - varchar (add, delete)
post_id - int

tl_groups_updates_hist:
update_id - int (from tl_groups_updates table)
when - date
old_content - text
new_content - text
hidden - boolean
locked - boolean

tl_groups_mod_hist:
group_id - int (from tl_groups table)
mod_id - int (from users table)
when - date
reason - text
locked - boolean
hidden - boolean
```

#### Languages (languages)
To organize languages for future updates.
```
languages:
id - int
name - varchar
```


### Posts (posts)

**Define stuff**
```
posts:
id - int
op_id - int (from users table)
published - date
translated_from - int (from languages table)
cover_image - varchar
title - varchar
download_link - varchar
download_note - text

posts_translators:
post_id - int (from posts table)
group_id - int (from tl_groups table)

posts_aliases:
post_id - int (from posts table)
alias - varchar

posts_details:
post_id - int (from posts table)
sinopsis - text
game_length - smallint (from game_length table)
classification - enum
tl_type - enum -- "MTL", "Edited MTL" or "Manual Translation"
tl_status - enum -- "In progress", "Completed", "Paused" or "Cancelled"
tl_scope - enum -- "Complete Translation" or "Partial Translation"
tl_platform - enum -- "PC", "Android" or "Others"

posts_buy_links:
post_id - int (from posts table)
platform - enum -- "Steam", "Itch.io", "DLSite", "Mangagamer", etc...
link - varchar

posts_tl_progress:
post_id - int (from posts table)
tl_percentage - smallint
tl_section - enum -- "Translating", "Editing", "Images and Menu", "Reinserting" or "Testing"

posts_hidden_data:
post_id - int (from posts table)
locked - boolean
hidden - boolean
reports - smallint

posts_reports:
post_id - int (from posts table)
user_id - int (from users table)
reason - text
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


**Post change history**
```
posts_title_hist:
post_id - int (from posts table)
when - date
old - varchar
new - varchar

posts_download_link_hist:
post_id - int (from posts table)
when - date
old - varchar
new - varchar

posts_cover_image_hist:
post_id - int (from posts table)
when - date
old - varchar
new - varchar

posts_sinopsis_hist:
post_id - int (from posts table)
when - date
old - text
new - text

posts_length_hist:
post_id - int (from posts table)
when - date
old - smallint (from game_length table)
new - smallint (from game_length table)

posts_buy_links_hist:
post_id - int (from posts table)
when - date
action - enum 
platform - enum
link - varchar
```

### Comments (comments)

**Define stuff**
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

comments_hidden_data:
comment_id - int (from comments table)
locked - boolean
hidden - boolean
reports - smallint

comments_reports:
comment_id - int (from comments table)
user_id - int (from users table)
```

**Comments change history**
```
comments_content_hist:
comment_id - int (from comments table)
when - date
old - text
new - text

comments_mod_hist:
comment_id - int (from comments table)
mod_id - int (from users table)
when - date
reason - text
locked - boolean
hidden - boolean
```

### Reviews (reviews)
Note: These are **not** translation reviews, but rather reviews for the visual novels themselves.

**Define stuff**
```
reviews:
id - int
post_id - int (from posts table)
user_id - int (from users table)
content - text
rating - smallint -- 1 ("Utter bullsh*t") to 5 ("HOLY SH*T THIS IS AMAZING")
votes - int

reviews_attachments:
review_id - int (from reviews table)
attachment - varchar

reviews_votes:
review_id - int (from reviews table)
user_id - int (from users table)
vote - enum -- "Up" or "Down"

reviews_hidden_data:
review_id - int (from reviews table)
locked - boolean
hidden - boolean
reports - smallint

reviews_reports:
review_id - int (from reviews table)
user_id - int (from users table)
reason - text
```

**Reviews change history**
```
reviews_content_hist:
review_id - int (from reviews table)
when - date
old - varchar
new - varchar

reviews_rating_hist:
review_id - int (from reviews table)
date - date
old - smallint
new - smallint

reviews_attachments_hist:
review_id - int (from reviews table)
when - date
action - enum -- "Added" or "Deleted"
attachment - varchar

reviews_mod_hist:
review_id - int (from reviews table)
mod_id - int (from users table)
when - date
reason - text
hidden - boolean
locked - boolean
```
