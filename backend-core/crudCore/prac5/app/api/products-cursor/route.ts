import { NextRequest, NextResponse} from "next/server";
import { prisma} from "@/lib/prisma";

export async function GET(req: NextRequest){
    try{
        const {searchParams} = new URL(req.url);

        const cursorParam = searchParams.get("cursor");

        //taking limit from query params, if not present then taking default value as 10, and also limiting it to max 100
        const limit = Math.min(100,
            Math.max(1, Number(searchParams.get("limit")) || 10)
        );

        //taking cursor from query params, if not present then taking default value as null
        const cursor = cursorParam? Number(cursorParam) : null;

        //validating cursor value, if cursor is present then it should be a positive integer
        if( cursorParam !==null && (cursor === null || !Number.isInteger(cursor) || cursor <=0)){
            return NextResponse.json({
                success: false,
                message: "InValid cursor value",
            }, { status: 400});
        }

        const products = await prisma.product.findMany({
            take: limit+1,

            //if cursor is present then taking products whose id is greater than cursor, otherwise taking all products
            ...(cursor && {
                where: {
                    id: {//gt means greater than, so taking products whose id is greater than cursor
                        gt: cursor,
                    },
                },
            }),

            orderBy: {
                id: "asc",
            },
        });

        const hasNextPage = products.length > limit;

        //removing extra product if hasNextPage is true, so that we can send only limit number of products in response
        //taking only limit number of products if hasNextPage is true, otherwise taking all products
        const data = hasNextPage? products.slice(0, limit) : products;

        //getting nextCursor value, if data is not empty then taking id of last product in data as nextCursor, otherwise null
        const nextCursor = data.length > 0 ? data[data.length -1].id : null;

        return NextResponse.json({
            success: true,

            //sending pagination info in response
            pagination: {
                limit,
                hasNextPage,
                nextCursor,
            },

            data,
        })
    }catch(error){
        console.error(error);

        return NextResponse.json({
            success: false,
            message: "Failed to fetch products",
        }, { status: 500});
    }
}