"use client";

import { useEffect, useState } from "react";

import { InventoryMaster, Item } from "@/lib/db";
import { getInventoryMasters } from "@/lib/db/inventory-master";
import { getItems } from "@/lib/db/items";
import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Heading2 } from "@/components/ui/typography";
import { getTargetLabel } from "@/components/modules/inventory/schema";

export default function InventoryPrintPage() {
  const [loading, setLoading] = useState(true);
  const [masters, setMasters] = useState<InventoryMaster[]>([]);
  const [itemCountMap, setItemCountMap] = useState<Record<string, number>>({});

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [mastersData, itemsData] = await Promise.all([
          getInventoryMasters(),
          getItems(),
        ]);

        const map: Record<string, number> = {};
        (itemsData as Item[]).forEach((item) => {
          const id = item.inventory_master_id;
          map[id] = (map[id] ?? 0) + 1;
        });

        setMasters(mastersData);
        setItemCountMap(map);
      } catch (error) {
        console.error("Error fetching inventory data:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  const handlePrint = () => {
    window.print();
  };

  return (
    <div className="container mx-auto py-8 print:py-0">
      <div className="mb-6 flex items-center justify-between print:hidden">
        <Heading2>棚卸し用 在庫一覧</Heading2>
        <Button onClick={handlePrint}>印刷</Button>
      </div>

      {loading ? (
        <Card className="p-6 text-center">
          <p className="text-muted-foreground">読み込み中...</p>
        </Card>
      ) : (
        <div className="overflow-x-auto rounded-md border">
          <table className="w-full print:w-auto print:text-xs">
            <thead className="print:table-header-group">
              <tr className="border-b bg-muted/50">
                <th className="px-4 py-2 text-left font-medium">項目1</th>
                <th className="px-4 py-2 text-left font-medium">商品コード</th>
                <th className="px-4 py-2 text-left font-medium">業種</th>
                <th className="px-4 py-2 text-left font-medium">在庫数</th>
                <th className="px-4 py-2 text-left font-medium print-hidden">
                  実棚数
                </th>
              </tr>
            </thead>
            <tbody>
              {masters.map((master) => (
                <tr key={master.id} className="border-b">
                  <td className="px-4 py-2">{master.col_1}</td>
                  <td className="px-4 py-2">{master.product_code || "-"}</td>
                  <td className="px-4 py-2">{getTargetLabel(master.target)}</td>
                  <td className="px-4 py-2">{itemCountMap[master.id] ?? 0}</td>
                  <td className="px-4 py-2 print:hidden">
                    {/* 空欄にして現場で記入してもらう */}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
      <style jsx global>{`
        @media print {
          /* 印刷時は余計なUIを非表示 */
          .print\:hidden {
            display: none !important;
          }
          .print\:py-0 {
            padding-top: 0 !important;
            padding-bottom: 0 !important;
          }
          .print\:text-xs {
            font-size: 12px !important;
          }
          .print\:w-auto {
            width: auto !important;
          }
          .print\:table-header-group {
            display: table-header-group !important;
          }
        }
      `}</style>
    </div>
  );
}
