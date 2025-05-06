"use client";

import { useEffect, useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { Eye, Filter, Search } from "lucide-react";

import { InventoryMaster, Item } from "@/lib/db";
import { getItemsWithMasterInfo } from "@/lib/db/items";
import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Input } from "@/components/ui/Input";
import { Label } from "@/components/ui/Label";
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/Popover";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/Select";
import { Switch } from "@/components/ui/Switch";
import { Heading2 } from "@/components/ui/typography";
import {
  getTargetLabel,
  targetOptions,
} from "@/components/modules/inventory/schema";

type ItemWithMaster = Item & { inventory_masters: InventoryMaster };

export default function ItemsPage() {
  const [items, setItems] = useState<ItemWithMaster[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState("");
  const [filteredItems, setFilteredItems] = useState<ItemWithMaster[]>([]);

  // フィルターのデフォルト値は "all" とする（空文字列は Radix Select.Item で使用不可のため）
  const [targetFilter, setTargetFilter] = useState<string>("all");
  const [inventoryStatusFilter, setInventoryStatusFilter] =
    useState<string>("all");

  useEffect(() => {
    const fetchData = async () => {
      try {
        const data = await getItemsWithMasterInfo();
        setItems(data);
        setFilteredItems(data);
      } catch (error) {
        console.error("Error fetching items:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  useEffect(() => {
    let filtered = [...items];

    // 検索フィルター
    if (searchTerm.trim() !== "") {
      const lowercasedSearch = searchTerm.toLowerCase();
      filtered = filtered.filter(
        (item) =>
          item.rfid.toLowerCase().includes(lowercasedSearch) ||
          item.inventory_masters.col_1
            .toLowerCase()
            .includes(lowercasedSearch) ||
          (item.inventory_masters.col_2 &&
            item.inventory_masters.col_2
              .toLowerCase()
              .includes(lowercasedSearch)) ||
          (item.inventory_masters.col_3 &&
            item.inventory_masters.col_3
              .toLowerCase()
              .includes(lowercasedSearch)) ||
          (item.inventory_masters.product_code &&
            item.inventory_masters.product_code
              .toLowerCase()
              .includes(lowercasedSearch))
      );
    }

    // 業種フィルター
    if (targetFilter && targetFilter !== "all") {
      filtered = filtered.filter(
        (item) => item.inventory_masters.target === targetFilter
      );
    }

    // 在庫状態フィルター
    if (inventoryStatusFilter && inventoryStatusFilter !== "all") {
      const isInventoried = inventoryStatusFilter === "true";
      filtered = filtered.filter(
        (item) => item.is_inventoried === isInventoried
      );
    }

    setFilteredItems(filtered);
  }, [searchTerm, items, targetFilter, inventoryStatusFilter]);

  const resetFilters = () => {
    setTargetFilter("all");
    setInventoryStatusFilter("all");
  };

  return (
    <div className="container mx-auto py-8">
      <div className="mb-6 flex items-center justify-between">
        <Heading2>RFIDアイテム一覧</Heading2>
      </div>

      <div className="mb-6 flex flex-col md:flex-row gap-4">
        <div className="relative flex-grow">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            placeholder="RFIDまたは商品名で検索..."
            className="pl-10"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>

        <Popover>
          <PopoverTrigger asChild>
            <Button variant="outline" className="gap-2">
              <Filter className="h-4 w-4" />
              フィルター
            </Button>
          </PopoverTrigger>
          <PopoverContent className="w-80">
            <div className="grid gap-4">
              <div className="space-y-2">
                <h4 className="font-medium">業種</h4>
                <Select value={targetFilter} onValueChange={setTargetFilter}>
                  <SelectTrigger>
                    <SelectValue placeholder="すべての業種" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">すべての業種</SelectItem>
                    {targetOptions.map((option) => (
                      <SelectItem key={option.value} value={option.value}>
                        {option.label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <h4 className="font-medium">在庫状態</h4>
                <Select
                  value={inventoryStatusFilter}
                  onValueChange={setInventoryStatusFilter}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="すべての状態" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">すべての状態</SelectItem>
                    <SelectItem value="true">在庫済み</SelectItem>
                    <SelectItem value="false">未在庫</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <Button variant="outline" onClick={resetFilters}>
                フィルターをリセット
              </Button>
            </div>
          </PopoverContent>
        </Popover>
      </div>

      {loading ? (
        <Card className="p-6 text-center">
          <p className="text-muted-foreground">読み込み中...</p>
        </Card>
      ) : filteredItems.length === 0 ? (
        <Card className="p-6 text-center">
          <p className="text-muted-foreground">
            {searchTerm || targetFilter || inventoryStatusFilter
              ? "検索条件に一致するアイテムがありません。"
              : "登録されたアイテムがありません。"}
          </p>
        </Card>
      ) : (
        <div className="overflow-x-auto rounded-md border">
          <table className="w-full">
            <thead>
              <tr className="border-b bg-muted/50">
                <th className="px-4 py-3 text-left font-medium">RFID</th>
                <th className="px-4 py-3 text-left font-medium">商品名</th>
                <th className="px-4 py-3 text-left font-medium">商品コード</th>
                <th className="px-4 py-3 text-left font-medium">業種</th>
                <th className="px-4 py-3 text-left font-medium">画像</th>
                <th className="px-4 py-3 text-left font-medium">在庫状態</th>
                <th className="px-4 py-3 text-left font-medium">作成日</th>
                <th className="px-4 py-3 text-left font-medium">操作</th>
              </tr>
            </thead>
            <tbody>
              {filteredItems.map((item) => (
                <tr key={item.id} className="border-b">
                  <td className="px-4 py-3 font-mono text-sm">{item.rfid}</td>
                  <td className="px-4 py-3">{item.inventory_masters.col_1}</td>
                  <td className="px-4 py-3">
                    {item.inventory_masters.product_code || "-"}
                  </td>
                  <td className="px-4 py-3">
                    <span className="rounded bg-primary/10 px-2 py-1 text-xs text-primary">
                      {getTargetLabel(item.inventory_masters.target)}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    {item.inventory_masters.product_image ? (
                      <div className="relative h-10 w-10 overflow-hidden rounded border">
                        <Image
                          src={item.inventory_masters.product_image}
                          alt={`${item.inventory_masters.col_1}のサムネイル`}
                          fill
                          style={{ objectFit: "cover" }}
                          onError={(e) => {
                            e.currentTarget.style.display = "none";
                            e.currentTarget.parentElement!.innerHTML =
                              '<div class="flex h-full w-full items-center justify-center bg-gray-100 text-xs text-gray-500">×</div>';
                          }}
                        />
                      </div>
                    ) : (
                      "-"
                    )}
                  </td>
                  <td className="px-4 py-3">
                    <span
                      className={`rounded px-2 py-1 text-xs ${
                        item.is_inventoried
                          ? "bg-green-100 text-green-800"
                          : "bg-amber-100 text-amber-800"
                      }`}
                    >
                      {item.is_inventoried ? "在庫済み" : "未在庫"}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    {new Date(item.created_at).toLocaleDateString("ja-JP")}
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex space-x-2">
                      <Link
                        href={`/inventory/masters/${item.inventory_master_id}`}
                      >
                        <Button
                          variant="ghost"
                          size="sm"
                          title="マスター詳細を表示"
                        >
                          <Eye className="h-4 w-4" />
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
