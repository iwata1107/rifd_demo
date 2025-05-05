# RFID iOS アプリケーションアーキテクチャ

このドキュメントでは、RFID iOS アプリケーションのアーキテクチャと設計原則について説明します。

## アーキテクチャ概要: シンプルな MVVM

このアプリケーションは、シンプルな MVVM（Model-View-ViewModel）パターンを採用しています。機能ごとにコードを整理し、関連するファイルを近くに配置することで、開発効率と可読性を高めています。

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  ┌─────────┐       ┌─────────────┐       ┌─────────────────┐   │
│  │  Views  │◄─────►│  ViewModels │◄─────►│     Models      │   │
│  └─────────┘       └─────────────┘       └─────────────────┘   │
│                          │                                      │
│                          ▼                                      │
│                    ┌─────────────┐                             │
│                    │   Services  │                             │
│                    └─────────────┘                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## コンポーネントの責任

### 1. Views

ユーザーインターフェースを担当します。

- SwiftUI の View を実装
- ViewModel からのデータを表示
- ユーザー操作を ViewModel に伝達
- UI の状態を反映

### 2. ViewModels

ビジネスロジックと状態管理を担当します。

- View のためのデータを準備
- ユーザー操作に応じたロジックを実行
- Services を使用してデータ操作
- UI の状態管理

### 3. Models

データモデルを定義します。

- アプリケーションで使用するデータ構造
- ビジネスロジックで使用するエンティティ
- データの検証ロジック

### 4. Services

外部サービスとの連携やデータアクセスを担当します。

- API 通信
- データベースアクセス
- 認証処理
- ハードウェア（スキャナー）との連携

## 依存性の方向

依存性は以下の方向に流れます：

```
Views → ViewModels → Services → Models
```

## 依存性注入（DI）

依存性は、AppDependencies クラスを通じて注入されます。これにより：

- コンポーネント間の結合度を低減
- テスト容易性の向上
- コードの再利用性の向上

## ファイル命名規則

- **Views**: `[機能名]View.swift`（例：`LoginView.swift`）
- **ViewModels**: `[機能名]ViewModel.swift`（例：`AuthViewModel.swift`）
- **Models**: `[名詞].swift`（例：`User.swift`）
- **Services**: `[名詞]Service.swift`（例：`SupabaseService.swift`）

## フォルダ構成

```
RFID_ios/
├── App/                  # アプリケーションのエントリーポイント
│   ├── RFID_iosApp.swift      # アプリエントリーポイント
│   └── AppDependencies.swift  # 依存関係の管理
│
├── Features/             # 機能別フォルダ
│   ├── Auth/             # 認証機能
│   │   ├── Views/        # 画面
│   │   ├── ViewModels/   # ビジネスロジック
│   │   └── Models/       # データモデル
│   │
│   ├── Scanner/          # スキャナー機能
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Models/
│   │
│   ├── Inventory/        # 在庫管理機能
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── Models/
│   │
│   ├── Settings/         # 設定機能
│   │   ├── Views/
│   │   └── ViewModels/
│   │
│   ├── Compare/          # 比較機能
│   │   ├── Views/
│   │   └── ViewModels/
│   │
│   └── Common/           # 共通コンポーネント
│       └── Views/
│
├── Services/             # サービス層
│   ├── Supabase/         # Supabase関連
│   │   ├── SupabaseClient.swift
│   │   └── SupabaseConfig.swift
│   │
│   └── Scanner/          # スキャナー関連
│
├── Utils/                # ユーティリティ
│   ├── Extensions/       # 拡張
│   │   ├── Date+Extensions.swift
│   │   └── String+Extensions.swift
│   │
│   └── Helpers/          # ヘルパー関数
│
└── Resources/            # リソース
    ├── Assets.xcassets/
    └── Sound/
```

## このアーキテクチャのメリット

1. **シンプルさ**

   - 理解しやすい構造
   - 学習コストが低い
   - 過度な抽象化を避ける

2. **フィーチャー中心の構成**

   - 機能単位でディレクトリを分けることで、関連するコードが近くに配置される
   - 新しい機能を追加する場合は対応する Feature フォルダに集約できる

3. **開発効率**

   - ファイル検索が容易（機能名で絞り込める）
   - 関連するコードが近くにあるため、文脈の切り替えが少ない
   - 機能単位での分担が容易

4. **スケーラビリティ**
   - 機能追加時は新しい Feature フォルダを追加するだけ
   - 既存の機能を修正する際も、関連コードが集約されている

## 新機能の追加方法

新機能を追加する場合は、以下の手順に従ってください：

1. **Features**フォルダに新しい機能のディレクトリを作成
2. **Models**の定義（必要な場合）
3. **ViewModels**の実装
4. **Views**の実装
5. 必要に応じて**Services**の追加または更新
6. **AppDependencies**の更新

## テスト戦略

- **ViewModels**: ユニットテスト（モックサービスを使用）
- **Services**: ユニットテスト（モック外部依存を使用）
- **UI Tests**: UI テスト（実際の UI との統合テスト）

## 参考資料

- [MVVM in SwiftUI](https://developer.apple.com/documentation/swiftui)
- [Swift Style Guide](https://google.github.io/swift/)
