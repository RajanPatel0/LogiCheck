import { NextRequest, NextResponse} from "next/server";
import { prisma } from "@/lib/prisma";

export async function GET(req: NextRequest){
    try{
        const { searchParams } = new URL(req.url);

        const page = Math.max(1,
            Number(searchParams.get("page")) || 1
        );

        //safe check by taking 100 or min limit
        const limit = Math.min(100,
            Math.max(1, Number(searchParams.get("limit")) || 10)
        );

        const skip = (page-1) * limit;

        const [products, total] = await Promise.all([
            prisma.product.findMany({
                skip,
                take: limit,

                orderBy: {
                    id: "asc",
                },
            }),

            prisma.product.count(),     //it gives total
        ]);

        return NextResponse.json({
            success: true,

            pagination: {
                page,
                limit,
                total,
                totalPages: Math.ceil(total / limit),
            },

            data : products,
        });
    }catch(error){
        console.error(error);

        return NextResponse.json({
            success: false,
            message: "Failed to fetch Products",
        },{ status: 500});
    }
}