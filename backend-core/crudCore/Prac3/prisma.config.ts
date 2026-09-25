import "dotenv/config";
import { defineConfig, env } from "prisma/config";

export default defineConfig({
  schema: "prisma/schema.prisma",
  migrations: {
    path: "prisma/migrations",
  },
  datasource: {
    url: env("DATABASE_URL"),
  },
});

//this file is only for Prisma "CLI operations" running such as migrations and doesn't become our application's db object

//hence runtime client should need and use @prisma/adapter-pg