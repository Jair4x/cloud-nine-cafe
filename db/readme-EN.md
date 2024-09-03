### [Ver. Español](readme-ES.md)
# Database

### Models
How should the models be?
Right now, the four main ones are:
- Users
- Translation Groups (Has users and not-users)
- Posts (Visual Novel Patches)
- Comments/Reviews (Inside said posts)

But then...
**How do we make them?**

#### Users
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
