import "dotenv/config";
import { PrismaClient } from "@prisma/client";
import { createPrismaAdapter } from "../lib/prisma-adapter";

const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
  throw new Error("DATABASE_URL is missing");
}

const prisma = new PrismaClient({ adapter: createPrismaAdapter(connectionString) });

async function main() {
  await prisma.product.deleteMany();

  await prisma.product.createMany({
    data: [
      {
        name: "iPhone 16",
        description: "Apple smartphone with A18 chip",
        brand: "Apple",
        category: "Electronics",
        price: 79999,
        stock: 20,
      },
      {
        name: "iPhone 15",
        description: "Previous generation Apple smartphone",
        brand: "Apple",
        category: "Electronics",
        price: 69999,
        stock: 15,
      },
      {
        name: "Galaxy S25",
        description: "Samsung flagship Android smartphone",
        brand: "Samsung",
        category: "Electronics",
        price: 74999,
        stock: 30,
      },
      {
        name: "Galaxy Buds",
        description: "Samsung wireless earbuds",
        brand: "Samsung",
        category: "Audio",
        price: 9999,
        stock: 50,
      },
      {
        name: "MacBook Air M4",
        description: "Apple laptop with M4 chip",
        brand: "Apple",
        category: "Laptops",
        price: 114999,
        stock: 10,
      },
      {
        name: "ThinkPad E14",
        description: "Lenovo business laptop",
        brand: "Lenovo",
        category: "Laptops",
        price: 64999,
        stock: 12,
      },
      {
        name: "Sony WH-1000XM5",
        description: "Sony noise cancelling headphones",
        brand: "Sony",
        category: "Audio",
        price: 29999,
        stock: 25,
      },
      {
        name: "Dell Inspiron",
        description: "Dell performance laptop",
        brand: "Dell",
        category: "Laptops",
        price: 57999,
        stock: 18,
      },
    ],
  });

  console.log("Products seeded successfully");
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });