import { Database } from "@/lib/db/database.types";
import { createClient } from "@/lib/supabase/client";

export type ECProduct = {
  id: string;
  name: string;
  description: string | null;
  price: number;
  image_url: string | null;
  stock: number;
  status: "available" | "out_of_stock" | "checking";
  category: string | null;
  created_at: string;
};

/**
 * 在庫のある商品を取得する
 * 在庫がゼロのマスターと棚卸し済みでない商品は在庫確認中ステータスにする
 */
export async function getAvailableProducts(): Promise<ECProduct[]> {
  const supabase = createClient();

  // マスターと在庫データを結合して取得
  const { data, error } = await supabase
    .from("inventory_masters")
    .select(
      `
      id,
      col_1,
      col_2,
      col_3,
      product_image,
      target,
      created_at,
      items:items(id, rfid, is_inventoried)
    `
    )
    .order("created_at", { ascending: false });

  if (error) {
    console.error("Error fetching products:", error);
    return [];
  }

  // 商品データを整形
  const products: ECProduct[] = data.map((master) => {
    // 在庫数をカウント（棚卸し済みの商品のみ）
    const inventoriedItems = master.items.filter(
      (item) => item.is_inventoried === true
    );
    const stock = inventoriedItems.length;

    // 在庫ステータスを判定
    let status: ECProduct["status"] = "available";
    if (stock === 0) {
      status = "out_of_stock";
    } else if (master.items.length > 0 && inventoriedItems.length === 0) {
      // 商品はあるが棚卸し済みのものがない場合は在庫確認中
      status = "checking";
    }

    // 価格を数値に変換
    const price = master.col_3 ? parseFloat(master.col_3) : 0;

    return {
      id: master.id,
      name: master.col_1,
      description: master.col_2,
      price,
      image_url: master.product_image,
      stock,
      status,
      category: master.target,
      created_at: master.created_at,
    };
  });

  return products;
}

/**
 * 商品IDから商品詳細を取得する
 */
export async function getProductById(id: string): Promise<ECProduct | null> {
  const supabase = createClient();

  const { data, error } = await supabase
    .from("inventory_masters")
    .select(
      `
      id,
      col_1,
      col_2,
      col_3,
      product_image,
      target,
      created_at,
      items:items(id, rfid, is_inventoried)
    `
    )
    .eq("id", id)
    .single();

  if (error || !data) {
    console.error("Error fetching product:", error);
    return null;
  }

  // 在庫数をカウント（棚卸し済みの商品のみ）
  const inventoriedItems = data.items.filter(
    (item) => item.is_inventoried === true
  );
  const stock = inventoriedItems.length;

  // 在庫ステータスを判定
  let status: ECProduct["status"] = "available";
  if (stock === 0) {
    status = "out_of_stock";
  } else if (data.items.length > 0 && inventoriedItems.length === 0) {
    // 商品はあるが棚卸し済みのものがない場合は在庫確認中
    status = "checking";
  }

  // 価格を数値に変換
  const price = data.col_3 ? parseFloat(data.col_3) : 0;

  return {
    id: data.id,
    name: data.col_1,
    description: data.col_2,
    price,
    image_url: data.product_image,
    stock,
    status,
    category: data.target,
    created_at: data.created_at,
  };
}
