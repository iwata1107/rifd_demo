"use client";

import { useState } from "react";
import { Eye, EyeOff } from "lucide-react";

import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Input } from "@/components/ui/Input";
import { Label } from "@/components/ui/Label";

interface ApiKeyFormProps {
  siteId: string;
  initialValues?: {
    apiKey?: string;
    secretKey?: string;
    applicationId?: string;
    sellerId?: string;
    [key: string]: string | undefined;
  };
  fields: {
    id: string;
    label: string;
    placeholder: string;
    required?: boolean;
    isSecret?: boolean;
  }[];
  onSave: (values: Record<string, string>) => void;
  isSaving?: boolean;
}

export function ApiKeyForm({
  siteId,
  initialValues = {},
  fields,
  onSave,
  isSaving = false,
}: ApiKeyFormProps) {
  const [values, setValues] = useState<Record<string, string>>(() => {
    // 初期値を設定
    const initialState: Record<string, string> = {};
    fields.forEach((field) => {
      initialState[field.id] = initialValues[field.id] || "";
    });
    return initialState;
  });

  const [showSecrets, setShowSecrets] = useState<Record<string, boolean>>({});

  const handleChange = (id: string, value: string) => {
    setValues((prev) => ({
      ...prev,
      [id]: value,
    }));
  };

  const toggleShowSecret = (id: string) => {
    setShowSecrets((prev) => ({
      ...prev,
      [id]: !prev[id],
    }));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSave(values);
  };

  return (
    <Card className="p-6">
      <h3 className="text-lg font-medium mb-4">API設定</h3>
      <form onSubmit={handleSubmit}>
        <div className="space-y-4">
          {fields.map((field) => (
            <div key={field.id}>
              <Label htmlFor={field.id} className="mb-2 block">
                {field.label}
                {field.required && <span className="text-red-500 ml-1">*</span>}
              </Label>
              <div className="relative">
                <Input
                  id={field.id}
                  type={
                    field.isSecret && !showSecrets[field.id]
                      ? "password"
                      : "text"
                  }
                  placeholder={field.placeholder}
                  value={values[field.id] || ""}
                  onChange={(e) => handleChange(field.id, e.target.value)}
                  required={field.required}
                  className={field.isSecret ? "pr-10" : ""}
                />
                {field.isSecret && (
                  <button
                    type="button"
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-700"
                    onClick={() => toggleShowSecret(field.id)}
                  >
                    {showSecrets[field.id] ? (
                      <EyeOff className="h-4 w-4" />
                    ) : (
                      <Eye className="h-4 w-4" />
                    )}
                  </button>
                )}
              </div>
            </div>
          ))}
        </div>

        <div className="mt-6 flex justify-end">
          <Button type="submit" disabled={isSaving}>
            {isSaving ? "保存中..." : "保存"}
          </Button>
        </div>
      </form>
    </Card>
  );
}
