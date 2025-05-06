import { createClient } from "@/lib/supabase/client";

import { Database } from "./database.types";
import { InventoryMaster, Item } from "./index";

/**
 * アイテムを取得する
 */
export async function getItems() {
  const supabase = createClient();
  const { data, error } = await supabase
    .from("items")
    .select("*")
    .order("created_at", { ascending: false });

  if (error) {
    console.error("Error fetching items:", error);
    throw error;
  }

  return data as Item[];
}

/**
 * マスター情報と結合したアイテムを取得する
 */
export async function getItemsWithMasterInfo() {
  const supabase = createClient();
  const { data, error } = await supabase
    .from("items")
    .select(
      `
      *,
      inventory_masters:inventory_master_id (
        id,
        col_1,
        col_2,
        col_3,
        product_code,
        product_image,
        target
      )
    `
    )
    .order("created_at", { ascending: false });

  if (error) {
    console.error("Error fetching items with master info:", error);
    throw error;
  }

  return data as (Item & { inventory_masters: InventoryMaster })[];
}

/**
 * 特定のマスターIDに関連するアイテムを取得する
 */
export async function getItemsByMasterId(masterId: string) {
  const supabase = createClient();
  const { data, error } = await supabase
    .from("items")
    .select("*")
    .eq("inventory_master_id", masterId)
    .order("created_at", { ascending: false });

  if (error) {
    console.error(`Error fetching items for master ID ${masterId}:`, error);
    throw error;
  }

  return data as Item[];
}

/**
 * 在庫状態でアイテムをフィルタリングして取得する
 */
export async function getItemsByInventoryStatus(isInventoried: boolean) {
  const supabase = createClient();
  const { data, error } = await supabase
    .from("items")
    .select(
      `
      *,
      inventory_masters:inventory_master_id (
        id,
        col_1,
        col_2,
        col_3,
        product_code,
        product_image,
        target
      )
    `
    )
    .eq("is_inventoried", isInventoried)
    .order("created_at", { ascending: false });

  if (error) {
    console.error(
      `Error fetching items with inventory status ${isInventoried}:`,
      error
    );
    throw error;
  }

  return data as (Item & { inventory_masters: InventoryMaster })[];
}

/**
 * 特定の業種のマスターに関連するアイテムを取得する
 */
export async function getItemsByTargetType(
  target: Database["public"]["Enums"]["target_type"]
) {
  const supabase = createClient();
  const { data, error } = await supabase
    .from("items")
    .select(
      `
      *,
      inventory_masters:inventory_master_id (
        id,
        col_1,
        col_2,
        col_3,
        product_code,
        product_image,
        target
      )
    `
    )
    .eq("inventory_masters.target", target)
    .order("created_at", { ascending: false });

  if (error) {
    console.error(`Error fetching items for target type ${target}:`, error);
    throw error;
  }

  return data as (Item & { inventory_masters: InventoryMaster })[];
}

/**
 * IDでアイテムを取得する
 */
export async function getItemById(id: string) {
  const supabase = createClient();
  const { data, error } = await supabase
    .from("items")
    .select(
      `
      *,
      inventory_masters:inventory_master_id (
        id,
        col_1,
        col_2,
        col_3,
        product_code,
        product_image,
        target
      )
    `
    )
    .eq("id", id)
    .single();

  if (error) {
    console.error(`Error fetching item with id ${id}:`, error);
    throw error;
  }

  return data as Item & { inventory_masters: InventoryMaster };
}

/**
 * アイテムを作成する
 */
export async function createItem(
  item: Omit<
    Database["public"]["Tables"]["items"]["Insert"],
    "id" | "created_at" | "updated_at" | "user_id"
  >
) {
  const supabase = createClient();
  const { data, error } = await supabase
    .from("items")
    .insert(item)
    .select()
    .single();

  if (error) {
    console.error("Error creating item:", error);
    throw error;
  }

  return data as Item;
}

/**
 * アイテムを更新する
 */
export async function updateItem(
  id: string,
  updates: Partial<
    Omit<
      Database["public"]["Tables"]["items"]["Update"],
      "id" | "created_at" | "user_id"
    >
  >
) {
  const supabase = createClient();

  // 更新時間を現在時刻に設定
  const updatedData = {
    ...updates,
    updated_at: new Date().toISOString(),
  };

  const { data, error } = await supabase
    .from("items")
    .update(updatedData)
    .eq("id", id)
    .select()
    .single();

  if (error) {
    console.error(`Error updating item with id ${id}:`, error);
    throw error;
  }

  return data as Item;
}

/**
 * アイテムを削除する
 */
export async function deleteItem(id: string) {
  const supabase = createClient();
  const { error } = await supabase.from("items").delete().eq("id", id);

  if (error) {
    console.error(`Error deleting item with id ${id}:`, error);
    throw error;
  }

  return true;
}
