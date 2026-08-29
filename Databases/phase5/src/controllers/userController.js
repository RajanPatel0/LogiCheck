import prisma from "../lib/prisma.js";  //only required here if you are using prisma in this file so as to avoid circular dependency issues over all other files. If you are using prisma in other files, you can import it there as well.

// export const getUsers = prisma.user.findMany()
//   .then((users) => {
//     console.log(users);
//   })
//   .catch((error) => {
//     console.error(error);
//   });   
//This above is wrong:
    // 1. it runs immediately when the file is imported (bcoz of the .then() and .catch() chaining)
    // 2. it is not an Express request handler (bcoz it does not take req, res, next as parameters)
    // 3. it does not send res.json(...) (so it will not send a response to the client)
    // 4. it is not the pattern for Express controllers (bcoz it does not use async/await and try/catch for error handling)

export const getUsers = async(req, res)=>{
    try{
        const users = await prisma.admin.findMany();
        res.json(users);
    }catch(error){
        console.error("Prisma error:", error);
        res.status(500).json({
            error: "error fetching users",
        })
    }
}