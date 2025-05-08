import { Suspense } from "react";
import Image from "next/image";
import Link from "next/link";
import { CheckCircle, Clock, XCircle } from "lucide-react";

import { getAvailableProducts } from "@/lib/db/ec";
import { Card } from "@/components/ui/Card";
import { Heading1, Heading2 } from "@/components/ui/typography";

export const dynamic = "force-dynamic";
export const revalidate = 0;

export default async function ECPage() {
  const products = await getAvailableProducts();

  return (
    <div className="container mx-auto py-8">
      <div className="mb-8">
        <Heading1>商品一覧</Heading1>
        <p className="mt-2 text-muted-foreground">
          在庫のある商品を表示しています。
        </p>
      </div>

      <Suspense
        fallback={
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {Array(6)
              .fill(0)
              .map((_, i) => (
                <Card key={i} className="overflow-hidden">
                  <div className="animate-pulse">
                    <div className="h-48 bg-gray-200"></div>
                    <div className="p-4">
                      <div className="h-6 bg-gray-200 rounded w-3/4 mb-2"></div>
                      <div className="h-4 bg-gray-200 rounded w-1/2 mb-4"></div>
                      <div className="h-8 bg-gray-200 rounded w-1/3"></div>
                    </div>
                  </div>
                </Card>
              ))}
          </div>
        }
      >
        {products.length === 0 ? (
          <div className="text-center py-12">
            <p className="text-muted-foreground">
              商品が見つかりませんでした。
            </p>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {products.map((product) => (
              <Link key={product.id} href={`/ec/${product.id}`}>
                <Card className="overflow-hidden hover:shadow-md transition-shadow duration-300">
                  <div className="relative h-48 bg-gray-100">
                    {product.image_url ? (
                      <Image
                        src={product.image_url}
                        alt={product.name}
                        fill
                        sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
                        className="object-cover"
                      />
                    ) : (
                      <div className="flex items-center justify-center h-full">
                        <span className="text-gray-400">No Image</span>
                      </div>
                    )}
                    <div className="absolute top-2 right-2">
                      {product.status === "available" ? (
                        <span className="bg-green-100 text-green-800 text-xs px-2 py-1 rounded-full flex items-center">
                          <CheckCircle className="h-3 w-3 mr-1" />
                          在庫あり
                        </span>
                      ) : product.status === "checking" ? (
                        <span className="bg-yellow-100 text-yellow-800 text-xs px-2 py-1 rounded-full flex items-center">
                          <Clock className="h-3 w-3 mr-1" />
                          在庫確認中
                        </span>
                      ) : (
                        <span className="bg-red-100 text-red-800 text-xs px-2 py-1 rounded-full flex items-center">
                          <XCircle className="h-3 w-3 mr-1" />
                          在庫なし
                        </span>
                      )}
                    </div>
                  </div>
                  <div className="p-4">
                    <h3 className="font-medium text-lg mb-1 line-clamp-1">
                      {product.name}
                    </h3>
                    <p className="text-muted-foreground text-sm mb-3 line-clamp-2">
                      {product.description || "商品説明はありません"}
                    </p>
                    <div className="flex justify-between items-center">
                      <span className="font-bold text-lg">
                        ¥{product.price.toLocaleString()}
                      </span>
                      {product.status === "available" && (
                        <span className="text-sm text-muted-foreground">
                          残り{product.stock}点
                        </span>
                      )}
                    </div>
                  </div>
                </Card>
              </Link>
            ))}
          </div>
        )}
      </Suspense>
    </div>
  );
}
