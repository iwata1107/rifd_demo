"use client";

import { useState } from "react";
import { ShoppingCart } from "lucide-react";

import { Button } from "@/components/ui/Button";

interface AddToCartButtonProps {
  productId: string;
  name: string;
  price: number;
  imageUrl: string | null;
  disabled?: boolean;
}

export function AddToCartButton({
  productId,
  name,
  price,
  imageUrl,
  disabled = false,
}: AddToCartButtonProps) {
  const [adding, setAdding] = useState(false);
  const [added, setAdded] = useState(false);

  const handleAddToCart = () => {
    if (disabled) return;

    setAdding(true);

    try {
      // カートデータを取得
      const savedCart = localStorage.getItem("ec-cart") || "[]";
      const cart = JSON.parse(savedCart);

      // 商品をカートに追加
      cart.push({
        id: productId,
        name,
        price,
        imageUrl,
        quantity: 1,
        addedAt: new Date().toISOString(),
      });

      // カートデータを保存
      localStorage.setItem("ec-cart", JSON.stringify(cart));

      // 成功表示
      setAdded(true);
      setTimeout(() => setAdded(false), 2000);
    } catch (error) {
      console.error("Error adding to cart:", error);
    } finally {
      setAdding(false);
    }
  };

  return (
    <Button
      onClick={handleAddToCart}
      disabled={disabled || adding}
      className="w-full"
      size="lg"
    >
      {adding ? (
        "カートに追加中..."
      ) : added ? (
        "カートに追加しました！"
      ) : (
        <>
          <ShoppingCart className="h-5 w-5 mr-2" />
          カートに追加
        </>
      )}
    </Button>
  );
}
