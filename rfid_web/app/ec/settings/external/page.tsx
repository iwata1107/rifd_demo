"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { ArrowLeft, ExternalLink } from "lucide-react";

import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Heading2 } from "@/components/ui/typography";

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

export default function ExternalECSettingsPage() {
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

  return (
    <div className="container mx-auto py-8">
      <Link href="/ec/settings">
        <Button variant="ghost" size="sm" className="mb-6">
          <ArrowLeft className="h-4 w-4 mr-1" />
          設定に戻る
        </Button>
      </Link>

      <div className="mb-8">
        <Heading2>外部ECサイト連携</Heading2>
        <p className="mt-2 text-muted-foreground">
          各ECサイトとの連携設定を行います。APIキーの設定や商品同期の設定が可能です。
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
        {loading
          ? // ローディング表示
            Array(4)
              .fill(0)
              .map((_, i) => (
                <Card key={i} className="p-6">
                  <div className="animate-pulse flex space-x-4">
                    <div className="rounded-full bg-gray-200 h-16 w-16"></div>
                    <div className="flex-1 space-y-4 py-1">
                      <div className="h-4 bg-gray-200 rounded w-3/4"></div>
                      <div className="space-y-2">
                        <div className="h-4 bg-gray-200 rounded"></div>
                        <div className="h-4 bg-gray-200 rounded w-5/6"></div>
                      </div>
                    </div>
                  </div>
                </Card>
              ))
          : // 連携先ECサイト一覧
            externalSites.map((site) => (
              <Link key={site.id} href={`/ec/settings/external/${site.id}`}>
                <Card className="overflow-hidden hover:shadow-md transition-shadow duration-300">
                  <div className="p-6">
                    <div className="flex items-start">
                      <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mr-4">
                        {/* ロゴの代わりに頭文字を表示 */}
                        <span className="text-2xl font-bold">
                          {site.name.charAt(0)}
                        </span>
                      </div>
                      <div>
                        <div className="flex items-center">
                          <h3 className="text-xl font-medium">{site.name}</h3>
                          <div
                            className={`ml-3 px-2 py-1 rounded text-xs ${
                              site.isConnected
                                ? "bg-green-100 text-green-800"
                                : "bg-gray-100 text-gray-800"
                            }`}
                          >
                            {site.isConnected ? "連携済み" : "未連携"}
                          </div>
                        </div>
                        <p className="text-sm text-muted-foreground mt-2">
                          {site.description}
                        </p>

                        {site.isConnected && (
                          <div className="mt-4 text-sm">
                            <p className="text-muted-foreground">
                              最終同期:{" "}
                              {site.lastSynced
                                ? new Date(site.lastSynced).toLocaleString(
                                    "ja-JP"
                                  )
                                : "未同期"}
                            </p>
                            <p className="text-muted-foreground">
                              同期商品数: {site.itemCount}点
                            </p>
                          </div>
                        )}
                      </div>
                    </div>

                    <div className="mt-4 pt-4 border-t">
                      <div className="flex justify-between items-center">
                        <div className="text-sm text-muted-foreground">
                          {site.isConnected
                            ? "設定を変更するにはクリックしてください"
                            : "連携を設定するにはクリックしてください"}
                        </div>
                        <ExternalLink className="h-4 w-4 text-muted-foreground" />
                      </div>
                    </div>
                  </div>
                </Card>
              </Link>
            ))}
      </div>

      <div className="mt-12 border-t pt-8">
        <h3 className="text-lg font-medium mb-4">連携に関する注意事項</h3>
        <div className="bg-blue-50 p-4 rounded-md">
          <p className="text-sm text-blue-800">
            ※
            このデモ環境では実際の外部ECサイトとの連携は行われません。設定内容はローカルストレージに保存され、ブラウザを閉じると消去されます。
          </p>
          <p className="text-sm text-blue-800 mt-2">
            ※
            実際の連携には、各ECサイトが提供するAPIキーやアプリケーションIDなどが必要です。詳細は各ECサイトのデベロッパーサイトをご確認ください。
          </p>
        </div>
      </div>
    </div>
  );
}
