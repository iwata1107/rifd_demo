"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { Home, Settings, ShoppingCart } from "lucide-react";

import { Button } from "@/components/ui/Button";

export function ECNavigation() {
  const pathname = usePathname();
  const [cartItemCount, setCartItemCount] = useState(0);

  // カート内のアイテム数を取得
  useEffect(() => {
    const updateCartCount = () => {
      try {
        const savedCart = localStorage.getItem("ec-cart");
        if (savedCart) {
          const cartItems = JSON.parse(savedCart);
          setCartItemCount(cartItems.length);
        }
      } catch (error) {
        console.error("Error loading cart count:", error);
      }
    };

    // 初期ロード時にカウントを更新
    updateCartCount();

    // ローカルストレージの変更を監視
    const handleStorageChange = () => {
      updateCartCount();
    };

    window.addEventListener("storage", handleStorageChange);

    // カスタムイベントを作成して、同一ウィンドウ内での更新も検知
    const originalSetItem = localStorage.setItem;
    localStorage.setItem = function (key, value) {
      originalSetItem.apply(this, [key, value]);
      if (key === "ec-cart") {
        updateCartCount();
      }
    };

    return () => {
      window.removeEventListener("storage", handleStorageChange);
      localStorage.setItem = originalSetItem;
    };
  }, []);

  return (
    <div className="mb-8 border-b pb-4 pt-10 px-10">
      <div className="container mx-auto">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <Link href="/ec">
              <Button
                variant={pathname === "/ec" ? "default" : "ghost"}
                size="sm"
                className="gap-1"
              >
                <Home size={16} />
                商品一覧
              </Button>
            </Link>
          </div>
          <div className="flex items-center space-x-2">
            <Link href="/ec/settings">
              <Button
                variant={
                  pathname.startsWith("/ec/settings") ? "default" : "ghost"
                }
                size="sm"
                className="gap-1"
              >
                <Settings size={16} />
                設定
              </Button>
            </Link>
            <Link href="/ec/cart">
              <Button
                variant={pathname === "/ec/cart" ? "default" : "ghost"}
                size="sm"
                className="gap-1 relative"
              >
                <ShoppingCart size={16} />
                カート
                {cartItemCount > 0 && (
                  <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full h-5 w-5 flex items-center justify-center">
                    {cartItemCount}
                  </span>
                )}
              </Button>
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
