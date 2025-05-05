import Link from "next/link";
import { notFound } from "next/navigation";

import { getInventoryMasterById } from "@/lib/db/inventory-master";
import { Button } from "@/components/ui/Button";
import { Heading2 } from "@/components/ui/typography";
import InventoryMasterEditForm from "@/components/modules/inventory/InventoryMasterEditForm";

interface EditInventoryMasterPageProps {
  params: {
    id: string;
  };
}

export const dynamic = "force-dynamic";

export default async function EditInventoryMasterPage({
  params,
}: EditInventoryMasterPageProps) {
  try {
    const inventoryMaster = await getInventoryMasterById(params.id);

    return (
      <div className="container mx-auto py-8">
        <div className="mb-6 flex items-center justify-between">
          <Heading2>在庫管理マスター編集</Heading2>
          <div className="flex space-x-2">
            <Link href={`/inventory/masters/${params.id}`}>
              <Button variant="outline">詳細に戻る</Button>
            </Link>
            <Link href="/inventory/masters">
              <Button variant="outline">一覧に戻る</Button>
            </Link>
          </div>
        </div>

        <InventoryMasterEditForm inventoryMaster={inventoryMaster} />
      </div>
    );
  } catch (error) {
    console.error("Error fetching inventory master:", error);
    notFound();
  }
}
