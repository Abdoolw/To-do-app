<?php

namespace App\Http\Controllers\Api;
use App\Models\Product;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\validator;
use App\Resources\ProductResource;
use Illuminate\Http\Resources\Json\JsonResource;

class ProductController extends Controller
{
    public function index()
    {
        $products = Product::all();
        dd($products);
        return response()->json(
            [
                'status' => true,
                'message' => 'Customers retrieved successfully',
                'data' => ProductResource::collection($products),
            ],
            200,
        );
    }

    public function store(Request $request)
    {
        $validator = validator::make($request->all(), [
            'name' => 'required',
            'des' => 'required',
        ]);

        if ($validator->fails()) {
            return response()->json(
                [
                    'message' => 'All fails are mandetroy',
                    'error' => $validator->messages(),
                ],
                442,
            );
        }

        $product = Product::create([
            'name' => $request->name,
            'des' => $request->des,
        ]);

        return response()->json(
            [
                'massage' => 'product created',
                'data' => $product,
                //new ProductResource($product)
            ],
            201,
        );
    }

    public function show(Product $product)
    {
        return $product;
    }

    public function update(Request $request, Product $product)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string',
            'des' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json(
                [
                    'message' => 'Validation failed',
                    'errors' => $validator->errors(),
                ],
                422,
            );
        }

        try {
            $product->update([
                'name' => $request->name,
                'des' => $request->des,
            ]);

            return response()->json(
                [
                    'message' => 'Product updated successfully',
                    'data' => $product,
                ],
                200,
            );
        } catch (\Exception $e) {
            return response()->json(
                [
                    'message' => 'An error occurred while updating the product',
                    'error' => $e->getMessage(),
                ],
                500,
            );
        }
    }

    public function destroy(Product $product)
    {
        $product->delete();
        return response()->json(
            [
                'massage' => 'product Deleted',
            ],
            200,
        );
    }
}
