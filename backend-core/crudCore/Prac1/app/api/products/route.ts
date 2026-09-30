import { NextRequest, NextResponse } from "next/server";
import {prisma} from "@/lib/prisma";

//normal search api of get 
// export async function GET(request: NextRequest){
//     try{
//         const { searchParams } = new URL(request.url);

//         const search = searchParams.get("search");
//         const category = searchParams.get("category");

//         const products = await prisma.product.findMany({
//             where:{
//                 ...(category && {
//                     category: {
//                         equals: category,
//                     },
//                 }),

//                 ...(search && { //it takes search=abc (check in all diff categories)
//                     OR: [
//                         {
//                             name: {
//                                 contains: search,
//                             },
//                         },
//                         {
//                             description:{
//                                 contains: search,
//                             },
//                         },
//                         {
//                             brand: {
//                                 contains: search,
//                             },
//                         },
//                     ],
//                 }),
//             },

//             orderBy: {
//                 createdAt: "desc",
//             },
//         });

//         return NextResponse.json({
//             success: true,
//             count: products.length,
//             data: products,
//         });
//     }catch(error){
//         console.error(error);

//         return NextResponse.json({
//             success: false,
//             message: "Failed to fetch Products",
//         }, { status: 500} );
//     }
// }

//paginartion + search:
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);

    const search = searchParams.get("search");
    const category = searchParams.get("category");

    const page = Math.max(
      Number(searchParams.get("page")) || 1,
      1
    );

    const limit = Math.min(
      Math.max(Number(searchParams.get("limit")) || 10, 1),
      100
    );

    const skip = (page - 1) * limit;

    const where = {
      ...(category && {
        category: {
          equals: category,
        },
      }),

      ...(search && {
        OR: [
          {
            name: {
              contains: search,
            },
          },
          {
            description: {
              contains: search,
            },
          },
          {
            brand: {
              contains: search,
            },
          },
        ],
      }),
    };

    const [products, total] = await Promise.all([
      prisma.product.findMany({
        where,      //it's defined above and we're reusing it here
        skip,     //these skip, take aare extra computes and passed directly from page, limit values need api to get basis of all these 3 params
        take: limit,

        orderBy: {
          createdAt: "desc",
        },
      }),

      prisma.product.count({
        where,  //and here also
      }),
    ]);

    const totalPages = Math.ceil(total / limit);

    return NextResponse.json({
      success: true,

      pagination: {
        page,
        limit,
        total,
        totalPages,
        hasNextPage: page < totalPages,
        hasPreviousPage: page > 1,
      },

      data: products,
    });
  } catch (error) {
    console.error(error);

    return NextResponse.json(
      {
        success: false,
        message: "Failed to fetch products",
      },
      { status: 500 }
    );
  }
}