-- Add product_image column to inventory_masters table
ALTER TABLE "public"."inventory_masters"
ADD COLUMN "product_image" TEXT;

-- Add is_inventoried column to items table
ALTER TABLE "public"."items"
ADD COLUMN "is_inventoried" BOOLEAN DEFAULT FALSE;

-- Create index for faster queries
CREATE INDEX items_is_inventoried_idx ON "public"."items" ("is_inventoried");
CREATE INDEX items_inventory_master_id_idx ON "public"."items" ("inventory_master_id");
