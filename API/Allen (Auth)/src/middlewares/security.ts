import ms from "ms";
import { Request, Response, NextFunction } from "express";
import rateLimit from "express-rate-limit";

export const rateLimiter = (max: number, windowMs: number) =>
    rateLimit({
        windowMs: typeof windowMs === "string" ? ms(windowMs) : windowMs,
        max,
        handler: (req, res) => {
            res.status(429).json({
                error: "Vas muy rápido, espera un rato y vuelve a intentarlo.",
            });
        },
    });