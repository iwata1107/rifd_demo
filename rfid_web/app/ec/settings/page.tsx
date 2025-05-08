"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { ArrowLeft, ExternalLink, Settings } from "lucide-react";

import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Heading2, Heading3 } from "@/components/ui/typography";

// 連携先ECサイトの型定義
type ExternalECSite = {
  id: string;
  name: string;
  logo: string;
  description: string;
  isConnected: boolean;
  lastSynced: string | null;
  itemCount: number;
};

export default function ECSettingsPage() {
  const [externalSites, setExternalSites] = useState<ExternalECSite[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // ローカルストレージから連携設定を取得
    const loadSettings = () => {
      try {
        const savedSettings = localStorage.getItem("ec-external-sites");
        if (savedSettings) {
          setExternalSites(JSON.parse(savedSettings));
        } else {
          // 初期データがない場合はデフォルト値を設定
          const defaultSites: ExternalECSite[] = [
            {
              id: "amazon",
              name: "Amazon",
              logo: "/amazon-logo.png",
              description: "Amazonマーケットプレイスへの出品と在庫同期",
              isConnected: false,
              lastSynced: null,
              itemCount: 0,
            },
            {
              id: "rakuten",
              name: "楽天市場",
              logo: "/rakuten-logo.png",
              description: "楽天市場への出品と在庫同期",
              isConnected: false,
              lastSynced: null,
              itemCount: 0,
            },
            {
              id: "yahoo",
              name: "Yahoo!ショッピング",
              logo: "/yahoo-logo.png",
              description: "Yahoo!ショッピングへの出品と在庫同期",
              isConnected: false,
              lastSynced: null,
              itemCount: 0,
            },
            {
              id: "base",
              name: "BASE",
              logo: "/base-logo.png",
              description: "BASEへの出品と在庫同期",
              isConnected: false,
              lastSynced: null,
              itemCount: 0,
            },
          ];
          setExternalSites(defaultSites);
          localStorage.setItem(
            "ec-external-sites",
            JSON.stringify(defaultSites)
          );
        }
      } catch (error) {
        console.error("Error loading external EC site settings:", error);
      } finally {
        setLoading(false);
      }
    };

    loadSettings();
  }, []);

  // 連携済みサイト数
  const connectedSitesCount = externalSites.filter(
    (site) => site.isConnected
  ).length;

  // 同期対象商品数（すべての連携サイトの合計）
  const totalSyncedItems = externalSites.reduce(
    (total, site) => total + site.itemCount,
    0
  );

  return (
    <div className="container mx-auto py-8">
      <Link href="/ec">
        <Button variant="ghost" size="sm" className="mb-6">
          <ArrowLeft className="h-4 w-4 mr-1" />
          ECサイトに戻る
        </Button>
      </Link>

      <div className="mb-8">
        <Heading2>EC連携設定</Heading2>
        <p className="mt-2 text-muted-foreground">
          外部ECサイトとの連携設定を管理します。
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <Card className="p-6">
          <div className="flex flex-col items-center">
            <div className="text-4xl font-bold text-primary mb-2">
              {connectedSitesCount}
            </div>
            <div className="text-sm text-muted-foreground">連携済みサイト</div>
          </div>
        </Card>
        <Card className="p-6">
          <div className="flex flex-col items-center">
            <div className="text-4xl font-bold text-primary mb-2">
              {externalSites.length}
            </div>
            <div className="text-sm text-muted-foreground">
              利用可能なサイト
            </div>
          </div>
        </Card>
        <Card className="p-6">
          <div className="flex flex-col items-center">
            <div className="text-4xl font-bold text-primary mb-2">
              {totalSyncedItems}
            </div>
            <div className="text-sm text-muted-foreground">同期対象商品</div>
          </div>
        </Card>
      </div>

      <div className="mb-6">
        <Heading3>外部ECサイト連携</Heading3>
        <p className="mt-2 text-sm text-muted-foreground">
          各ECサイトの連携設定を行います。APIキーの設定や商品同期の設定が可能です。
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {loading
          ? // ローディング表示
            Array(4)
              .fill(0)
              .map((_, i) => (
                <Card key={i} className="p-6">
                  <div className="animate-pulse flex space-x-4">
                    <div className="rounded-full bg-gray-200 h-12 w-12"></div>
                    <div className="flex-1 space-y-4 py-1">
                      <div className="h-4 bg-gray-200 rounded w-3/4"></div>
                      <div className="space-y-2">
                        <div className="h-4 bg-gray-200 rounded"></div>
                      </div>
                    </div>
                  </div>
                </Card>
              ))
          : // 連携先ECサイト一覧
            externalSites.map((site) => (
              <Card key={site.id} className="overflow-hidden">
                <div className="p-6">
                  <div className="flex items-start justify-between">
                    <div className="flex items-center">
                      <div className="w-12 h-12 bg-gray-100 rounded-full flex items-center justify-center mr-4">
                        {/* ロゴの代わりに頭文字を表示 */}
                        <span className="text-xl font-bold">
                          {site.name.charAt(0)}
                        </span>
                      </div>
                      <div>
                        <h3 className="text-lg font-medium">{site.name}</h3>
                        <p className="text-sm text-muted-foreground mt-1">
                          {site.description}
                        </p>
                      </div>
                    </div>
                    <div
                      className={`px-2 py-1 rounded text-xs ${
                        site.isConnected
                          ? "bg-green-100 text-green-800"
                          : "bg-gray-100 text-gray-800"
                      }`}
                    >
                      {site.isConnected ? "連携済み" : "未連携"}
                    </div>
                  </div>

                  {site.isConnected && (
                    <div className="mt-4 text-sm text-muted-foreground">
                      <p>
                        最終同期:{" "}
                        {site.lastSynced
                          ? new Date(site.lastSynced).toLocaleString("ja-JP")
                          : "未同期"}
                      </p>
                      <p>同期商品数: {site.itemCount}点</p>
                    </div>
                  )}

                  <div className="mt-6 flex justify-end">
                    <Link href={`/ec/settings/external/${site.id}`}>
                      <Button variant="outline" size="sm" className="gap-1">
                        <Settings className="h-4 w-4" />
                        設定
                      </Button>
                    </Link>
                  </div>
                </div>
              </Card>
            ))}
      </div>

      <div className="mt-12 border-t pt-8">
        <Heading3>その他の設定</Heading3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-6">
          <Card className="p-6">
            <h3 className="text-lg font-medium">一般設定</h3>
            <p className="text-sm text-muted-foreground mt-1">
              ECサイトの一般設定を行います。
            </p>
            <div className="mt-6 flex justify-end">
              <Button variant="outline" size="sm" disabled>
                準備中
              </Button>
            </div>
          </Card>
          <Card className="p-6">
            <h3 className="text-lg font-medium">同期スケジュール</h3>
            <p className="text-sm text-muted-foreground mt-1">
              外部ECサイトとの同期スケジュールを設定します。
            </p>
            <div className="mt-6 flex justify-end">
              <Button variant="outline" size="sm" disabled>
                準備中
              </Button>
            </div>
          </Card>
        </div>
      </div>
    </div>
  );
}
