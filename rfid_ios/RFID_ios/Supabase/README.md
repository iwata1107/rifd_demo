# Supabase 実装手順

このプロジェクトでは Supabase を使用して認証機能とデータベース機能を実装しています。以下の手順に従って、プロジェクトを設定してください。

## 1. Swift Package Manager での依存関係の追加

Xcode でプロジェクトを開き、以下の手順で Supabase パッケージを追加します：

1. Xcode メニューから「File」→「Add Packages...」を選択
2. 検索バーに `https://github.com/supabase-community/supabase-swift.git` を入力
3. バージョンは最新の安定版を選択（例：1.0.0 以上）
4. 「Add Package」をクリック

## 2. Supabase 接続情報の設定

`SupabaseConfig.swift` ファイルを編集して、実際のプロジェクト情報を設定します：

```swift
struct SupabaseConfig {
    static let supabaseURL = "https://あなたのプロジェクトURL.supabase.co"
    static let supabaseAnonKey = "あなたのAnonymous API Key"

    // ...
}
```

Supabase プロジェクトの情報は、Supabase ダッシュボードの「Project Settings」→「API」から取得できます。

## 3. データベーススキーマの設定

Supabase プロジェクトで以下のテーブルが作成されていることを確認してください：

### inventory_masters テーブル

| カラム名    | データ型    | 説明                                                |
| ----------- | ----------- | --------------------------------------------------- |
| id          | uuid        | プライマリキー（デフォルト: `uuid_generate_v4()` ） |
| name        | text        | マスター名                                          |
| description | text        | 説明（NULL 許容）                                   |
| target      | text        | 業種（NULL 許容）                                   |
| created_at  | timestamptz | 作成日時（デフォルト: `now()` ）                    |
| updated_at  | timestamptz | 更新日時（NULL 許容）                               |
| user_id     | uuid        | 作成者 ID（NULL 許容）                              |

## 4. Row Level Security の設定

セキュリティを強化するために、Supabase ダッシュボードで適切な Row Level Security（RLS）ポリシーを設定することをお勧めします。

例えば、inventory_masters テーブルに対して以下のようなポリシーを設定できます：

- 認証済みユーザーのみが読み取り可能
- 自分が作成したレコードのみ更新・削除可能

## 5. アプリの実行

上記の設定が完了したら、アプリを実行してください。ログイン画面が表示され、Supabase を使った認証とデータ取得が機能するはずです。

## トラブルシューティング

- ログインできない場合は、Supabase 接続情報が正しく設定されているか確認してください。
- データが取得できない場合は、テーブル名やカラム名が正しいか、RLS ポリシーが適切に設定されているか確認してください。
- ビルドエラーが発生する場合は、Supabase パッケージが正しくインストールされているか確認してください。
