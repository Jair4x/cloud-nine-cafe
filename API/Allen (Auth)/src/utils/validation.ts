import { z } from "zod";

export const RegisterSchema = z.object({
    username: z.string()
        .min(3, "El nombre de usuario debe tener al menos 3 caracteres.")
        .max(23, "El nombre de usuario no puede tener más de 23 caracteres.")
        .regex(/^[a-zA-Z0-9_]+$/, "El nombre de usuario solo puede contener letras, números y guiones bajos."),
    email: z.string().email("Correo electrónico inválido."),
    password: z.string()
        .min(8, "Tu contraseña debe tener al menos 8 caracteres.")
        .max(100, "Tu contraseña no puede tener más de 100 caracteres.")
        .regex(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/, "La contraseña debe tener al menos una letra mayúscula, una letra minúscula, un número y un carácter especial."),
});

export const LoginSchema = z.object({
    identifier: z.string()
        .min(3, "El nombre de usuario/correo electrónico debe tener al menos 3 caracteres.")
        .max(254, "El nombre de usuario/correo electrónico es muy largo."),
    password: z.string()
        .min(8, "La contraseña debe tener al menos 8 caracteres.")
        .max(100, "Contraseña muy larga."),
});

export const ResetPasswordSchema = z.object({
    token: z.string().min(1, "El token es requerido."),
    newPassword: z
        .string()
        .min(8, "Tu contraseña debe tener al menos 8 caracteres.")
        .max(100, "Tu contraseña no puede tener más de 100 caracteres.")
        .regex(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/, "La contraseña debe tener al menos una letra mayúscula, una letra minúscula, un número y un carácter especial."),
});

export const RequestPasswordResetSchema = z.object({
    email: z.string().email("Correo electrónico inválido."),
});

export const roleSchema = z.string().min(1, "El nombre del rol es requerido.");