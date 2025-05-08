"use client";

import { useState } from "react";
import { AlertCircle, CheckCircle, Loader2 } from "lucide-react";

import { Button } from "@/components/ui/Button";

interface TestConnectionButtonProps {
  siteId: string;
  apiValues: Record<string, string>;
  onSuccess?: () => void;
  onError?: (error: string) => void;
}

export function TestConnectionButton({
  siteId,
  apiValues,
  onSuccess,
  onError,
}: TestConnectionButtonProps) {
  const [testing, setTesting] = useState(false);
  const [result, setResult] = useState<{
    status: "success" | "error" | null;
    message: string;
  }>({ status: null, message: "" });

  const handleTest = async () => {
    setTesting(true);
    setResult({ status: null, message: "" });

    try {
      // 実際のAPIテストの代わりに、擬似的な遅延と結果を返す
      await new Promise((resolve) => setTimeout(resolve, 1500));

      // 必須フィールドが空でないかチェック
      const hasEmptyRequiredField = Object.entries(apiValues).some(
        ([key, value]) => {
          // APIキーとシークレットキーは必須とする
          if ((key === "apiKey" || key === "secretKey") && !value) {
            return true;
          }
          return false;
        }
      );

      if (hasEmptyRequiredField) {
        const errorMessage = "必須フィールドが入力されていません。";
        setResult({
          status: "error",
          message: errorMessage,
        });
        if (onError) onError(errorMessage);
        return;
      }

      // 成功レスポンスをシミュレート
      setResult({
        status: "success",
        message: "接続テストに成功しました。APIキーは有効です。",
      });
      if (onSuccess) onSuccess();
    } catch (error) {
      const errorMessage =
        error instanceof Error
          ? error.message
          : "接続テストに失敗しました。設定を確認してください。";
      setResult({
        status: "error",
        message: errorMessage,
      });
      if (onError) onError(errorMessage);
    } finally {
      setTesting(false);
    }
  };

  return (
    <div>
      <Button
        type="button"
        variant="outline"
        onClick={handleTest}
        disabled={testing}
        className="w-full"
      >
        {testing ? (
          <>
            <Loader2 className="mr-2 h-4 w-4 animate-spin" />
            接続テスト中...
          </>
        ) : (
          "接続テスト"
        )}
      </Button>

      {result.status && (
        <div
          className={`mt-3 p-3 rounded text-sm ${
            result.status === "success"
              ? "bg-green-50 text-green-800"
              : "bg-red-50 text-red-800"
          }`}
        >
          <div className="flex items-start">
            {result.status === "success" ? (
              <CheckCircle className="h-5 w-5 mr-2 flex-shrink-0" />
            ) : (
              <AlertCircle className="h-5 w-5 mr-2 flex-shrink-0" />
            )}
            <p>{result.message}</p>
          </div>
        </div>
      )}
    </div>
  );
}
