"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { Edit, Eye, Plus, Search } from "lucide-react";

import { InventoryMaster } from "@/lib/db";
import { getInventoryMasters } from "@/lib/db/inventory-master";
import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Input } from "@/components/ui/Input";
import { Heading2 } from "@/components/ui/typography";
import { getTargetLabel } from "@/components/modules/inventory/schema";

export default function InventoryMastersPage() {
  const [inventoryMasters, setInventoryMasters] = useState<InventoryMaster[]>(
    []
  );
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState("");
  const [filteredMasters, setFilteredMasters] = useState<InventoryMaster[]>([]);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const data = await getInventoryMasters();
        setInventoryMasters(data);
        setFilteredMasters(data);
      } catch (error) {
        console.error("Error fetching inventory masters:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  useEffect(() => {
    if (searchTerm.trim() === "") {
      setFilteredMasters(inventoryMasters);
      return;
    }

    const lowercasedSearch = searchTerm.toLowerCase();
    const filtered = inventoryMasters.filter(
      (master) =>
        master.col_1?.toLowerCase().includes(lowercasedSearch) ||
        master.col_2?.toLowerCase().includes(lowercasedSearch) ||
        master.col_3?.toLowerCase().includes(lowercasedSearch) ||
        master.product_code?.toLowerCase().includes(lowercasedSearch)
    );
    setFilteredMasters(filtered);
  }, [searchTerm, inventoryMasters]);

  return (
    <div className="container mx-auto py-8">
      <div className="mb-6 flex items-center justify-between">
        <Heading2>在庫管理マスター</Heading2>
        <Link href="/inventory/masters/new">
          <Button>
            <Plus className="mr-2 h-4 w-4" />
            新規登録
          </Button>
        </Link>
      </div>

      <div className="mb-6">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            placeholder="検索..."
            className="pl-10"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
      </div>

      {loading ? (
        <Card className="p-6 text-center">
          <p className="text-muted-foreground">読み込み中...</p>
        </Card>
      ) : filteredMasters.length === 0 ? (
        <Card className="p-6 text-center">
          <p className="text-muted-foreground">
            {searchTerm
              ? "検索条件に一致する在庫管理マスターがありません。"
              : "登録された在庫管理マスターがありません。"}
          </p>
          {!searchTerm && (
            <p className="mt-2">
              「新規登録」ボタンをクリックして、最初の在庫管理マスターを登録しましょう。
            </p>
          )}
        </Card>
      ) : (
        <div className="overflow-x-auto rounded-md border">
          <table className="w-full">
            <thead>
              <tr className="border-b bg-muted/50">
                <th className="px-4 py-3 text-left font-medium">項目1</th>
                <th className="px-4 py-3 text-left font-medium">項目2</th>
                <th className="px-4 py-3 text-left font-medium">項目3</th>
                <th className="px-4 py-3 text-left font-medium">商品コード</th>
                <th className="px-4 py-3 text-left font-medium">業種</th>
                <th className="px-4 py-3 text-left font-medium">作成日</th>
                <th className="px-4 py-3 text-left font-medium">操作</th>
              </tr>
            </thead>
            <tbody>
              {filteredMasters.map((master) => (
                <tr key={master.id} className="border-b">
                  <td className="px-4 py-3">{master.col_1}</td>
                  <td className="px-4 py-3 max-w-xs truncate">
                    {master.col_2 || "-"}
                  </td>
                  <td className="px-4 py-3">{master.col_3 || "-"}</td>
                  <td className="px-4 py-3">{master.product_code || "-"}</td>
                  <td className="px-4 py-3">
                    <span className="rounded bg-primary/10 px-2 py-1 text-xs text-primary">
                      {getTargetLabel(master.target)}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    {new Date(master.created_at).toLocaleDateString("ja-JP")}
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex space-x-2">
                      <Link href={`/inventory/masters/${master.id}`}>
                        <Button variant="ghost" size="sm">
                          <Eye className="h-4 w-4" />
                        </Button>
                      </Link>
                      <Link href={`/inventory/masters/${master.id}/edit`}>
                        <Button variant="ghost" size="sm">
                          <Edit className="h-4 w-4" />
                        </Button>
                      </Link>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
