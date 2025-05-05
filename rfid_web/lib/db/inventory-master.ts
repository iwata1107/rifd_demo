import { cookies } from "next/headers";

import { createClient } from "@/lib/supabase/server";

import { Database } from "./database.types";
import { InventoryMaster } from "./index";

/**
 * 在庫管理マスターを取得する
 */
export async function getInventoryMasters() {
  const cookieStore = cookies();
  const supabase = createClient(cookieStore);
  const { data, error } = await supabase
    .from("inventory_masters")
    .select("*")
    .order("created_at", { ascending: false });

  if (error) {
    console.error("Error fetching inventory masters:", error);
    throw error;
  }

  return data as InventoryMaster[];
}

/**
 * 特定のターゲット（業種）の在庫管理マスターを取得する
 */
export async function getInventoryMastersByTarget(
  target: Database["public"]["Enums"]["target_type"]
) {
  const cookieStore = cookies();
  const supabase = createClient(cookieStore);
  const { data, error } = await supabase
    .from("inventory_masters")
    .select("*")
    .eq("target", target)
    .order("created_at", { ascending: false });

  if (error) {
    console.error(
      `Error fetching inventory masters for target ${target}:`,
      error
    );
    throw error;
  }

  return data as InventoryMaster[];
}

/**
 * IDで在庫管理マスターを取得する
 */
export async function getInventoryMasterById(id: string) {
  const cookieStore = cookies();
  const supabase = createClient(cookieStore);
  const { data, error } = await supabase
    .from("inventory_masters")
    .select("*")
    .eq("id", id)
    .single();

  if (error) {
    console.error(`Error fetching inventory master with id ${id}:`, error);
    throw error;
  }

  return data as InventoryMaster;
}

/**
 * 在庫管理マスターを作成する
 */
export async function createInventoryMaster(
  inventoryMaster: Omit<
    Database["public"]["Tables"]["inventory_masters"]["Insert"],
    "id" | "created_at" | "updated_at" | "user_id"
  >
) {
  const cookieStore = cookies();
  const supabase = createClient(cookieStore);
  const { data, error } = await supabase
    .from("inventory_masters")
    .insert(inventoryMaster)
    .select()
    .single();

  if (error) {
    console.error("Error creating inventory master:", error);
    throw error;
  }

  return data as InventoryMaster;
}

/**
 * 在庫管理マスターを更新する
 */
export async function updateInventoryMaster(
  id: string,
  updates: Partial<
    Omit<
      Database["public"]["Tables"]["inventory_masters"]["Update"],
      "id" | "created_at" | "user_id"
    >
  >
) {
  const cookieStore = cookies();
  const supabase = createClient(cookieStore);

  // 更新時間を現在時刻に設定
  const updatedData = {
    ...updates,
    updated_at: new Date().toISOString(),
  };

  const { data, error } = await supabase
    .from("inventory_masters")
    .update(updatedData)
    .eq("id", id)
    .select()
    .single();

  if (error) {
    console.error(`Error updating inventory master with id ${id}:`, error);
    throw error;
  }

  return data as InventoryMaster;
}

/**
 * 在庫管理マスターを削除する
 */
export async function deleteInventoryMaster(id: string) {
  const cookieStore = cookies();
  const supabase = createClient(cookieStore);
  const { error } = await supabase
    .from("inventory_masters")
    .delete()
    .eq("id", id);

  if (error) {
    console.error(`Error deleting inventory master with id ${id}:`, error);
    throw error;
  }

  return true;
}
