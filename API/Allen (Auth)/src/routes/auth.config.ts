import 'dotenv/config';
import Credentials from "@auth/express/providers/credentials";
import Discord from "@auth/express/providers/discord";
import Facebook from "@auth/express/providers/facebook";
import Google from "@auth/express/providers/google";
import express from "express";
import secureHash from "../utils/password-security";
import { DrizzleAdapter } from "@auth/drizzle-adapter";
import { ExpressAuth } from "@auth/express";
import { LoginSchema } from "../utils/validation";
import { db } from "../config/schema";

const app = express();

app.set("trust proxy", true);
app.use(
    "/*",
    ExpressAuth({
        providers: [
            Credentials({
                credentials: {
                    identifier: { label: "Email o Nombre de Usuario", type: "text" },
                    password: { label: "Contraseña", type: "password" },
                },
                authorize: async (credentials) => {
                    let user = null;

                    const { identifier, password } = await LoginSchema.parseAsync(credentials);

                    if (!identifier || !password) {
                        throw new Error("Credenciales faltantes.");
                    }

                    const isEmail = identifier.includes("@");

                    const pwHash = await secureHash(credentials.password);

                    user = isEmail
                        ? await db.select().from("users").where({ email: identifier, password: pwHash }).first()
                        : await db.select().from("users").where({ username: identifier, password: pwHash }).first();

                    if (!user) {
                        throw new Error("Credenciales inválidas.");
                    }

                    return user;
                }
            }),
            Facebook({
                clientId: process.env.FACEBOOK_CLIENT_ID,
                clientSecret: process.env.FACEBOOK_CLIENT_SECRET,
            }),
            Google({
                clientId: process.env.GOOGLE_CLIENT_ID,
                clientSecret: process.env.GOOGLE_CLIENT_SECRET
            }),
            Discord({
                clientId: process.env.DISCORD_CLIENT_ID,
                clientSecret: process.env.DISCORD_CLIENT_SECRET
            })
        ],
        callbacks: {
            async session({ session, token }) {
                session.user.id = token.sub;
                return session;
            },
        },
        secret: process.env.JWT_SECRET,
        session: {
            strategy: "jwt",
        },
        adapter: DrizzleAdapter(db, {
            usersTable: users,
            accountsTable: accounts,
            sessionsTable: sessions,
            verificationTokensTable: verificationTokens,
            authenticatorsTable: authenticators,
        }),
    })
);

export default app;