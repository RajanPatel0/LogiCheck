import "dotenv/config";

import { PrismaMariaDb } from "@prisma/adapter-mariadb";
import { PrismaClient } from "@prisma/client";

const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
  throw new Error("DATABASE_URL is missing");
}

const adapter = new PrismaMariaDb(connectionString);

const prisma = new PrismaClient({
  adapter,
});

async function main() {
  await prisma.product.deleteMany();

  const products = Array.from({ length: 100 }, (_, index) => ({
    name: `Product ${index + 1}`,
    description: `Description for product ${index + 1}`,
    price: (index + 1) * 100,
    category: index % 2 === 0 ? "Electronics" : "Accessories",
    stock: 10 + (index % 20),
  }));

  await prisma.product.createMany({
    data: products,
  });

  console.log("100 products inserted successfully");
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });