import { Router } from "express";
import { getSession } from "next-auth/react";
import { db } from "../config/schema";
import { roleSchema } from "../utils/validation";

const router = Router();

router.get("/check-role/:role", async (req, res) => {
    try {
        let { role } = req.params;

        role = roleSchema.safeParse(role);
        if (!role.success) {
            return res.status(400).json({ hasRole: false, error: "No autenticado." });
        }

        const session = await getSession({ req });
        if (!session) {
            return res.status(401).json({ hasRole: false, error: "No autenticado." });
        }

        const userId = session.user.id;

        const userRoles = await db
            .select("roles.name")
            .from("user_role")
            .join("roles", "user_role.roleId", "roles.id")
            .where({ userId });

        const hasRole = userRoles.some((userRole) => userRole.roleId === role);
        res.json({ hasRole });
    } catch (error) {
        console.error("Error al verificar el rol:", error);
        errorHandler(res, error);
    }
});

export default router;