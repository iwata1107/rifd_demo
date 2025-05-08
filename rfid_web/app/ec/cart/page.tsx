"use client";

import { useEffect, useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { ArrowLeft, Minus, Plus, ShoppingBag, Trash2 } from "lucide-react";

import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Heading1 } from "@/components/ui/typography";

// カート内の商品の型定義
interface CartItem {
  id: string;
  name: string;
  price: number;
  imageUrl: string | null;
  quantity: number;
  addedAt: string;
}

export default function CartPage() {
  const [cartItems, setCartItems] = useState<CartItem[]>([]);
  const [loading, setLoading] = useState(true);

  // カートデータを取得
  useEffect(() => {
    try {
      const savedCart = localStorage.getItem("ec-cart");
      if (savedCart) {
        setCartItems(JSON.parse(savedCart));
      }
    } catch (error) {
      console.error("Error loading cart:", error);
    } finally {
      setLoading(false);
    }
  }, []);

  // カートの合計金額を計算
  const totalPrice = cartItems.reduce(
    (total, item) => total + item.price * item.quantity,
    0
  );

  // 数量を変更
  const updateQuantity = (id: string, newQuantity: number) => {
    if (newQuantity < 1) return;

    const updatedItems = cartItems.map((item) =>
      item.id === id ? { ...item, quantity: newQuantity } : item
    );
    setCartItems(updatedItems);
    localStorage.setItem("ec-cart", JSON.stringify(updatedItems));
  };

  // 商品を削除
  const removeItem = (id: string) => {
    const updatedItems = cartItems.filter((item) => item.id !== id);
    setCartItems(updatedItems);
    localStorage.setItem("ec-cart", JSON.stringify(updatedItems));
  };

  // 注文確定（デモ用）
  const handleCheckout = () => {
    alert("この機能はデモ用です。実際の決済処理は行われません。");
    // カートを空にする
    setCartItems([]);
    localStorage.setItem("ec-cart", JSON.stringify([]));
  };

  return (
    <div className="container mx-auto py-8">
      <Link href="/ec">
        <Button variant="ghost" size="sm" className="mb-6">
          <ArrowLeft className="h-4 w-4 mr-1" />
          商品一覧に戻る
        </Button>
      </Link>

      <div className="mb-8">
        <Heading1>ショッピングカート</Heading1>
        <p className="mt-2 text-muted-foreground">
          カートに追加した商品を確認できます。
        </p>
      </div>

      {loading ? (
        <div className="animate-pulse space-y-4">
          {Array(3)
            .fill(0)
            .map((_, i) => (
              <Card key={i} className="p-4">
                <div className="flex space-x-4">
                  <div className="h-24 w-24 bg-gray-200 rounded"></div>
                  <div className="flex-1 space-y-2">
                    <div className="h-4 bg-gray-200 rounded w-3/4"></div>
                    <div className="h-4 bg-gray-200 rounded w-1/2"></div>
                    <div className="h-4 bg-gray-200 rounded w-1/4"></div>
                  </div>
                </div>
              </Card>
            ))}
        </div>
      ) : cartItems.length === 0 ? (
        <Card className="p-8 text-center">
          <div className="flex flex-col items-center justify-center space-y-4">
            <ShoppingBag className="h-16 w-16 text-muted-foreground" />
            <h2 className="text-xl font-medium">カートは空です</h2>
            <p className="text-muted-foreground">
              商品をカートに追加すると、ここに表示されます。
            </p>
            <Link href="/ec">
              <Button className="mt-4">商品一覧に戻る</Button>
            </Link>
          </div>
        </Card>
      ) : (
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <div className="lg:col-span-2 space-y-4">
            {cartItems.map((item) => (
              <Card key={item.id} className="p-4">
                <div className="flex flex-col sm:flex-row">
                  <div className="relative h-32 w-32 bg-gray-100 rounded-md overflow-hidden mb-4 sm:mb-0 sm:mr-4">
                    {item.imageUrl ? (
                      <Image
                        src={item.imageUrl}
                        alt={item.name}
                        fill
                        sizes="128px"
                        className="object-cover"
                      />
                    ) : (
                      <div className="flex items-center justify-center h-full">
                        <span className="text-gray-400 text-sm">No Image</span>
                      </div>
                    )}
                  </div>
                  <div className="flex-1">
                    <div className="flex flex-col sm:flex-row sm:justify-between">
                      <div>
                        <Link href={`/ec/${item.id}`}>
                          <h3 className="font-medium text-lg hover:text-primary transition-colors">
                            {item.name}
                          </h3>
                        </Link>
                        <p className="text-muted-foreground text-sm">
                          単価: ¥{item.price.toLocaleString()}
                        </p>
                      </div>
                      <div className="mt-2 sm:mt-0 text-right">
                        <p className="font-bold">
                          ¥{(item.price * item.quantity).toLocaleString()}
                        </p>
                      </div>
                    </div>
                    <div className="flex justify-between items-center mt-4">
                      <div className="flex items-center space-x-2">
                        <Button
                          variant="outline"
                          size="icon"
                          className="h-8 w-8"
                          onClick={() =>
                            updateQuantity(item.id, item.quantity - 1)
                          }
                          disabled={item.quantity <= 1}
                        >
                          <Minus className="h-4 w-4" />
                        </Button>
                        <span className="w-8 text-center">{item.quantity}</span>
                        <Button
                          variant="outline"
                          size="icon"
                          className="h-8 w-8"
                          onClick={() =>
                            updateQuantity(item.id, item.quantity + 1)
                          }
                        >
                          <Plus className="h-4 w-4" />
                        </Button>
                      </div>
                      <Button
                        variant="ghost"
                        size="sm"
                        className="text-red-500 hover:text-red-700 hover:bg-red-50"
                        onClick={() => removeItem(item.id)}
                      >
                        <Trash2 className="h-4 w-4 mr-1" />
                        削除
                      </Button>
                    </div>
                  </div>
                </div>
              </Card>
            ))}
          </div>

          <div>
            <Card className="p-6 sticky top-4">
              <h2 className="text-lg font-medium mb-4">注文内容</h2>
              <div className="space-y-2 mb-4">
                <div className="flex justify-between">
                  <span className="text-muted-foreground">小計</span>
                  <span>¥{totalPrice.toLocaleString()}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">送料</span>
                  <span>¥0</span>
                </div>
                <div className="border-t pt-2 mt-2">
                  <div className="flex justify-between font-bold">
                    <span>合計</span>
                    <span>¥{totalPrice.toLocaleString()}</span>
                  </div>
                  <p className="text-xs text-muted-foreground mt-1">(税込)</p>
                </div>
              </div>
              <Button className="w-full" size="lg" onClick={handleCheckout}>
                注文を確定する
              </Button>
              <p className="text-xs text-center text-muted-foreground mt-4">
                ※このボタンをクリックしても実際の決済は行われません
              </p>
            </Card>
          </div>
        </div>
      )}
    </div>
  );
}
