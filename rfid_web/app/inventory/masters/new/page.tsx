import Link from "next/link";

import { Button } from "@/components/ui/Button";
import { Heading2 } from "@/components/ui/typography";
import InventoryMasterForm from "@/components/modules/inventory/InventoryMasterForm";

export default function NewInventoryMasterPage() {
  return (
    <div className="container mx-auto py-8">
      <div className="mb-6 flex items-center justify-between">
        <Heading2>在庫管理マスター登録</Heading2>
        <Link href="/inventory/masters">
          <Button variant="outline">一覧に戻る</Button>
        </Link>
      </div>

      <InventoryMasterForm />
    </div>
  );
}
