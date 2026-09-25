import mongoose from 'mongoose';

const orderItemSchema = new mongoose.Schema({
    productId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Product",
        required: true
    },
    title:{
        type: String,
        required: true,
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
}, {_id: false});

const orderSchema = new mongoose.Schema({
    userId:{
        type: String,
        required: true,
    },
    items:{
        type: [orderItemSchema],
        required: true  //order is definitely if created then there's present forever
    },
    totalAmount:{
        type: Number,
        required: true,
        min: 0
    },
    status:{
        type: String,
        enum: ["CONFIRMED", "CANCELLED"],
        default: "CONFIRMED"
    }
}, {timestamps: true});

const Order = mongoose.model("Order", orderSchema);
export default Order;