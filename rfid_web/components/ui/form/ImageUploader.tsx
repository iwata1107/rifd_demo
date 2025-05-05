"use client";

import { ChangeEvent, useEffect, useRef, useState } from "react";
import Image from "next/image";
import { AlertCircle, RefreshCw, Upload, X } from "lucide-react";

import { uploadProductImage } from "@/lib/supabase/storage";
import { Button } from "@/components/ui/Button";
import { toast } from "@/components/ui/use-toast";

interface ImageUploaderProps {
  initialImageUrl?: string;
  onImageUploaded: (url: string) => void;
  onError?: (error: Error) => void;
}

export function ImageUploader({
  initialImageUrl,
  onImageUploaded,
  onError,
}: ImageUploaderProps) {
  const [imageUrl, setImageUrl] = useState<string | undefined>(initialImageUrl);
  const [isUploading, setIsUploading] = useState(false);
  const [uploadProgress, setUploadProgress] = useState(0);
  const [error, setError] = useState<string | null>(null);
  const [retryCount, setRetryCount] = useState(0);
  const fileInputRef = useRef<HTMLInputElement>(null);

  // 初期画像URLが変更された場合に状態を更新
  useEffect(() => {
    if (initialImageUrl !== imageUrl) {
      setImageUrl(initialImageUrl);
      setError(null);
    }
  }, [initialImageUrl]);

  const handleFileChange = async (e: ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    // ファイルサイズチェック (5MB以下)
    if (file.size > 5 * 1024 * 1024) {
      const errorMsg = "ファイルサイズは5MB以下にしてください";
      setError(errorMsg);
      toast({
        title: "エラー",
        description: errorMsg,
        variant: "destructive",
      });
      if (onError) onError(new Error(errorMsg));
      return;
    }

    // ファイルタイプチェック
    const validTypes = ["image/jpeg", "image/png", "image/gif", "image/webp"];
    if (!validTypes.includes(file.type)) {
      const errorMsg = "JPG, PNG, GIF, WEBPファイルのみアップロード可能です";
      setError(errorMsg);
      toast({
        title: "エラー",
        description: errorMsg,
        variant: "destructive",
      });
      if (onError) onError(new Error(errorMsg));
      return;
    }

    try {
      setIsUploading(true);
      setError(null);
      setUploadProgress(10); // 初期進捗表示

      // ローカルプレビュー用のURL生成
      const localPreviewUrl = URL.createObjectURL(file);
      setImageUrl(localPreviewUrl);

      // 進捗表示のためのタイマー（実際の進捗ではなく視覚的なフィードバック）
      const progressTimer = setInterval(() => {
        setUploadProgress((prev) => {
          const next = prev + Math.floor(Math.random() * 10);
          return next > 90 ? 90 : next; // 90%で止める（完了は別で100%にする）
        });
      }, 300);

      try {
        // Supabaseにアップロード
        const uploadedUrl = await uploadProductImage(file);

        // アップロード完了
        clearInterval(progressTimer);
        setUploadProgress(100);

        // アップロード完了後、ローカルプレビューURLを解放
        URL.revokeObjectURL(localPreviewUrl);

        // 実際のアップロードされたURLに更新
        setImageUrl(uploadedUrl);
        onImageUploaded(uploadedUrl);

        toast({
          title: "完了",
          description: "画像のアップロードが完了しました",
        });
      } catch (uploadError) {
        clearInterval(progressTimer);
        throw uploadError;
      }
    } catch (err) {
      console.error("画像アップロードエラー:", err);

      // エラーメッセージを取得
      let errorMsg = "画像のアップロードに失敗しました";
      if (err instanceof Error) {
        errorMsg = err.message;
      }

      setError(errorMsg);
      toast({
        title: "アップロードエラー",
        description: errorMsg,
        variant: "destructive",
      });

      if (onError && err instanceof Error) onError(err);
    } finally {
      setIsUploading(false);
      // ファイル選択をリセット
      if (fileInputRef.current) fileInputRef.current.value = "";
    }
  };

  const handleRemoveImage = () => {
    setImageUrl(undefined);
    setError(null);
    onImageUploaded("");
    toast({
      title: "画像を削除しました",
    });
  };

  const triggerFileInput = () => {
    if (isUploading) return; // アップロード中は新しいファイル選択を防止
    fileInputRef.current?.click();
  };

  const handleRetry = () => {
    setError(null);
    setRetryCount((prev) => prev + 1);
    triggerFileInput();
  };

  return (
    <div className="space-y-2">
      <input
        type="file"
        ref={fileInputRef}
        onChange={handleFileChange}
        accept="image/jpeg,image/png,image/gif,image/webp"
        className="hidden"
        key={`file-input-${retryCount}`} // リトライ時に強制的にリセット
      />

      {imageUrl ? (
        <div className="relative rounded border p-2">
          <div className="relative h-40 w-full overflow-hidden rounded">
            <div className="relative w-full h-full">
              {/* Next.jsのImageコンポーネントではonErrorをサーバーコンポーネントで使用できないため、
                  通常のimgタグを使用 */}
              <img
                src={imageUrl}
                alt="商品画像プレビュー"
                className="object-contain w-full h-full"
                onError={() => {
                  setError("画像の読み込みに失敗しました");
                  setImageUrl(undefined);
                  toast({
                    title: "エラー",
                    description: "画像の読み込みに失敗しました",
                    variant: "destructive",
                  });
                }}
              />
            </div>
          </div>
          <Button
            type="button"
            variant="ghost"
            size="sm"
            className="absolute right-2 top-2 h-8 w-8 rounded-full p-0"
            onClick={handleRemoveImage}
            disabled={isUploading}
          >
            <X className="h-4 w-4" />
          </Button>
        </div>
      ) : (
        <div
          onClick={triggerFileInput}
          className={`flex h-40 cursor-pointer flex-col items-center justify-center rounded border border-dashed ${
            error ? "border-red-300 bg-red-50" : "border-gray-300 bg-gray-50"
          } p-4 hover:bg-gray-100 ${isUploading ? "cursor-not-allowed opacity-70" : ""}`}
        >
          {error ? (
            <AlertCircle className="mb-2 h-8 w-8 text-red-400" />
          ) : (
            <Upload className="mb-2 h-8 w-8 text-gray-400" />
          )}
          <p className="text-sm text-gray-500">
            {error ? "エラーが発生しました" : "クリックして画像をアップロード"}
          </p>
          <p className="mt-1 text-xs text-gray-400">
            JPG, PNG, GIF, WEBP (最大5MB)
          </p>
        </div>
      )}

      {error && (
        <div className="flex items-center justify-between">
          <p className="text-xs text-red-500">{error}</p>
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={handleRetry}
            className="ml-2 h-6 px-2 py-0 text-xs"
          >
            <RefreshCw className="mr-1 h-3 w-3" />
            再試行
          </Button>
        </div>
      )}

      {isUploading && (
        <div className="space-y-1">
          <div className="flex items-center justify-center">
            <div className="h-4 w-4 animate-spin rounded-full border-2 border-primary border-t-transparent"></div>
            <span className="ml-2 text-xs">
              アップロード中... {uploadProgress}%
            </span>
          </div>
          <div className="h-1 w-full overflow-hidden rounded-full bg-gray-200">
            <div
              className="h-full bg-primary transition-all duration-300 ease-in-out"
              style={{ width: `${uploadProgress}%` }}
            ></div>
          </div>
        </div>
      )}
    </div>
  );
}
