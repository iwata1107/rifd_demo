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
                <h4 className="mb-1 font-semibold">説明</h4>
                <p className="text-muted-foreground">{inventoryMaster.col_2}</p>
              </div>
            )}

            {inventoryMaster.col_3 && (
              <div>
                <h4 className="mb-1 font-semibold">カテゴリ</h4>
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
