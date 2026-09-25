import mongoose from "mongoose";

const cartItemSchema = new mongoose.Schema({
    productId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Product",
        required: true
    },
    quantity:{
        type: Number,
        required: true,
        min: 1
    },
    unitPrice:{
        type: Number,
        required: true,
        min: 0
    }
}, {_id: false});   //tells Mongoose not to automatically generate an _id field for each item embedded in the itmes array.
//Avoids Redundant Identifiers:
//Each cart item already references a unique product via productId. Generating another random _id for the subdocument itself is redundant

const cartSchema = new mongoose.Schema({
    userId: {
        type: String,
        required: true, 
        unique: true   //one user = one cart
    },
    items:{
        type: [cartItemSchema],
        default: []
    },
    totalAmount:{
        type: Number,
        default: 0, //default: true on a field typed as Number can cause casting or validation issues
        min: 0
    }
}, {timestamps: true});

const Cart = mongoose.model("Cart", cartSchema);
export default Cart;