import Cart from "../models/Cart.js";
import Product from "../models/Product.js";
import Order from "../models/Order.js";
import mongoose from 'mongoose';

export const getCartByUserId = async (req, res) => {
  try {
    const cart = await Cart.findOne({ userId: req.params.userId })
      .populate("items.productId", "title price stock");

    if (!cart) {
      return res.status(404).json({
        success: false,
        error: "Cart not found"
      });
    }

    return res.status(200).json({
      success: true,
      data: cart
    });
  } catch (err) {
    return res.status(500).json({ success: false, error: err.message });
  }
};

export const addToCart = async(req, res)=>{
    try{
        const { userId, productId, quantity } = req.body;

        //validate inputs: ensure IDs exist, quantity is an integer, and count is greater than 0
        if(!userId || !productId || !Number.isInteger(quantity) || quantity <=0){
            return res.status(400).json({
                success: false,
                error: "Invalid userId, productId or quantity"
            });
        }

        //find product
        const product = await Product.findById(productId);

        if(!product){
            return res.status(404).json({
                success: false,
                error: "product not found"
            })
        }

        // Retrieve existing active cart for this specific user using their unique userId
        let cart = await Cart.findOne({ userId });

        // If no cart exists for the user yet, instantiate a fresh Cart document in memory
        if(!cart){
            cart = new Cart({
                userId,
                items: []
            })
        }

        // Check if the product being added already exists inside the cart's items array
        const existingItem = cart.items.find(
            (item)=> item.productId.toString()===productId
        );

        //Determine current count in cart: use existing quantity if found, otherwise start from 0
        const currentQty = existingItem ? existingItem.quantity : 0;

        // Calculate combined quantity if this new addition proceeds
        const newQty = currentQty + quantity;

        //checking stock: requested total does not exceed the real-time available stock
        if(newQty > product.stock){ //not reducing on cart add cuzz maybe user not buy ever & but stock got reduced disable the others
            return res.status(400).json({
                success: false,
                error: "Only "+product.stock+" items are available"
            })        
        }

        //If product already in cart, update its existing quantity
        if(existingItem){   //replacing the previous qty with new possible added quantity
            existingItem.quantity = newQty
        }else{
            //push a new subdocument into the items array with snapshot of current price in cart
            cart.items.push({
                productId,
                quantity,
                unitPrice: product.price
            });
        }

        // Recalculate cart grand total by looping through items, starting the running tally at 0
        cart.totalAmount = cart.items.reduce(
            (total, item)=> total + item.quantity * item.unitPrice, 0   //0 is initial value i.e. "total=0" of this callback calculation
        )
        //.reduce(callback, initialValue) takes an initial accumulator value.

        await cart.save();

        return res.status(200).json({
            success: true,
            data: cart
        })

    }catch(err){
        return res.status(500).json({
            success: false,
            error: err.message
        });
    }
}

// Export the checkout controller handler
export const checkout = async (req, res) => {
    // 1. Initialize a MongoDB client session to track all operations in this request
    const session = await mongoose.startSession();

    try {
        // Extract the target userId from the incoming request payload
        const { userId } = req.body;

        // 2. Begin the atomic multi-document transaction boundary
        session.startTransaction();

        // 3. Find the user's cart; attach .session() so this read joins the transaction
        const cart = await Cart.findOne({ userId }).session(session);

        // Guard clause: ensure the cart exists and contains at least one item
        if (!cart || cart.items.length === 0) {
            // Cancel and clean up the transaction before early return
            await session.abortTransaction();
            return res.status(400).json({
                success: false,
                error: "Cart is empty"
            });
        }

        // Temporary array to hold finalized order item subdocuments
        const orderItems = [];

        // 4. Iterate over every item in the cart to check and decrement stock
        for (const item of cart.items) {
            // Atomically check if stock >= requested quantity AND decrement stock in one step
            const product = await Product.findOneAndUpdate(
                {
                    _id: item.productId,
                    stock: { $gte: item.quantity } // Match only if sufficient stock exists
                },
                {
                    $inc: { stock: -item.quantity } // Atomically decrease stock by cart quantity
                },
                {
                    new: true, // Return the updated product document
                    session    // Run this update inside our active transaction
                }
            );

            // If product is null, it means either ID wasn't found or stock was less than requested
            if (!product) {
                // Abort all previous stock deductions made during this loop
                await session.abortTransaction();
                return res.status(400).json({
                    success: false,
                    error: `Insufficient stock for product ID: ${item.productId}`
                });
            }

            // Construct an immutable snapshot of the purchased item for the order
            orderItems.push({
                productId: product._id,   // Verified ID from database
                title: product.title,     // Current title from database
                quantity: item.quantity,  // Chosen quantity from cart
                unitPrice: item.unitPrice // Price snapshot agreed upon in cart
            });
        }

        // 5. Create the permanent Order record inside the transaction envelope
        // Note: Mongoose requires array syntax [ { ... } ] when passing options like { session }
        const order = await Order.create(
            [
                {
                    userId,
                    items: orderItems,
                    totalAmount: cart.totalAmount,
                    status: "CONFIRMED"
                }
            ],
            { session }
        );

        // 6. Reset the user's cart back to an empty state
        cart.items = [];
        cart.totalAmount = 0;

        // Persist the emptied cart state within the session
        await cart.save({ session });

        // 7. Commit all pending operations simultaneously to the database
        await session.commitTransaction();

        // Respond with 201 Created and return the created order (first item of array)
        return res.status(201).json({
            success: true,
            message: "Checkout Successful",
            order: order[0]
        });

    } catch (err) {
        // If an unexpected runtime/database error occurs, roll back all modifications
        await session.abortTransaction();

        // Send a 500 internal server error response with failure details
        return res.status(500).json({
            success: false,
            error: err.message
        });
    } finally {
        // 8. Always close the session to release connection resources back to the pool
        session.endSession();
    }
};