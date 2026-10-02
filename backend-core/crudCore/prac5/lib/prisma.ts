import 'server-only';

import { PrismaMariaDb } from "@prisma/adapter-mariadb";
import { PrismaClient } from "@prisma/client";

const connectionString = process.env.DATABASE_URL;

if(!connectionString){
    throw new Error("DATABASE_URL missing");
}

const adapter = new PrismaMariaDb(connectionString);

const globalForPrisma = globalThis as unknown as {
    prisma ?: PrismaClient;
}

export const prisma = globalForPrisma.prisma ?? new PrismaClient({
    adapter,
})

if(process.env.NODE_ENV != "production") globalForPrisma.prisma = prisma;