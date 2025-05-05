-- Create items table
CREATE TABLE "public"."items" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "created_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    "updated_at" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    "rfid" TEXT NOT NULL,
    "inventory_master_id" UUID NOT NULL,
    "user_id" UUID DEFAULT auth.uid(),
    CONSTRAINT "items_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "items_rfid_key" UNIQUE ("rfid"),
    CONSTRAINT "items_inventory_master_id_fkey" FOREIGN KEY ("inventory_master_id")
        REFERENCES "public"."inventory_masters"("id") ON DELETE CASCADE
);

-- Enable Row Level Security
ALTER TABLE "public"."items" ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own items"
    ON "public"."items"
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own items"
    ON "public"."items"
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own items"
    ON "public"."items"
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own items"
    ON "public"."items"
    FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);

-- Grant permissions
GRANT ALL ON TABLE "public"."items" TO authenticated;
GRANT ALL ON TABLE "public"."items" TO service_role;
