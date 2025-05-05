import Link from "next/link";

import { getInventoryMasters } from "@/lib/db/inventory-master";
import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Heading2 } from "@/components/ui/typography";
import { getTargetLabel } from "@/components/modules/inventory/schema";

export const dynamic = "force-dynamic";

export default async function InventoryMastersPage() {
  const inventoryMasters = await getInventoryMasters();

  return (
    <div className="container mx-auto py-8">
      <div className="mb-6 flex items-center justify-between">
        <Heading2>在庫管理マスター</Heading2>
        <Link href="/inventory/masters/new">
          <Button>新規登録</Button>
        </Link>
      </div>

      {inventoryMasters.length === 0 ? (
        <Card className="p-6 text-center">
          <p className="text-muted-foreground">
            登録された在庫管理マスターがありません。
          </p>
          <p className="mt-2">
            「新規登録」ボタンをクリックして、最初の在庫管理マスターを登録しましょう。
          </p>
        </Card>
      ) : (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          {inventoryMasters.map((master) => (
            <Link
              href={`/inventory/masters/${master.id}`}
              key={master.id}
              className="block"
            >
              <Card className="h-full p-4 transition-shadow hover:shadow-md">
                <div className="mb-2 flex items-center justify-between">
                  <h3 className="text-lg font-semibold">{master.col_1}</h3>
                  <span className="rounded bg-primary/10 px-2 py-1 text-xs text-primary">
                    {getTargetLabel(master.target)}
                  </span>
                </div>
                {master.col_2 && (
                  <p className="mb-2 text-sm text-muted-foreground line-clamp-2">
                    {master.col_2}
                  </p>
                )}
                {master.col_3 && (
                  <div className="text-xs text-muted-foreground">
                    カテゴリ: {master.col_3}
                  </div>
                )}
                {master.product_code && (
                  <div className="text-xs text-muted-foreground">
                    商品コード: {master.product_code}
                  </div>
                )}
                <div className="mt-2 text-xs text-muted-foreground">
                  作成日:{" "}
                  {new Date(master.created_at).toLocaleDateString("ja-JP")}
                </div>
              </Card>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
