import "server-only";
import { PrismaClient } from "@prisma/client";
import { createPrismaAdapter } from "./prisma-adapter";

const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
  throw new Error("DATABASE_URL is missing. Add it to .env.");
}

const globalForPrisma = globalThis as unknown as { prisma?: PrismaClient };

export const prisma = globalForPrisma.prisma ?? new PrismaClient({
  adapter: createPrismaAdapter(connectionString),
});

if (process.env.NODE_ENV !== "production") {
  globalForPrisma.prisma = prisma;
}