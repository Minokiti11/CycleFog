# CycleFog Connect データベース設定

このディレクトリには、CycleFog ConnectアプリのSupabaseデータベース設定ファイルが含まれています。

## 構成

```
database/
├── migrations/          # データベーススキーママイグレーション
│   ├── 000_run_all_migrations.sql    # 全マイグレーション実行
│   ├── 001_enable_postgis.sql        # PostGIS拡張有効化
│   ├── 002_create_profiles_table.sql # ユーザープロフィール
│   ├── 003_create_explored_tiles_table.sql # 探索済みタイル
│   ├── 004_create_gps_tracks_table.sql     # GPSトラック
│   ├── 005_create_ride_events_table.sql    # ライドイベント
│   ├── 006_create_ride_participants_table.sql # ライド参加者
│   ├── 007_create_ride_locations_table.sql    # リアルタイム位置
│   └── 008_create_challenges_table.sql       # チャレンジ
└── seed/               # 開発用サンプルデータ
    └── 001_sample_data.sql
```

## セットアップ手順

### 1. Supabaseプロジェクト作成

1. [Supabase](https://supabase.com)にアクセス
2. 新しいプロジェクトを作成
3. プロジェクトの設定から以下を取得：
   - Project URL
   - Anon Key

### 2. 環境変数設定

`.env`ファイルを作成し、Supabase認証情報を設定：

```bash
cp .env.example .env
# .envファイルを編集してSupabaseの設定を追加
```

### 3. PostGIS拡張有効化

Supabase SQL Editorで以下を実行：

```sql
-- PostGIS拡張を有効化
CREATE EXTENSION IF NOT EXISTS postgis;
```

### 4. データベーススキーマ作成

Supabase SQL Editorで各マイグレーションファイルを順次実行：

1. `001_enable_postgis.sql`
2. `002_create_profiles_table.sql`
3. `003_create_explored_tiles_table.sql`
4. `004_create_gps_tracks_table.sql`
5. `005_create_ride_events_table.sql`
6. `006_create_ride_participants_table.sql`
7. `007_create_ride_locations_table.sql`
8. `008_create_challenges_table.sql`

または、`000_run_all_migrations.sql`を実行して一括実行。

### 5. Row Level Security (RLS) 確認

各テーブルでRLSが有効化され、適切なポリシーが設定されていることを確認：

```sql
-- RLS状態確認
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public';

-- ポリシー確認
SELECT schemaname, tablename, policyname, cmd, qual 
FROM pg_policies 
WHERE schemaname = 'public';
```

## 主要テーブル

### profiles
- ユーザープロフィール情報
- Supabase Authと連携
- サイクリングレベル、地域、設定を管理

### explored_tiles
- 探索済み地図タイル情報
- Fog of World機能の基盤
- タイル座標とユーザー別探索状況

### gps_tracks
- GPSトラックデータ
- PostGIS LINESTRINGで走行ルートを保存
- 距離、標高獲得、時間情報

### ride_events
- グループライドイベント
- PostGIS POINTで開始地点を保存
- 難易度、参加者数制限

### ride_participants
- ライドイベント参加管理
- 参加申請・承認フロー
- 自動的にイベントステータス更新

### ride_locations
- リアルタイム位置共有
- グループライド中の参加者位置
- 自動的に古いデータをクリーンアップ

### challenges
- 個人・グループチャレンジ
- 探索・距離目標の管理
- 進捗追跡と自動完了判定

## セキュリティ

### Row Level Security (RLS)
- 全テーブルでRLS有効化
- ユーザーは自分のデータのみアクセス可能
- 公開データ（ライドイベント等）は適切に制御

### 主要ポリシー
- **profiles**: 自分のプロフィールのみ管理、公開設定に応じて他ユーザーも閲覧可能
- **gps_tracks**: 自分のトラックのみ管理
- **ride_events**: オープンイベントは誰でも閲覧、主催者のみ管理
- **challenges**: アクティブチャレンジは誰でも閲覧、作成者のみ管理

## 開発用データ

開発・テスト環境では`seed/001_sample_data.sql`を使用してサンプルデータを作成可能：

```sql
-- ユーザー登録後に実行
SELECT create_sample_ride_events();
SELECT create_sample_challenges();
```

## 注意事項

- 本番環境では絶対にサンプルデータを作成しない
- PostGIS拡張は必須（地理空間データ処理のため）
- RLSポリシーは慎重にテストしてから本番適用
- 定期的に古いデータ（位置情報等）をクリーンアップ