-- データベース設定確認スクリプト
-- セットアップが正しく完了しているかチェック

-- PostGIS拡張確認
SELECT 'PostGIS Extension' as check_name, 
       CASE WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'postgis') 
            THEN '✓ Enabled' 
            ELSE '✗ Not Found' 
       END as status;

-- テーブル存在確認
SELECT 'Tables Created' as check_name,
       COUNT(*) || ' tables found' as status
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN (
    'profiles', 'explored_tiles', 'gps_tracks', 'ride_events', 
    'ride_participants', 'ride_locations', 'challenges', 'challenge_participants'
);

-- RLS有効化確認
SELECT 'Row Level Security' as check_name,
       COUNT(*) || ' tables with RLS enabled' as status
FROM pg_tables 
WHERE schemaname = 'public' 
AND rowsecurity = true;

-- ポリシー数確認
SELECT 'Security Policies' as check_name,
       COUNT(*) || ' policies created' as status
FROM pg_policies 
WHERE schemaname = 'public';

-- インデックス確認
SELECT 'Indexes Created' as check_name,
       COUNT(*) || ' indexes found' as status
FROM pg_indexes 
WHERE schemaname = 'public';

-- 関数確認
SELECT 'Functions Created' as check_name,
       COUNT(*) || ' functions found' as status
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_type = 'FUNCTION'
AND routine_name IN (
    'get_exploration_stats', 'get_user_cycling_stats', 
    'find_nearby_ride_events', 'update_challenge_progress'
);

-- 詳細テーブル情報
SELECT 
    table_name,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as column_count,
    (SELECT COUNT(*) FROM pg_indexes WHERE tablename = t.table_name) as index_count,
    (SELECT COUNT(*) FROM pg_policies WHERE tablename = t.table_name) as policy_count
FROM information_schema.tables t
WHERE table_schema = 'public' 
AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- PostGISバージョン情報
SELECT PostGIS_Version() as postgis_version;