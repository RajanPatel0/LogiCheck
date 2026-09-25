import express from "express";
import { createProduct, getProductById, getProducts } from "../controllers/productController.js";
const router = express.Router();

router.get("/", getProducts);
router.post("/create", createProduct);
router.get("/:id", getProductById);

export default router;