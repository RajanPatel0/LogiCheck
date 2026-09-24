import mongoose from "mongoose";

const commentSchema = new mongoose.Schema({
    text: {
        type: String,
        required: true,
        trim: true
    },
    author: {
        type: String,
        default: 'Anonymous'
    },
    parentId: {
        type: mongoose.Schema.Types.ObjectId,   //parentId = ID of another comment
        ref: "Comment",
        default: null
    },
}, {timestamps: true});

// export default mongoose.model('Comment', commentSchema);
const Comment = mongoose.model('Comment', commentSchema);
export default Comment;