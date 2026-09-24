import Comment from "../models/Comment.js";

const createComment = async(req, res)=>{
    try{
        const { text, author, parentId} = req.body;

        if(!text || text.trim()==""){
            return res.status(400).json({
                success: false,
                error: "comment text is required"   //console.log inside a JSON response object.
            });
        }

        if(parentId){
            const parent = await Comment.findById(parentId);

            if(!parentId){  //required to prevent an orphan comment creation
                return res.status(404).json({
                    success: false,
                    error: "Parent comment not found"
                });
            }
        }

        const comment = await Comment.create({
            text, 
            author: author || 'Anonymous',
            parentId: parentId || null
        });

        return res.status(201).json({
            success: true,
            data: comment
        });

    }catch(err){
        return res.status(500).json({
            success: false, 
            error: err.message
        });
    }
}

const getComment = async(req, res)=>{
    try{
        const comments = await Comment.find()
        .sort({createdAt: 1}).lean();
        //Mongoose skips all that wrapping. It gives you a plain, everyday JavaScript {} object: helps add replies to comment

        const commentMap = {};
        const rootComments = [];

        //Pass1:
        comments.forEach((comment)=>{
            commentMap[comment._id.toString()]={
                ...comment,
                replies: [] //currently all replied associate with each comment is empty here pushing to next pass
            }
        });

        //Pass2:
        comments.forEach((comment)=>{
            if(comment.parentId){   //most imp step if parentId associate(offcource associated with all so need extract and then check if null or dome id's) then it's child (reply) to that parent(comment) 
                const parentId = comment.parentId.toString();

                if(commentMap[parentId]){   //parent nikal ke map mei parent wale comment ke replies mei iss curr comment ko push krdo
                    commentMap[parentId].replies.push(
                        commentMap[comment._id.toString()]  //furthur having comment map as with nested replies [] more
                    );
                }
            }else{  //if parent not associated means that id condition not satisfied =means (null) hai
                rootComments.push(
                    commentMap[comment._id.toString()]
                );
            }
        })

        return res.status(200).json({
            success: true, 
            data: rootComments
        })

    }catch(err){
        return res.status(500).json({
            status: false, 
            error: err.message 
        })
    }
}

export {createComment, getComment};