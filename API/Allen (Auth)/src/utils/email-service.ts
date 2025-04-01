import fs from "fs";
import nodemailer from "nodemailer";
import { getSession } from "next-auth/react";
import { db } from "../config/schema";
import 'dotenv/config';

const transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: 465,
    secure: true,
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
    },
});

const verificationMailHTML = fs.readFileSync("../views/mailverification.html", "utf-8");
const resetMailHTML = fs.readFileSync("../views/resetpassword.html", "utf-8");

export async function sendVerificationEmail(userId: string, token: string) {
    try {
        const user = await db.select().from("users").where({ id: userId }).first();
        if (!user) throw new Error("Usuario no encontrado.");

        const session = await getSession();
        if (!session) throw new Error("Sesión no encontrada.");

        const verificationLink = `${process.env.WEBSITE_DOMAIN}/verify-email?token=${token}&userId=${userId}`;

        await transporter.sendMail({
            from: `"Cloud Nine Café" <${process.env.EMAIL_USER}>`,
            to: user.email,
            subject: `Verifica tu cuenta`,
            html: verificationMailHTML.replace("{{verificationLink}}", verificationLink),
        });

        console.log(`Correo de verificación enviado a ${user.email}.`);
    } catch (err) {
        console.warn("Error al enviar email de confirmación: ", err);
    }
}

export async function sendPasswordResetEmail(email: string, token: string) {
    try {
        const resetLink = `${process.env.WEBSITE_DOMAIN}/reset-password?token=${token}`;

        await transporter.sendMail({
            from: `"Cloud Nine Café" <${process.env.EMAIL_USER}>`,
            to: email,
            subject: `Restablece tu contraseña`,
            html: resetMailHTML.replace("{{resetLink}}", resetLink),
        });

        console.log(`Correo de restablecimiento de contraseña enviado a ${email}.`);
    } catch (error) {
        console.warn("Error al enviar el correo de restablecimiento de contraseña: ", error);
    }
}