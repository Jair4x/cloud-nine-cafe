import express from "express";
import secureHash from "../utils/password-security";
import { sendPasswordResetEmail, sendVerificationEmail } from "../utils/email-service";
import { v4 as uuidv4 } from 'uuid';
import { db } from "../config/schema";
import { SignupSchema, LoginSchema, RequestPasswordResetSchema, ResetPasswordSchema } from "../utils/validation";
import errorHandler from "../utils/responses";

const router = express.Router();

router.post("/signup", async (req, res) => {
    try {
        const { username, email, password } = await SignupSchema.parseAsync(req.body);

        const existingUser = await db.select().from("users").where({ email }).first();
        if (existingUser) {
            return res.status(400).json({ error: "El usuario ya existe." });
        }

        const hashedPassword = await secureHash(password);
        const userId = uuidv4();
        const token = uuidv4();

        await db.insert("users").values({
            id: userId,
            username,
            email,
            password: hashedPassword,
            emailVerified: null,
        });

        await db.insert("verificationToken").values({
            identifier: email,
            token,
            expires: new Date(Date.now() + 6 * 60 * 60 * 1000), // 6 hours
        });

        await sendVerificationEmail(userId, token);

        res.status(201).json({ message: "Usuario registrado. Verifique su correo electrónico." });
    } catch (error) {
        console.error("Error en el registro:", error);
        errorHandler(res, error);
    }
});

router.post("/logout", async (req, res) => {
    try {
        res.clearCookie("next-auth.session-token", { path: "/" });
        res.clearCookie("next-auth.csrf-token", { path: "/" });

        res.status(200).json({ message: "Sesión cerrada con éxito." });
    } catch (error) {
        console.error("Error al cerrar sesión:", error);
        errorHandler(res, error);
    }
});

router.post("/request-email-verification", async (req, res) => {
    try {
        const { email } = await RequestPasswordResetSchema.parseAsync(req.body); // Using the same one as password reset

        const user = await db.select().from("users").where({ email }).first();
        if (!user) {
            return res.status(400).json({ error: "Usuario no encontrado." });
        }

        if (user.emailVerified) {
            return res.status(400).json({ error: "El correo electrónico ya está verificado." });
        }

        const token = uuidv4();
        const expires = new Date(Date.now() + 6 * 60 * 60 * 1000); // 6 hours

        await db.insert("verificationToken").values({
            identifier: email,
            token,
            expires,
        });

        await sendVerificationEmail(user.id, token);

        res.status(200).json({ message: "Correo de verificación enviado.\nRevisa tu carpeta de SPAM si no lo ves." });
    } catch (error) {
        console.error("Error al solicitar la verificación del correo electrónico:", error);
        errorHandler(res, error);
    }
});

router.get("/verify-email", async (req, res) => {
    try {
        const { token, userId } = req.query;

        const verificationToken = await db.select().from("verificationToken").where({ token }).first();
        if (!verificationToken || verificationToken.identifier !== userId || verificationToken.expires < new Date()) {
            return res.status(400).json({ error: "Token de verificación inválido o expirado." });
        }

        await db.update("users").set({ emailVerified: new Date() }).where({ id: userId });
        await db.delete("verificationToken").where({ token });

        res.status(200).json({ message: "Correo electrónico verificado." });
    } catch (error) {
        console.error("Error al verificar el correo electrónico:", error);
        errorHandler(res, error);
    }
});

router.post("/request-password-reset", async (req, res) => {
    try {
        const { email } = await RequestPasswordResetSchema.parseAsync(req.body);

        const user = await db
            .select()
            .from("users")
            .where({ email })
            .first();
        if (!user) {
            return res.status(400).json({ error: "Usuario no encontrado." });
        }

        const token = uuidv4();
        const expires = new Date(Date.now() + 2 * 60 * 60 * 1000); // 2 hours

        await sendPasswordResetEmail(email, token);

        res.status(200).json({ message: "Correo de restablecimiento de contraseña enviado.\nMira la casilla de Spam si no lo encuentras." });
    } catch (error) {
        console.error("Error al solicitar el restablecimiento de contraseña:", error);
        errorHandler(res, error);
    }
});

router.post("/reset-password", async (req, res) => {
    try {
        const { token, newPassword } = await ResetPasswordSchema.parseAsync(req.body);

        const verificationToken = await db
            .select()
            .from("verificationToken")
            .where({ token })
            .first();

        if (!verificationToken || verificationToken.expires < new Date()) {
            return res.status(400).json({ error: "Token inválido o expirado." });
        }

        const hashedPassword = secureHash(newPassword);

        await db.update("users").set({ password: hashedPassword }).where({ email: verificationToken.identifier })
        await db.delete("verificationToken").where({ token });

        res.status(200).json({ message: "Contraseña restablecida." });
    } catch (error) {
        console.error("Error al restablecer la contraseña:", error);
        errorHandler(res, error);
    }
});

export default router;