Español
=======
#### [English ver.](#English)
## Base de Datos

Modelos
----------
¿Cómo deberían ser los modelos?
Los cuatro principales actualmente son:
- Usuarios
- Grupos de traducción (Conjunto de usuarios y no usuarios)
- Posts (Parches de Novelas Visuales)
- Comentarios/Reseñas (Dentro de dichos posts)

Pero...
**¿Cómo los hacemos?**

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
tl_groups - int
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

Grupos de Traducción (tl_group)
----------
**Definir cosas**
```
tl_group:
id - int
uid - int (dueño/a del grupo)
name - varchar
r_name - varchar (en caso de que algún grupo use nombres con caracteres fuera del latin)
description - text
lang - varchar (posibilemente se haga al mismo estilo que en VNDB, usando types)
deleted - boolean
hidden - boolean

tl_group_members:
id - int
uid - int (owner of the group)
r_mem - int[] (IDs of registered members)
nr_mem varchar[] (names of non-registered members)

tl_group_posts:
id - int
pid - int[] (IDs of posts)
```

	**Historial  de cambios de Grupo**
```
tl_group_name_hist:
id - int
date - date
old - varchar
new - varchar

tl_group_latin_name_hist:
id - int
date - date
old - varchar
new - varchar

tl_group_description_hist:
id - int
date - date
old - text
new - text

tl_group_lang_hist:
id - int
date - date
old - varchar
new - varchar

tl_group_status_hist:
id - int
date - date
locked - boolean
hidden - boolean

tl_group_member_hist:
id - int
date - date
type - varchar (add, delete, edit)
member - int (null si no está registrado)
nr_member - varchar (para miembros no registrados)

tl_group_post_hist:
id - int
date - date
type - varchar (add, delete)
pid - int
```

English
=======
#### [Ver. Español](#Español)
## Database

Models
----------
How should the models be?
Right now, the four main ones are:
- Users
- Translation Groups (Has users and not-users)
- Posts (Visual Novel Patches)
- Comments/Reviews (Inside said posts)

But then...
**How do we make them?**

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
tl_groups - int
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

Translation Groups (tl_group)
----------
**Define things**
```
tl_group:
id - int
uid - int (owner of the group)
name - varchar
r_name - varchar (in case someone uses a non-latin name)
description - text
lang - varchar (we might make this like vndb, using types, but for now no)
deleted - boolean
hidden - boolean

tl_group_members:
id - int
uid - int (owner of the group)
r_mem - int[] (IDs of registered members)
nr_mem varchar[] (names of non-registered members)

tl_group_posts:
id - int
pid - int[] (IDs of posts)
```

**Group changes history**
```
tl_group_name_hist:
id - int
date - date
old - varchar
new - varchar

tl_group_latin_name_hist:
id - int
date - date
old - varchar
new - varchar

tl_group_description_hist:
id - int
date - date
old - text
new - text

tl_group_lang_hist:
id - int
date - date
old - varchar
new - varchar

tl_group_status_hist:
id - int
date - date
locked - boolean
hidden - boolean

tl_group_member_hist:
id - int
date - date
type - varchar (add, delete, edit)
member - int (null if not registered)
nr_member - varchar (for non-registered members)

tl_group_post_hist:
id - int
date - date
type - varchar (add, delete)
pid - int
```