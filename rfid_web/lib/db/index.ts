import { Tables } from "./database.types";

export * from "./database.types";
export type Profile = Tables<"profiles">;
export type InventoryMaster = Tables<"inventory_masters">;
export type TokenUsage = Tables<"token_usage">;
