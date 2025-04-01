import "dotenv/config";
import express from "express";
import helmet from "helmet";
import cors from "cors";
import hpp from "hpp";
import authRoutes from "./routes/auth.routes";
import permRoutes from "./routes/perms.routes";
import authConfig from "./routes/auth.config";
import { rateLimiter } from "./middlewares/security";

const app = express();

app.use(helmet());
app.use(hpp());
app.use(cors({
    origin: process.env.MAIN_API_URL,
    credentials: true,
    methods: ["GET", "POST"],
}));
app.use(express.json());
app.use(authConfig);

//? Routes
app.use("/v1/auth", rateLimiter(15, "10m"), authRoutes);
app.use("/v1/permissions", rateLimiter(30, "10m"), permRoutes);

export default app;
