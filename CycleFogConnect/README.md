# CycleFog Connect

CycleFog Connectは、サイクリストのための走行ルート可視化とグループライドマッチングアプリです。Fog of World型の地図可視化により未踏エリアを明確にし、グループライド機能で仲間との連携を促進することで、サイクリングの継続意欲を喚起します。

## 主な機能

- **Fog of World型地図可視化**: GPSログから走行ルートを地図上に塗りつぶし表示
- **グループライドマッチング**: 地域と予定日時を指定してライド募集・参加
- **チャレンジ機能**: 個人・グループ単位での未踏エリア制覇や走行距離目標
- **モチベーション維持通知**: 未踏エリア近接時の探索促進通知
- **安全・ナビサポート**: リアルタイム位置共有と安全注意箇所アラート

## 対象地域

- ドイツ (DE)
- フランス (FR)
- オランダ (NL)

## 技術スタック

- **フロントエンド**: React Native + Expo
- **バックエンド**: Supabase (PostgreSQL + PostGIS)
- **状態管理**: Zustand
- **地図**: React Native Maps + OpenStreetMap
- **認証**: Supabase Auth
- **リアルタイム通信**: Supabase Realtime

## 開発環境のセットアップ

### 前提条件

- Node.js 20.x以上
- npm または yarn
- Expo CLI
- iOS Simulator (iOS開発の場合)
- Android Studio (Android開発の場合)

### インストール

1. リポジトリをクローン
```bash
git clone <repository-url>
cd CycleFogConnect
```

2. 依存関係をインストール
```bash
npm install --legacy-peer-deps
```

3. 環境変数を設定
```bash
cp .env.example .env
# .envファイルを編集してSupabaseの設定を追加
```

4. 開発サーバーを起動
```bash
npm start
```

### 環境変数

`.env`ファイルに以下の変数を設定してください：

```
EXPO_PUBLIC_SUPABASE_URL=your_supabase_project_url
EXPO_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
```

## プロジェクト構造

```
src/
├── components/     # 再利用可能なUIコンポーネント
├── screens/        # 画面コンポーネント
├── services/       # API通信・外部サービス連携
├── stores/         # Zustand状態管理
├── types/          # TypeScript型定義
└── utils/          # ユーティリティ関数
```

## 開発スクリプト

- `npm start` - Expo開発サーバー起動
- `npm run android` - Android版起動
- `npm run ios` - iOS版起動
- `npm run web` - Web版起動
- `npm run test` - テスト実行
- `npm run lint` - ESLint実行
- `npm run type-check` - TypeScript型チェック

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。