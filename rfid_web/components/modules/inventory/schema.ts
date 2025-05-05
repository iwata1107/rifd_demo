import { z } from "zod";

import { Constants } from "@/lib/db/database.types";

// 在庫管理マスターのスキーマ定義
export const inventoryMasterSchema = z.object({
  col_1: z
    .string()
    .min(1, { message: "名前は必須です" })
    .max(100, { message: "名前は100文字以内で入力してください" }),
  col_2: z
    .string()
    .max(500, { message: "説明は500文字以内で入力してください" })
    .optional()
    .nullable(),
  col_3: z
    .string()
    .max(50, { message: "カテゴリは50文字以内で入力してください" })
    .optional()
    .nullable(),
  product_code: z
    .string()
    .max(50, { message: "商品コードは50文字以内で入力してください" })
    .optional()
    .nullable(),
  target: z.enum(["clinic", "card_shop"] as const, {
    required_error: "業種を選択してください",
    invalid_type_error: "業種の選択が無効です",
  }),
});

// フォーム用のスキーマ型定義
export type InventoryMasterFormValues = z.infer<typeof inventoryMasterSchema>;

// 業種の選択肢
export const targetOptions = Constants.public.Enums.target_type.map(
  (value) => ({
    value,
    label: getTargetLabel(value),
  })
);

// 業種の表示名を取得する関数
export function getTargetLabel(target: string): string {
  switch (target) {
    case "clinic":
      return "クリニック";
    case "card_shop":
      return "カードショップ";
    default:
      return target;
  }
}
