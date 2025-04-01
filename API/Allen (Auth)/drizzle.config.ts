import { defineConfig } from "drizzle-kit";

export default defineConfig({
    dialect: "postgresql",
    schema: "./src/config/schema.ts",
    out: "./drizzle",
});
