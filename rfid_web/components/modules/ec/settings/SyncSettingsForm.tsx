"use client";

import { useState } from "react";
import { Check, ChevronsUpDown } from "lucide-react";

import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
// import { Checkbox } from "@/components/ui/Checkbox";
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
} from "@/components/ui/Command";
import { Label } from "@/components/ui/Label";
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/Popover";
import { Switch } from "@/components/ui/Switch";

// 同期設定の型定義
interface SyncSettings {
  autoSync: boolean;
  syncInterval: string;
  syncItems: boolean;
  syncPrices: boolean;
  syncInventory: boolean;
  syncDescription: boolean;
  syncImages: boolean;
  selectedCategories: string[];
}

interface SyncSettingsFormProps {
  siteId: string;
  initialSettings?: Partial<SyncSettings>;
  onSave: (settings: SyncSettings) => void;
  isSaving?: boolean;
}

// 同期間隔のオプション
const syncIntervalOptions = [
  { value: "15min", label: "15分ごと" },
  { value: "30min", label: "30分ごと" },
  { value: "1hour", label: "1時間ごと" },
  { value: "3hours", label: "3時間ごと" },
  { value: "6hours", label: "6時間ごと" },
  { value: "12hours", label: "12時間ごと" },
  { value: "daily", label: "1日1回" },
];

// カテゴリーのオプション（デモ用）
const categoryOptions = [
  { value: "apparel", label: "アパレル" },
  { value: "electronics", label: "家電" },
  { value: "books", label: "書籍" },
  { value: "toys", label: "おもちゃ" },
  { value: "sports", label: "スポーツ用品" },
  { value: "food", label: "食品" },
  { value: "beauty", label: "美容・健康" },
  { value: "home", label: "ホーム・キッチン" },
];

export function SyncSettingsForm({
  siteId,
  initialSettings = {},
  onSave,
  isSaving = false,
}: SyncSettingsFormProps) {
  // デフォルト値とマージした初期値を設定
  const defaultSettings: SyncSettings = {
    autoSync: false,
    syncInterval: "daily",
    syncItems: true,
    syncPrices: true,
    syncInventory: true,
    syncDescription: true,
    syncImages: true,
    selectedCategories: [],
  };

  const [settings, setSettings] = useState<SyncSettings>({
    ...defaultSettings,
    ...initialSettings,
  });

  const [open, setOpen] = useState(false);

  const handleChange = (
    key: keyof SyncSettings,
    value: boolean | string | string[]
  ) => {
    setSettings((prev) => ({
      ...prev,
      [key]: value,
    }));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSave(settings);
  };

  return (
    <Card className="p-6">
      <h3 className="text-lg font-medium mb-4">同期設定</h3>
      <form onSubmit={handleSubmit}>
        <div className="space-y-6">
          {/* 自動同期設定 */}
          <div className="flex items-center justify-between">
            <div>
              <Label className="text-base">自動同期</Label>
              <p className="text-sm text-muted-foreground">
                設定した間隔で自動的に商品情報を同期します
              </p>
            </div>
            <Switch
              checked={settings.autoSync}
              onCheckedChange={(checked) => handleChange("autoSync", checked)}
            />
          </div>

          {/* 同期間隔 */}
          {settings.autoSync && (
            <div>
              <Label htmlFor="syncInterval" className="mb-2 block">
                同期間隔
              </Label>
              <Popover open={open} onOpenChange={setOpen}>
                <PopoverTrigger asChild>
                  <Button
                    variant="outline"
                    role="combobox"
                    aria-expanded={open}
                    className="w-full justify-between"
                  >
                    {settings.syncInterval
                      ? syncIntervalOptions.find(
                          (option) => option.value === settings.syncInterval
                        )?.label
                      : "同期間隔を選択"}
                    <ChevronsUpDown className="ml-2 h-4 w-4 shrink-0 opacity-50" />
                  </Button>
                </PopoverTrigger>
                <PopoverContent className="w-full p-0">
                  <Command>
                    <CommandInput placeholder="同期間隔を検索..." />
                    <CommandEmpty>見つかりませんでした</CommandEmpty>
                    <CommandGroup>
                      {syncIntervalOptions.map((option) => (
                        <CommandItem
                          key={option.value}
                          value={option.value}
                          onSelect={(currentValue) => {
                            handleChange("syncInterval", currentValue);
                            setOpen(false);
                          }}
                        >
                          <Check
                            className={`mr-2 h-4 w-4 ${
                              settings.syncInterval === option.value
                                ? "opacity-100"
                                : "opacity-0"
                            }`}
                          />
                          {option.label}
                        </CommandItem>
                      ))}
                    </CommandGroup>
                  </Command>
                </PopoverContent>
              </Popover>
            </div>
          )}

          {/* 同期項目 */}
          <div>
            <Label className="mb-2 block">同期項目</Label>
            <div className="space-y-3">
              <div className="flex items-center space-x-2">
                <input
                  type="checkbox"
                  id="syncItems"
                  checked={settings.syncItems}
                  onChange={(e) => handleChange("syncItems", e.target.checked)}
                  className="h-4 w-4 rounded border-gray-300 text-primary focus:ring-primary"
                />
                <Label htmlFor="syncItems" className="font-normal">
                  商品情報
                </Label>
              </div>
              <div className="flex items-center space-x-2">
                <input
                  type="checkbox"
                  id="syncPrices"
                  checked={settings.syncPrices}
                  onChange={(e) => handleChange("syncPrices", e.target.checked)}
                  className="h-4 w-4 rounded border-gray-300 text-primary focus:ring-primary"
                />
                <Label htmlFor="syncPrices" className="font-normal">
                  価格情報
                </Label>
              </div>
              <div className="flex items-center space-x-2">
                <input
                  type="checkbox"
                  id="syncInventory"
                  checked={settings.syncInventory}
                  onChange={(e) =>
                    handleChange("syncInventory", e.target.checked)
                  }
                  className="h-4 w-4 rounded border-gray-300 text-primary focus:ring-primary"
                />
                <Label htmlFor="syncInventory" className="font-normal">
                  在庫情報
                </Label>
              </div>
              <div className="flex items-center space-x-2">
                <input
                  type="checkbox"
                  id="syncDescription"
                  checked={settings.syncDescription}
                  onChange={(e) =>
                    handleChange("syncDescription", e.target.checked)
                  }
                  className="h-4 w-4 rounded border-gray-300 text-primary focus:ring-primary"
                />
                <Label htmlFor="syncDescription" className="font-normal">
                  商品説明
                </Label>
              </div>
              <div className="flex items-center space-x-2">
                <input
                  type="checkbox"
                  id="syncImages"
                  checked={settings.syncImages}
                  onChange={(e) => handleChange("syncImages", e.target.checked)}
                  className="h-4 w-4 rounded border-gray-300 text-primary focus:ring-primary"
                />
                <Label htmlFor="syncImages" className="font-normal">
                  商品画像
                </Label>
              </div>
            </div>
          </div>

          {/* 同期対象カテゴリー */}
          <div>
            <Label className="mb-2 block">同期対象カテゴリー</Label>
            <p className="text-sm text-muted-foreground mb-2">
              同期対象とするカテゴリーを選択してください。選択しない場合はすべてのカテゴリーが対象となります。
            </p>
            <div className="space-y-3">
              {categoryOptions.map((category) => (
                <div
                  key={category.value}
                  className="flex items-center space-x-2"
                >
                  <input
                    type="checkbox"
                    id={`category-${category.value}`}
                    checked={settings.selectedCategories.includes(
                      category.value
                    )}
                    onChange={(e) => {
                      const checked = e.target.checked;
                      const newCategories = checked
                        ? [...settings.selectedCategories, category.value]
                        : settings.selectedCategories.filter(
                            (c) => c !== category.value
                          );
                      handleChange("selectedCategories", newCategories);
                    }}
                    className="h-4 w-4 rounded border-gray-300 text-primary focus:ring-primary"
                  />
                  <Label
                    htmlFor={`category-${category.value}`}
                    className="font-normal"
                  >
                    {category.label}
                  </Label>
                </div>
              ))}
            </div>
          </div>
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
