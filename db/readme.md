Español
=======
#### [English ver.](#English)
## Base de Datos

Modelos
----------
¿Cómo deberían ser los modelos?
Los cuatro (o cinco) principales actualmente son:
- Usuarios
- Grupos de traducción (Conjunto de usuarios y no usuarios)
- Posts (Parches de Novelas Visuales)
- Comentarios/Reseñas (Dentro de dichos posts)

Pero...
**¿Cómo los hacemos?**

**Nota**: Cada modelo tiene una propiedad `hidden` y una propiedad `locked`, las cuales fueron inspiradas en el schema oficial de VNDB, que usa estas propiedades.

Moderación/Aprobación necesitada:
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

Usuarios (users)
----------
**Definir cosas**
```
users:
id - int
username - varchar
display_name - varchar
email_verified - boolean
avatar - varchar
registered - date

users_extras:
id - int
bio - text
socials - text[]
tl_group - int
tl_languages - text[]
w_skin - int

users_extras_privacy:
id - int
bio_hidden - boolean
socials_hidden - boolean
languages_hidden - boolean

users_role:
id - int
role - int

users_hidden:
id - int
email - varchar
status - varchar
passwd - varchar (encriptada)
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
until - date (null si es permanente)
```

Grupos de Traducción (tl_groups)
----------
**Definir cosas**
```
tl_groups:
id - int
uid - int (dueño/a del grupo)
name - varchar
r_name - varchar (en caso de que algún grupo use nombres con caracteres fuera del latin)
description - text
lang - varchar (posibilemente se haga al mismo estilo que en VNDB, usando types)
status - varchar (activo, muerto)
deleted - boolean
hidden - boolean

tl_groups_members:
id - int
uid - int
r_mem - int[] (IDs de usuarios registrados)
nr_mem varchar[] (nombres de usuarios no registrados)

tl_groups_posts:
id - int
pid - int[] (IDs de posts en la página)
```

**Historial  de cambios de Grupo**
```
tl_groups_name_hist:
id - int
date - date
old - varchar
new - varchar

tl_groups_latin_name_hist:
id - int
date - date
old - varchar
new - varchar

tl_groups_description_hist:
id - int
date - date
old - text
new - text

tl_groups_lang_hist:
id - int
date - date
old - varchar
new - varchar

tl_groups_status_hist:
id - int
date - date
old - varchar
new - varchar

tl_groups_mod_hist:
id - int
date - date
locked - boolean
hidden - boolean

tl_groups_member_hist:
id - int
date - date
type - varchar (add, delete, edit)
member - int (null si no está registrado)
nr_member - varchar (para miembros no registrados)

tl_groups_post_hist:
id - int
date - date
type - varchar (add, delete)
pid - int
```

Posts (posts)
----------
**Definir cosas**
```
posts:
id - int
uid - int (ID del usuario que hizo el post)
gid - int (ID del grupo que traduce/tradujo la novela)
published - date
lang - varchar (idioma desde el que se tradujo la novela visual)
image - varchar (link a la imagen de portada)
title - varchar (nombre de la novela visual en romaji/latin)
o_title - varchar (nombre de la novela visual en su lenguaje original)
link - varchar (link a la página del grupo para descargar el parche) -- Estoy considerando agregar una forma de hostear en la página los parches, pero puede costar mucho.
locked - boolean
hidden - boolean

posts_details:
id - int
length - smallint (número de horas que toma en promedio completar la novela) -- Puede que lo cambie más adelante si encuentro una manera en plan VNDB para las horas, como el rango de [0 - 5] y el tema de las horas exactas.
classif - varchar (All ages, +15, +18)
status - varchar (publicado, trabajando en ello, hiatus)

posts_progress:
id - int
percentage - smallint (% de completado del parche)
section - varchar (traduciendo, editando/corrigiendo, QC, lanzado) -- Más o menos como lo hace Project Sekai y otros grupos de mostrar un porcentaje de su traducción y decir en qué van con la traducción. Es una buena idea, pero voy a pedir feedback igual.
```

**Historial de cambios en Posts**
```
posts_group_hist:
id - int
date - date
old_gid - int
new_gid - int

posts_lang_hist:
id - int
date - date
old - varchar
new - varchar

posts_image_hist:
id - int
date - date
old - varchar
new - varchar

posts_title_hist:
id - int
date - date
old - varchar
new - varchar

posts_orig_title_hist:
id - int
date - date
old - varchar
new - varchar

posts_link_hist:
id - int
date - date
old - varchar
new - varchar

posts_mod_hist:
id - int
date - date
locked - boolean
hidden - boolean


posts_length_hist:
id - int
date - date
old - smallint
new - smallint

posts_classif_hist:
id - int
date - date
old - varchar
new - varchar

posts_status_hist:
id - int
date - date
old - varchar
new - varchar


posts_perc_hist:
id - int
date - date
old - smallint
new - smallint

posts_section_hist:
id - int
date - date
old - varchar
new - varchar
```

Comentarios (comments)
----------
**Definir**
```
comments:
id - int
parent - int (ID del comentario original)
pid - int (ID del post)
uid - int (ID del usuario comentando)
content - text (límite: ~250 caracteres)
date - date
locked - boolean
hidden - boolean

comments_votes:
id - int
value - int (Contador de votos del comentario, siendo positivos, negativos o cero)
voters - int[] (Lista de IDs de usuarios que votaron el comentario) -- No estoy seguro de si lo implementaré de esta manera.

comments_reports:
id - int
value - int -- ¿Cuántos reportes tiene el comentario? (A partir de los 3, se envía una notificación al panel de moderación)
reporters - int[] (Lista de IDs de usuarios que reportaron el comentario)
```

**Historial de cambios de comentario**
```
comments_cont_edit_hist:
id - int
date - date
old_content - text
new_content - text

comments_mod_hist:
id - int
date - date
locked - boolean
hidden - boolean
```

Reseñas (reviews)
----------
Nota: Estas **no** son reseñas sobre las traducciones, sino de las novelas en sí.
**Definir**
```
reviews:
id - int
pid - int (ID del post)
uid - int (ID del usuario que hace la reseña)
content - text
score - smallint -- 1 ("Basura total") to 5 ("¡GOTY of the year del año!")
locked - boolean
hidden - boolean

reviews_attachments: -- Analizando si agregar esto, con fe y podré implementarlo.
id - int
attachments - varchar[] (Links relativos a las imágenes que estarán en el footer de la reseña)

reviews_reports:
id - int
value - int -- ¿Cuántos reportes tiene la reseña? (A partir de los 3, se envía una notificación al panel de moderación)
reporters - int[] (Lista de IDs de los usuarios que reportaron la reseña)
```

**Historial de cambios de reseña**
```
reviews_content_hist:
id - int
date - date
old - varchar
new - varchar

reviews_score_hist:
id - int
date - date
old - varchar
new - varchar

reviews_mod_hist:
id - int
date - date
locked - boolean
hidden - boolean
```


English
=======
#### [Ver. Español](#Español)
## Database

Models
----------
How should the models be?
Right now, the four (or five) main ones are:
- Users
- Translation Groups (Has users and not-users)
- Posts (Visual Novel Patches)
- Comments/Reviews (Inside said posts)

But then...
**How do we make them?**

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

Users (users)
----------
**Define stuff**
```
users:
id - int
username - varchar
display_name - varchar
email_verified - boolean
avatar - varchar
registered - date

users_extras:
id - int
bio - text
socials - text[]
tl_group - int
tl_languages - text[]
w_skin - int

users_extras_privacy:
id - int
bio_hidden - boolean
socials_hidden - boolean
languages_hidden - boolean

users_role:
id - int
role - int

users_hidden:
id - int
email - varchar
status - varchar
passwd - varchar (encrypted)
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
until - date (null if permanent)
```

Translation Groups (tl_groups)
----------
**Define stuff**
```
tl_groups:
id - int
uid - int (owner of the group)
name - varchar
r_name - varchar (in case someone uses a non-latin name)
description - text
lang - varchar (we might make this like vndb, using types, but for now no need)
status - varchar (active, dead)
deleted - boolean
hidden - boolean

tl_groups_members:
id - int
uid - int (owner of the group)
r_mem - int[] (IDs of registered members)
nr_mem varchar[] (names of non-registered members)

tl_groups_posts:
id - int
pid - int[] (IDs of posts)
```

**Group changes history**
```
tl_groups_name_hist:
id - int
date - date
old - varchar
new - varchar

tl_groups_latin_name_hist:
id - int
date - date
old - varchar
new - varchar

tl_groups_description_hist:
id - int
date - date
old - text
new - text

tl_groups_lang_hist:
id - int
date - date
old - varchar
new - varchar

tl_groups_status_hist:
id - int
date - date
old - varchar
new - varchar

tl_groups_mod_hist:
id - int
date - date
locked - boolean
hidden - boolean

tl_groups_member_hist:
id - int
date - date
type - varchar (add, delete, edit)
member - int (null if not registered)
nr_member - varchar (for non-registered members)

tl_groups_post_hist:
id - int
date - date
type - varchar (add, delete)
pid - int
```

Posts (posts)
----------
**Define stuff**
```
posts:
id - int
uid - int (ID of the user who made the post)
gid - int (ID of the group that translated the visual novel)
published - date
lang - varchar (language the visual novel was translated from)
image - varchar (link to cover image)
title - varchar (name of the visual novel in romaji)
o_title - varchar (name of the visual novel in original lang)
link - varchar (link to group website to download patch) -- I'm considering adding a way to host patches, but it may be too expensive
locked - boolean
hidden - boolean

posts_details:
id - int
length - smallint (number of hours that the visual novel takes to complete on average) -- Might change later if I find a vndb-like way to get two types of lengths, kinda like the [0 - 5] range and the hours thingy.
classif - varchar (All ages, +15, +18)
status - varchar (published, working on it, hiatus)

posts_progress:
id - int
percentage - smallint (% of completion of the patch)
section - varchar (translating, editing, QA, released) -- Kinda like how Project Sekai or other groups show progress, giving a % and saying what exactly are they doing. It's a neat idea, but I might need some feedback for it.
```

**Post change history**
```
posts_group_hist:
id - int
date - date
old_gid - int
new_gid - int

posts_lang_hist:
id - int
date - date
old - varchar
new - varchar

posts_image_hist:
id - int
date - date
old - varchar
new - varchar

posts_title_hist:
id - int
date - date
old - varchar
new - varchar

posts_orig_title_hist:
id - int
date - date
old - varchar
new - varchar

posts_link_hist:
id - int
date - date
old - varchar
new - varchar

posts_mod_hist:
id - int
date - date
locked - boolean
hidden - boolean


posts_length_hist:
id - int
date - date
old - smallint
new - smallint

posts_classif_hist:
id - int
date - date
old - varchar
new - varchar

posts_status_hist:
id - int
date - date
old - varchar
new - varchar


posts_perc_hist:
id - int
date - date
old - smallint
new - smallint

posts_section_hist:
id - int
date - date
old - varchar
new - varchar
```

Comments (comments)
----------
**Define stuff**
```
comments:
id - int
parent - int (ID of original/parent comment)
pid - int (ID of the post)
uid - int (ID of the user who commented)
content - text (limit: ~250 characters)
date - date
locked - boolean
hidden - boolean

comments_votes:
id - int
value - int (Count of the comment's votes, being either positive, negative or zero)
voters - int[] (List of IDs of users who voted the comment) -- Not sure if I'll implement it this way, but for now I'll leave it as that.

comments_reports:
id - int
value - int -- How many reports does the comment have? (On 3 reports, an alert will get sent to the moderation dashboard)
reporters - int[] (List of IDs of users who reported the comment)
```

**Comments change history**
```
comments_cont_edit_hist:
id - int
date - date
old_content - text
new_content - text

comments_mod_hist:
id - int
date - date
locked - boolean
hidden - boolean
```

Reviews (reviews)
----------
Note: These are **not** translation reviews, but rather reviews for the visual novels.
**Define stuff**
```
reviews:
id - int
pid - int (ID of the post)
uid - int (ID of the user who's reviewing)
content - text
score - smallint -- 1 ("absolute dogwater") to 5 ("what a masterpiece!")
locked - boolean
hidden - boolean

reviews_attachments: -- Analyzing if I'll add this, hopefully I can make it work.
id - int
attachments - varchar[] (Relative links to images included in the footer of the review)

reviews_reports:
id - int
value - int -- How many reports does the review have? (On 3 reports, an alert will get sent to the moderation dashboard)
reporters - int[] (List of IDs of users who reported the review)
```

**Reviews change history**
```
reviews_content_hist:
id - int
date - date
old - varchar
new - varchar

reviews_score_hist:
id - int
date - date
old - varchar
new - varchar

reviews_mod_hist:
id - int
date - date
locked - boolean
hidden - boolean
```