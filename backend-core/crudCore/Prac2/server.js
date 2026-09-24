import express from 'express';
import dotenv from "dotenv";
import mongoose from "mongoose";

import commentRoute from "./routes/commentRoute.js";

dotenv.config();
const app = express();

app.use(express.json());    //Express needs to parse the JSON body. for req.body


app.use("/api/comments", commentRoute);


const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGODB_URI;

mongoose.connect(MONGO_URI)
    .then(()=>{
        console.log("mongodb connected");

        app.listen(PORT, ()=>{
            console.log("server running on port:", PORT);
        })
    }).catch((err)=>{
        console.error("connection failed", err.message);
    });