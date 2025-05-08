"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { ArrowLeft } from "lucide-react";

import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Switch } from "@/components/ui/Switch";
import { Heading2 } from "@/components/ui/typography";
import { ApiKeyForm } from "@/components/modules/ec/settings/ApiKeyForm";
import { SyncSettingsForm } from "@/components/modules/ec/settings/SyncSettingsForm";
import { TestConnectionButton } from "@/components/modules/ec/settings/TestConnectionButton";

// 楽天市場連携設定の型定義
interface RakutenSettings {
  isConnected: boolean;
  applicationId: string;
  applicationSecret: string;
  serviceSecret: string;
  licenseKey: string;
  shopId: string;
  lastSynced: string | null;
  itemCount: number;
  syncSettings: {
    autoSync: boolean;
    syncInterval: string;
    syncItems: boolean;
    syncPrices: boolean;
    syncInventory: boolean;
    syncDescription: boolean;
    syncImages: boolean;
    selectedCategories: string[];
  };
}

export default function RakutenSettingsPage() {
  const router = useRouter();
  const [settings, setSettings] = useState<RakutenSettings | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [testValues, setTestValues] = useState<Record<string, string>>({});

  useEffect(() => {
    // ローカルストレージから設定を取得
    const loadSettings = () => {
      try {
        // 外部ECサイト一覧を取得
        const sitesData = localStorage.getItem("ec-external-sites");
        if (sitesData) {
          const sites = JSON.parse(sitesData);
          const rakutenSite = sites.find((site: any) => site.id === "rakuten");

          // 楽天市場固有の設定を取得
          const rakutenSettings = localStorage.getItem("ec-rakuten-settings");

          if (rakutenSite) {
            const newSettings: RakutenSettings = {
              isConnected: rakutenSite.isConnected,
              applicationId: "",
              applicationSecret: "",
              serviceSecret: "",
              licenseKey: "",
              shopId: "",
              lastSynced: rakutenSite.lastSynced,
              itemCount: rakutenSite.itemCount,
              syncSettings: {
                autoSync: false,
                syncInterval: "daily",
                syncItems: true,
                syncPrices: true,
                syncInventory: true,
                syncDescription: true,
                syncImages: true,
                selectedCategories: [],
              },
            };

            // 保存されている設定があれば上書き
            if (rakutenSettings) {
              const parsedSettings = JSON.parse(rakutenSettings);
              Object.assign(newSettings, parsedSettings);
            }

            setSettings(newSettings);
            setTestValues({
              applicationId: newSettings.applicationId,
              applicationSecret: newSettings.applicationSecret,
              serviceSecret: newSettings.serviceSecret,
              licenseKey: newSettings.licenseKey,
              shopId: newSettings.shopId,
            });
          }
        }
      } catch (error) {
        console.error("Error loading Rakuten settings:", error);
      } finally {
        setLoading(false);
      }
    };

    loadSettings();
  }, []);

  const handleConnectionToggle = (isConnected: boolean) => {
    if (!settings) return;

    setSettings({
      ...settings,
      isConnected,
    });
  };

  const handleApiSave = (values: Record<string, string>) => {
    if (!settings) return;

    setSaving(true);

    // 擬似的な保存処理
    setTimeout(() => {
      setSettings({
        ...settings,
        ...values,
      });

      setTestValues(values);

      // 外部ECサイト一覧も更新
      try {
        const sitesData = localStorage.getItem("ec-external-sites");
        if (sitesData) {
          const sites = JSON.parse(sitesData);
          const updatedSites = sites.map((site: any) => {
            if (site.id === "rakuten") {
              return {
                ...site,
                isConnected: settings.isConnected,
              };
            }
            return site;
          });

          localStorage.setItem(
            "ec-external-sites",
            JSON.stringify(updatedSites)
          );
        }

        // 楽天市場固有の設定を保存
        localStorage.setItem(
          "ec-rakuten-settings",
          JSON.stringify({
            ...settings,
            ...values,
          })
        );
      } catch (error) {
        console.error("Error saving Rakuten settings:", error);
      }

      setSaving(false);
    }, 1000);
  };

  const handleSyncSettingsSave = (syncSettings: any) => {
    if (!settings) return;

    setSaving(true);

    // 擬似的な保存処理
    setTimeout(() => {
      const updatedSettings = {
        ...settings,
        syncSettings,
      };

      setSettings(updatedSettings);

      // 楽天市場固有の設定を保存
      try {
        localStorage.setItem(
          "ec-rakuten-settings",
          JSON.stringify(updatedSettings)
        );
      } catch (error) {
        console.error("Error saving Rakuten sync settings:", error);
      }

      setSaving(false);
    }, 1000);
  };

  const handleConnectionSuccess = () => {
    if (!settings) return;

    // 接続成功時の処理
    const now = new Date().toISOString();

    const updatedSettings = {
      ...settings,
      isConnected: true,
      lastSynced: now,
    };

    setSettings(updatedSettings);

    // 外部ECサイト一覧も更新
    try {
      const sitesData = localStorage.getItem("ec-external-sites");
      if (sitesData) {
        const sites = JSON.parse(sitesData);
        const updatedSites = sites.map((site: any) => {
          if (site.id === "rakuten") {
            return {
              ...site,
              isConnected: true,
              lastSynced: now,
            };
          }
          return site;
        });

        localStorage.setItem("ec-external-sites", JSON.stringify(updatedSites));
      }

      // 楽天市場固有の設定を保存
      localStorage.setItem(
        "ec-rakuten-settings",
        JSON.stringify(updatedSettings)
      );
    } catch (error) {
      console.error("Error updating Rakuten connection status:", error);
    }
  };

  if (loading) {
    return (
      <div className="container mx-auto py-8">
        <div className="animate-pulse">
          <div className="h-8 w-48 bg-gray-200 rounded mb-6"></div>
          <div className="h-64 bg-gray-200 rounded mb-6"></div>
          <div className="h-64 bg-gray-200 rounded"></div>
        </div>
      </div>
    );
  }

  if (!settings) {
    return (
      <div className="container mx-auto py-8">
        <Link href="/ec/settings/external">
          <Button variant="ghost" size="sm" className="mb-6">
            <ArrowLeft className="h-4 w-4 mr-1" />
            戻る
          </Button>
        </Link>
        <Card className="p-6 text-center">
          <p className="text-muted-foreground">
            設定の読み込みに失敗しました。
          </p>
          <Button
            variant="outline"
            className="mt-4"
            onClick={() => router.refresh()}
          >
            再読み込み
          </Button>
        </Card>
      </div>
    );
  }

  return (
    <div className="container mx-auto py-8">
      <Link href="/ec/settings/external">
        <Button variant="ghost" size="sm" className="mb-6">
          <ArrowLeft className="h-4 w-4 mr-1" />
          戻る
        </Button>
      </Link>

      <div className="mb-8">
        <Heading2>楽天市場連携設定</Heading2>
        <p className="mt-2 text-muted-foreground">
          楽天市場との連携設定を行います。
        </p>
      </div>

      <div className="grid grid-cols-1 gap-8">
        {/* 連携状態 */}
        <Card className="p-6">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-medium">連携状態</h3>
            <div className="flex items-center gap-2">
              <span className="text-sm text-muted-foreground">
                {settings.isConnected ? "連携中" : "未連携"}
              </span>
              <Switch
                checked={settings.isConnected}
                onCheckedChange={handleConnectionToggle}
              />
            </div>
          </div>

          {settings.isConnected && settings.lastSynced && (
            <p className="text-sm text-muted-foreground">
              最終同期: {new Date(settings.lastSynced).toLocaleString("ja-JP")}
            </p>
          )}

          <div className="mt-4">
            <TestConnectionButton
              siteId="rakuten"
              apiValues={testValues}
              onSuccess={handleConnectionSuccess}
            />
          </div>
        </Card>

        {/* API設定 */}
        <ApiKeyForm
          siteId="rakuten"
          initialValues={{
            applicationId: settings.applicationId,
            applicationSecret: settings.applicationSecret,
            serviceSecret: settings.serviceSecret,
            licenseKey: settings.licenseKey,
            shopId: settings.shopId,
          }}
          fields={[
            {
              id: "applicationId",
              label: "アプリケーションID",
              placeholder: "楽天アプリケーションIDを入力",
              required: true,
            },
            {
              id: "applicationSecret",
              label: "アプリケーションシークレット",
              placeholder: "楽天アプリケーションシークレットを入力",
              required: true,
              isSecret: true,
            },
            {
              id: "serviceSecret",
              label: "サービスシークレット",
              placeholder: "楽天サービスシークレットを入力",
              required: true,
              isSecret: true,
            },
            {
              id: "licenseKey",
              label: "ライセンスキー",
              placeholder: "楽天ライセンスキーを入力",
              required: false,
              isSecret: true,
            },
            {
              id: "shopId",
              label: "ショップID",
              placeholder: "楽天ショップIDを入力",
              required: true,
            },
          ]}
          onSave={handleApiSave}
          isSaving={saving}
        />

        {/* 同期設定 */}
        <SyncSettingsForm
          siteId="rakuten"
          initialSettings={settings.syncSettings}
          onSave={handleSyncSettingsSave}
          isSaving={saving}
        />
      </div>
    </div>
  );
}
