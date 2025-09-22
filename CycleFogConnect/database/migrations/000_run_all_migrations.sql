-- CycleFog Connect データベース初期化スクリプト
-- 全てのマイグレーションを順次実行

-- 実行ログ用テーブル
CREATE TABLE IF NOT EXISTS migration_log (
    id SERIAL PRIMARY KEY,
    migration_name VARCHAR(255) NOT NULL,
    executed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    success BOOLEAN DEFAULT TRUE,
    error_message TEXT
);

-- マイグレーション実行関数
CREATE OR REPLACE FUNCTION execute_migration(migration_name TEXT, migration_sql TEXT)
RETURNS void AS $$
BEGIN
    -- マイグレーションが既に実行されているかチェック
    IF EXISTS (SELECT 1 FROM migration_log WHERE migration_log.migration_name = execute_migration.migration_name AND success = TRUE) THEN
        RAISE NOTICE 'Migration % already executed, skipping...', migration_name;
        RETURN;
    END IF;
    
    BEGIN
        -- マイグレーションを実行
        EXECUTE migration_sql;
        
        -- 成功をログに記録
        INSERT INTO migration_log (migration_name, success) 
        VALUES (migration_name, TRUE);
        
        RAISE NOTICE 'Migration % executed successfully', migration_name;
        
    EXCEPTION WHEN OTHERS THEN
        -- エラーをログに記録
        INSERT INTO migration_log (migration_name, success, error_message) 
        VALUES (migration_name, FALSE, SQLERRM);
        
        RAISE EXCEPTION 'Migration % failed: %', migration_name, SQLERRM;
    END;
END;
$$ LANGUAGE plpgsql;

-- 実行開始ログ
DO $$
BEGIN
    RAISE NOTICE 'Starting CycleFog Connect database migrations...';
END $$;

-- 001: PostGIS拡張有効化
\i 001_enable_postgis.sql

-- 002: プロフィールテーブル作成
\i 002_create_profiles_table.sql

-- 003: 探索済みタイルテーブル作成
\i 003_create_explored_tiles_table.sql

-- 004: GPSトラックテーブル作成
\i 004_create_gps_tracks_table.sql

-- 005: ライドイベントテーブル作成
\i 005_create_ride_events_table.sql

-- 006: ライド参加者テーブル作成
\i 006_create_ride_participants_table.sql

-- 007: ライド位置共有テーブル作成
\i 007_create_ride_locations_table.sql

-- 008: チャレンジテーブル作成
\i 008_create_challenges_table.sql

-- 実行完了ログ
DO $$
BEGIN
    RAISE NOTICE 'CycleFog Connect database migrations completed successfully!';
    RAISE NOTICE 'Database is ready for use.';
END $$;