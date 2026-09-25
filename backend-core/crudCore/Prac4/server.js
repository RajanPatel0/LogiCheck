import express from "express";
import dotenv from 'dotenv';
import mongoose from "mongoose";

import productRoute from "./routes/productRoute.js"
import cartRoute from "./routes/cartRoutes.js";

dotenv.config();

const app = express();

app.use(express.json());

app.use("/api/product", productRoute);
app.use("/api/cart", cartRoute);

const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGODB_URI;

mongoose.connect(MONGO_URI)
    .then(()=>{
        console.log("MONGODB connected");

        app.listen((PORT), ()=>{
            console.log("Server running on port: ", PORT);
        })
    })
    .catch((err)=>{
        console.error("connection failed", err.message);
    })