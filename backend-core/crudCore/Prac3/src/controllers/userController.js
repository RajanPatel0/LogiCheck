import prisma from "../lib/prisma.js";

export async function getUsers(req, res) {
  try {
    const users = await prisma.user.findMany({
      orderBy: { id: "asc" },
    });

    res.json(users);
  } catch (error) {
    console.error("Failed to fetch users:", error);
    res.status(500).json({ error: "Failed to fetch users" });
  }
}

export async function createUser(req, res) {
  const { name, email } = req.body;

  if (typeof name !== "string" || typeof email !== "string" || !name.trim() || !email.trim()) {
    return res.status(400).json({ error: "name and email are required" });
  }

  try {
    const user = await prisma.user.create({
      data: {
        name: name.trim(),
        email: email.trim().toLowerCase(),
      },
    });

    res.status(201).json(user);
  } catch (error) {
    if (error.code === "P2002") {
      return res.status(409).json({ error: "A user with this email already exists" });
    }

    console.error("Failed to create user:", error);
    res.status(500).json({ error: "Failed to create user" });
  }
}