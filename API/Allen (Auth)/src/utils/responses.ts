import { Response } from "express";

export const errorHandler = (res: Response, error: unknown) => {
    console.error(error);

    if (error instanceof Error) {
        return res.status(500).json({
            error: "Error del servidor.",
            message: error.message,
        });
    }

    res.status(500).json({ error: "Error desconocido." });
};
