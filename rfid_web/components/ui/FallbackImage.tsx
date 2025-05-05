"use client";

import { useState } from "react";
import Image, { ImageProps } from "next/image";
import clsx from "clsx";

interface FallbackImageProps extends Omit<ImageProps, "src" | "alt"> {
  src: string;
  alt: string;
  /** 表示するラッパー div の追加クラス */
  wrapperClassName?: string;
  /** フォールバック時に表示する文言 */
  fallbackText?: string;
}

// エラー時にフォールバック UI を表示するクライアントコンポーネント
export default function FallbackImage({
  src,
  alt,
  wrapperClassName,
  fallbackText = "画像を読み込めませんでした",
  ...imageProps
}: FallbackImageProps) {
  const [hasError, setHasError] = useState(false);

  return (
    <div className={clsx("relative w-full h-full", wrapperClassName)}>
      {hasError ? (
        <div className="flex h-full w-full items-center justify-center bg-gray-100 text-sm text-gray-500">
          {fallbackText}
        </div>
      ) : (
        <Image
          src={src}
          alt={alt}
          fill
          style={{ objectFit: "contain" }}
          onError={() => setHasError(true)}
          {...imageProps}
        />
      )}
    </div>
  );
}
