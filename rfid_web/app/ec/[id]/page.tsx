import { Suspense } from "react";
import Image from "next/image";
import Link from "next/link";
import { notFound } from "next/navigation";
import {
  ArrowLeft,
  CheckCircle,
  Clock,
  ShoppingCart,
  XCircle,
} from "lucide-react";

import { getProductById } from "@/lib/db/ec";
import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Heading1 } from "@/components/ui/typography";
import { AddToCartButton } from "@/components/modules/ec/AddToCartButton";

export const dynamic = "force-dynamic";
export const revalidate = 0;

interface ProductPageProps {
  params: {
    id: string;
  };
}

export default async function ProductPage({ params }: ProductPageProps) {
  const product = await getProductById(params.id);

  if (!product) {
    notFound();
  }

  return (
    <div className="container mx-auto py-8">
      <Link href="/ec">
        <Button variant="ghost" size="sm" className="mb-6">
          <ArrowLeft className="h-4 w-4 mr-1" />
          商品一覧に戻る
        </Button>
      </Link>

      <Suspense
        fallback={
          <div className="animate-pulse">
            <div className="h-8 bg-gray-200 rounded w-3/4 mb-6"></div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
              <div className="h-96 bg-gray-200 rounded"></div>
              <div className="space-y-4">
                <div className="h-6 bg-gray-200 rounded w-1/2"></div>
                <div className="h-24 bg-gray-200 rounded"></div>
                <div className="h-8 bg-gray-200 rounded w-1/3"></div>
                <div className="h-10 bg-gray-200 rounded w-full"></div>
              </div>
            </div>
          </div>
        }
      >
        <div>
          <Heading1>{product.name}</Heading1>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mt-6">
            {/* 商品画像 */}
            <div className="relative h-96 bg-gray-100 rounded-lg overflow-hidden">
              {product.image_url ? (
                <Image
                  src={product.image_url}
                  alt={product.name}
                  fill
                  sizes="(max-width: 768px) 100vw, 50vw"
                  className="object-cover"
                  priority
                />
              ) : (
                <div className="flex items-center justify-center h-full">
                  <span className="text-gray-400 text-lg">No Image</span>
                </div>
              )}
            </div>

            {/* 商品情報 */}
            <div>
              <div className="mb-4">
                {product.status === "available" ? (
                  <span className="bg-green-100 text-green-800 text-sm px-3 py-1 rounded-full inline-flex items-center">
                    <CheckCircle className="h-4 w-4 mr-1" />
                    在庫あり（残り{product.stock}点）
                  </span>
                ) : product.status === "checking" ? (
                  <span className="bg-yellow-100 text-yellow-800 text-sm px-3 py-1 rounded-full inline-flex items-center">
                    <Clock className="h-4 w-4 mr-1" />
                    在庫確認中
                  </span>
                ) : (
                  <span className="bg-red-100 text-red-800 text-sm px-3 py-1 rounded-full inline-flex items-center">
                    <XCircle className="h-4 w-4 mr-1" />
                    在庫なし
                  </span>
                )}
              </div>

              <div className="mb-6">
                <p className="text-2xl font-bold mb-1">
                  ¥{product.price.toLocaleString()}
                </p>
                {product.category && (
                  <p className="text-sm text-muted-foreground">
                    カテゴリー: {product.category}
                  </p>
                )}
              </div>

              <div className="mb-8">
                <h2 className="text-lg font-medium mb-2">商品説明</h2>
                <p className="text-muted-foreground whitespace-pre-line">
                  {product.description || "商品説明はありません。"}
                </p>
              </div>

              <div className="space-y-3">
                <AddToCartButton
                  productId={product.id}
                  name={product.name}
                  price={product.price}
                  imageUrl={product.image_url}
                  disabled={product.status !== "available"}
                />

                {product.status !== "available" && (
                  <p className="text-sm text-muted-foreground">
                    {product.status === "checking"
                      ? "在庫確認中のため、現在購入できません。"
                      : "在庫切れのため、現在購入できません。"}
                  </p>
                )}
              </div>
            </div>
          </div>
        </div>
      </Suspense>
    </div>
  );
}
