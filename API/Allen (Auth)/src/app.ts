import express from "express";
import cors from "cors";
import authRoutes from "./routes/auth.routes";
import permRoutes from "./routes/perms.routes";
import authConfig from "./routes/auth.config";

const app = express();

app.use(cors());
app.use(express.json());

app.use(authConfig); // Auth configuration middleware

//? Routes
app.use("/v1/auth", authRoutes);
app.use("/v1/permissions", permRoutes);

export default app;
