import express from "express";
import { addToCart, checkout, getCartByUserId } from "../controllers/cartController.js";
const router = express.Router();

router.get("/:userId", getCartByUserId);
router.post("/add", addToCart);
router.post("/checkout", checkout);

export default router;