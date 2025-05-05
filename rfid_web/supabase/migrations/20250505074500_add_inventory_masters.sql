-- Create target_type enum
CREATE TYPE "public"."target_type" AS ENUM ('clinic', 'card_shop');

-- Create inventory_masters table
CREATE TABLE "public"."inventory_masters" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    "col_1" TEXT NOT NULL,
    "col_2" TEXT,
    "col_3" TEXT,
    "product_code" TEXT,
    "target" target_type NOT NULL,
    "user_id" UUID DEFAULT auth.uid(),
    CONSTRAINT "inventory_masters_pkey" PRIMARY KEY ("id")
);

-- Add foreign key constraint
ALTER TABLE "public"."inventory_masters" ADD CONSTRAINT "inventory_masters_user_id_fkey"
    FOREIGN KEY ("user_id") REFERENCES auth.users(id) ON DELETE CASCADE;

-- Enable Row Level Security
ALTER TABLE "public"."inventory_masters" ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own inventory masters"
    ON "public"."inventory_masters"
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own inventory masters"
    ON "public"."inventory_masters"
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own inventory masters"
    ON "public"."inventory_masters"
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own inventory masters"
    ON "public"."inventory_masters"
    FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);

-- Grant permissions
GRANT ALL ON TABLE "public"."inventory_masters" TO authenticated;
GRANT ALL ON TABLE "public"."inventory_masters" TO service_role;
