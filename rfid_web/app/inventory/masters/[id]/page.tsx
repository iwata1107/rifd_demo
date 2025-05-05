import Image from "next/image";
import Link from "next/link";
import { notFound } from "next/navigation";

import { getInventoryMasterById } from "@/lib/db/inventory-master";
import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Heading2, Heading3 } from "@/components/ui/typography";
import { getTargetLabel } from "@/components/modules/inventory/schema";

interface InventoryMasterDetailPageProps {
  params: {
    id: string;
  };
}

export const dynamic = "force-dynamic";

export default async function InventoryMasterDetailPage({
  params,
}: InventoryMasterDetailPageProps) {
  try {
    console.log(params);
    const inventoryMaster = await getInventoryMasterById(params.id);

    return (
      <div className="container mx-auto py-8">
        <div className="mb-6 flex items-center justify-between">
          <Heading2>在庫管理マスター詳細</Heading2>
          <div className="flex space-x-2">
            <Link href={`/inventory/masters/${params.id}/edit`}>
              <Button variant="outline">編集</Button>
            </Link>
            <Link href="/inventory/masters">
              <Button variant="outline">一覧に戻る</Button>
            </Link>
          </div>
        </div>

        <Card className="p-6">
          <div className="mb-4 flex items-center justify-between">
            <Heading3>{inventoryMaster.col_1}</Heading3>
            <span className="rounded bg-primary/10 px-3 py-1 text-sm text-primary">
              {getTargetLabel(inventoryMaster.target)}
            </span>
          </div>

          <div className="space-y-4">
            {inventoryMaster.col_2 && (
              <div>
                <h4 className="mb-1 font-semibold">項目2</h4>
                <p className="text-muted-foreground">{inventoryMaster.col_2}</p>
              </div>
            )}

            {inventoryMaster.col_3 && (
              <div>
                <h4 className="mb-1 font-semibold">項目3</h4>
                <p className="text-muted-foreground">{inventoryMaster.col_3}</p>
              </div>
            )}

            {inventoryMaster.product_code && (
              <div>
                <h4 className="mb-1 font-semibold">商品コード</h4>
                <p className="text-muted-foreground">
                  {inventoryMaster.product_code}
                </p>
              </div>
            )}

            {inventoryMaster.product_image && (
              <div>
                <h4 className="mb-1 font-semibold">商品画像</h4>
                <div className="relative mt-2 h-60 w-full overflow-hidden rounded border">
                  <Image
                    src={inventoryMaster.product_image}
                    alt={`${inventoryMaster.col_1}の画像`}
                    fill
                    style={{ objectFit: "contain" }}
                    onError={(e) => {
                      // エラー時に代替テキストを表示
                      e.currentTarget.style.display = "none";
                      e.currentTarget.parentElement!.innerHTML =
                        '<div class="flex h-full w-full items-center justify-center bg-gray-100 text-sm text-gray-500">画像を読み込めませんでした</div>';
                    }}
                  />
                </div>
                <p className="mt-1 text-xs text-muted-foreground break-all">
                  URL: {inventoryMaster.product_image}
                </p>
              </div>
            )}

            <div className="grid grid-cols-2 gap-4 pt-4 border-t">
              <div>
                <h4 className="mb-1 text-sm font-semibold">作成日</h4>
                <p className="text-sm text-muted-foreground">
                  {new Date(inventoryMaster.created_at).toLocaleDateString(
                    "ja-JP"
                  )}
                </p>
              </div>
              <div>
                <h4 className="mb-1 text-sm font-semibold">更新日</h4>
                <p className="text-sm text-muted-foreground">
                  {new Date(inventoryMaster.updated_at).toLocaleDateString(
                    "ja-JP"
                  )}
                </p>
              </div>
            </div>
          </div>
        </Card>
      </div>
    );
  } catch (error) {
    console.error("Error fetching inventory master:", error);
    notFound();
  }
}
