import Product from "../models/Product.js";
import mongoose from "mongoose";

export const getProducts = async (req, res) => {
  try {
    // Step 1: Pagination setup
    const page = Number(req.query.page) || 1;
    const limit = Number(req.query.limit) || 10;
    const skip = (page - 1) * limit;

    // Step 2: Build the filter object step-by-step
    const filter = {};

    // Price range filters
    if (req.query.minPrice || req.query.maxPrice) {
      filter.price = {};
      if (req.query.minPrice) filter.price.$gte = Number(req.query.minPrice);
      if (req.query.maxPrice) filter.price.$lte = Number(req.query.maxPrice);
    }

    // In-stock toggle (stock > 0)
    if (req.query.inStock === "true") {
      filter.stock = { $gt: 0 };
    }

    // Step 3: Run queries
    const products = await Product.find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await Product.countDocuments(filter);

    // Step 4: Return response
    return res.status(200).json({
      success: true,
      page,
      limit,
      total,
      data: products
    });
  } catch (err) {
    return res.status(500).json({ success: false, error: err.message });
  }
};

export const getProductById = async (req, res) => {
  try {
    const { id } = req.params;

    // Guard: Prevent MongoDB crash if string isn't a valid 24-character hex ID
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        success: false,
        error: "Invalid product id format"
      });
    }

    const product = await Product.findById(id);

    if (!product) {
      return res.status(404).json({
        success: false,
        error: "Product not found"
      });
    }

    return res.status(200).json({
      success: true,
      data: product
    });
  } catch (err) {
    return res.status(500).json({ success: false, error: err.message });
  }
};

//const createProduct = async (req, res)=>{ logic }   then   export default createProduct
    //or
//export async function createProduct(req, res){ logic }
export const createProduct = async(req, res)=>{
    try{
        const {title, price, stock} = req.body;

        if(!title || price==null || stock==null){   //type: Number represent by null not by "!" so
            return res.status(400).json({
                success: false,
                error: "a field is missing which is required"
            });
        }

        if(price<0 || stock<0){
            return res.status(400).json({
                success: false,
                error: "price & stock cant be negative"
            })
        }

        const product = await Product.create({
            title,
            price,
            stock
        });

        return res.status(201).json({
            success: true,
            data: product
        });

    }catch(err){
        return res.status(500).json({
            success: false,
            error: err.message
        })
    }
}