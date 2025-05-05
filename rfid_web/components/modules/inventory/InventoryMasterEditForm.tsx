"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";

import { InventoryMaster } from "@/lib/db";
import { updateInventoryMaster } from "@/lib/db/inventory-master";
import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { InputField, TextAreaField } from "@/components/ui/form/form-fields";
import { Label } from "@/components/ui/Label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/Select";
import { toast } from "@/components/ui/use-toast";

import {
  InventoryMasterFormValues,
  inventoryMasterSchema,
  targetOptions,
} from "./schema";

interface InventoryMasterEditFormProps {
  inventoryMaster: InventoryMaster;
}

export default function InventoryMasterEditForm({
  inventoryMaster,
}: InventoryMasterEditFormProps) {
  const router = useRouter();
  const [isSubmitting, setIsSubmitting] = useState(false);

  const { register, handleSubmit, formState, setValue, watch } =
    useForm<InventoryMasterFormValues>({
      resolver: zodResolver(inventoryMasterSchema),
      defaultValues: {
        col_1: inventoryMaster.col_1 || "",
        col_2: inventoryMaster.col_2 || "",
        col_3: inventoryMaster.col_3 || "",
        product_code: inventoryMaster.product_code || "",
        target: inventoryMaster.target,
      },
    });

  const onSubmit = async (data: InventoryMasterFormValues) => {
    try {
      setIsSubmitting(true);
      await updateInventoryMaster(inventoryMaster.id, data);
      toast({
        title: "更新完了",
        description: "在庫管理マスターを更新しました",
      });
      router.refresh();
      router.push(`/inventory/masters/${inventoryMaster.id}`);
    } catch (error) {
      console.error("Error updating inventory master:", error);
      toast({
        title: "エラー",
        description: "在庫管理マスターの更新に失敗しました",
        variant: "destructive",
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleTargetChange = (value: string) => {
    setValue("target", value as any);
  };

  const selectedTarget = watch("target");

  return (
    <Card className="p-6">
      <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
        <div className="space-y-4">
          <div>
            <Label htmlFor="col_1">
              項目1 <span className="text-red-500">*</span>
            </Label>
            <InputField
              id="col_1"
              placeholder="項目1を入力してください"
              register={register}
              name="col_1"
              formState={formState}
            />
          </div>

          <div>
            <Label htmlFor="col_2">項目2</Label>
            <TextAreaField
              id="col_2"
              placeholder="項目2を入力してください"
              register={register}
              name="col_2"
              formState={formState}
            />
          </div>

          <div>
            <Label htmlFor="col_3">項目3</Label>
            <InputField
              id="col_3"
              placeholder="項目3を入力してください"
              register={register}
              name="col_3"
              formState={formState}
            />
          </div>

          <div>
            <Label htmlFor="product_code">商品コード</Label>
            <InputField
              id="product_code"
              placeholder="商品コード/SKU"
              register={register}
              name="product_code"
              formState={formState}
            />
          </div>

          <div>
            <Label htmlFor="target">
              業種 <span className="text-red-500">*</span>
            </Label>
            <div className="relative">
              <Select value={selectedTarget} onValueChange={handleTargetChange}>
                <SelectTrigger className="w-full">
                  <SelectValue placeholder="業種を選択してください" />
                </SelectTrigger>
                <SelectContent>
                  {targetOptions.map((option) => (
                    <SelectItem key={option.value} value={option.value}>
                      {option.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
              {formState.errors.target && (
                <p className="mt-1 text-xs text-red-500">
                  {formState.errors.target.message}
                </p>
              )}
            </div>
          </div>
        </div>

        <div className="flex justify-end space-x-2">
          <Button
            type="button"
            variant="outline"
            onClick={() => router.back()}
            disabled={isSubmitting}
          >
            キャンセル
          </Button>
          <Button type="submit" disabled={isSubmitting}>
            {isSubmitting ? "更新中..." : "更新する"}
          </Button>
        </div>
      </form>
    </Card>
  );
}
