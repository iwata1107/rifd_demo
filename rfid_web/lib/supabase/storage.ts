import { v4 as uuidv4 } from "uuid";

import { createClient } from "./client";

/**
 * 画像ファイルをSupabase Storageにアップロードする
 * @param file アップロードするファイル
 * @param bucket バケット名（デフォルト: "product-images"）
 * @returns アップロードされた画像のURL
 */
export async function uploadProductImage(
  file: File,
  bucket: string = "product-images"
): Promise<string> {
  try {
    const supabase = createClient();
    console.log("Supabaseクライアント初期化完了");

    // ファイル名を一意にするためにUUIDを使用
    const fileExt = file.name.split(".").pop();
    const fileName = `${uuidv4()}.${fileExt}`;
    const filePath = `${fileName}`;
    console.log(`ファイル名: ${filePath}`);

    // 認証状態を確認
    const {
      data: { session },
    } = await supabase.auth.getSession();
    if (!session) {
      console.error("認証されていません。ログインが必要です。");
      throw new Error("認証されていません。ログインしてください。");
    }

    try {
      // バケットが存在するか確認
      console.log("バケット確認中...");
      const { data: buckets, error: bucketsError } =
        await supabase.storage.listBuckets();

      if (bucketsError) {
        console.error("バケット一覧取得エラー:", bucketsError);
        // バケット一覧取得に失敗した場合でも、アップロードを試みる
        console.log("バケット一覧取得に失敗しましたが、アップロードを試みます");
      } else {
        const bucketExists = buckets?.some((b) => b.name === bucket);
        console.log(`バケット "${bucket}" 存在: ${bucketExists}`);

        // バケットが存在しない場合は作成を試みる
        if (!bucketExists) {
          try {
            console.log(`バケット "${bucket}" を作成中...`);
            const { error: createBucketError } =
              await supabase.storage.createBucket(bucket, {
                public: true,
                fileSizeLimit: 5242880, // 5MB
                allowedMimeTypes: [
                  "image/jpeg",
                  "image/png",
                  "image/gif",
                  "image/webp",
                ],
              });

            if (createBucketError) {
              console.error("バケット作成エラー:", createBucketError);
              console.log(
                "バケット作成に失敗しましたが、既存のバケットへのアップロードを試みます"
              );
            } else {
              console.log(`バケット "${bucket}" 作成完了`);
            }
          } catch (bucketError) {
            console.error("バケット作成中に例外が発生:", bucketError);
            console.log(
              "バケット作成に失敗しましたが、既存のバケットへのアップロードを試みます"
            );
          }
        }
      }
    } catch (bucketCheckError) {
      console.error("バケット確認中にエラーが発生:", bucketCheckError);
      console.log("バケット確認に失敗しましたが、アップロードを試みます");
    }

    // ファイルをアップロード（upsertをtrueに変更して既存ファイルを上書き可能に）
    console.log("ファイルアップロード開始...");
    const { data, error } = await supabase.storage
      .from(bucket)
      .upload(filePath, file, {
        cacheControl: "3600",
        upsert: true, // 既存ファイルを上書き
      });

    if (error) {
      console.error("ファイルアップロードエラー:", error);

      // エラーの種類に応じたメッセージを返す
      if (error.message.includes("storage/bucket-not-found")) {
        throw new Error(
          "ストレージバケットが見つかりません。管理者に連絡してください。"
        );
      } else if (error.message.includes("storage/unauthorized")) {
        throw new Error(
          "ストレージへのアクセス権限がありません。再ログインしてください。"
        );
      } else if (error.message.includes("network")) {
        throw new Error(
          "ネットワークエラーが発生しました。インターネット接続を確認してください。"
        );
      } else {
        throw new Error(`ファイルのアップロードに失敗: ${error.message}`);
      }
    }
    console.log("ファイルアップロード完了:", data?.path);

    // 公開URLを取得
    const { data: publicURL } = supabase.storage
      .from(bucket)
      .getPublicUrl(filePath);

    if (!publicURL || !publicURL.publicUrl) {
      throw new Error("公開URLの取得に失敗しました");
    }

    console.log("公開URL取得:", publicURL.publicUrl);
    return publicURL.publicUrl;
  } catch (error) {
    console.error("画像アップロード処理エラー:", error);
    throw error;
  }
}
