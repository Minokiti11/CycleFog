-- 開発用サンプルデータ
-- テスト・開発環境でのみ使用

-- サンプルプロフィール（実際の認証ユーザーが作成された後に手動で追加）
-- 注意: auth.users テーブルはSupabase Authが管理するため、
-- 実際のユーザー登録後にプロフィールを作成する必要があります

-- サンプルライドイベント用の関数
CREATE OR REPLACE FUNCTION create_sample_ride_events()
RETURNS void AS $$
DECLARE
    sample_user_id UUID;
BEGIN
    -- 既存のユーザーIDを取得（存在する場合）
    SELECT id INTO sample_user_id FROM auth.users LIMIT 1;
    
    IF sample_user_id IS NOT NULL THEN
        -- ベルリンでのサンプルライドイベント
        INSERT INTO ride_events (
            organizer_id, title, description, start_location, start_time, difficulty, max_participants
        ) VALUES (
            sample_user_id,
            'Morning Ride in Berlin',
            'Join us for a scenic morning ride through Berlin''s beautiful parks and landmarks.',
            ST_GeomFromText('POINT(13.4050 52.5200)', 4326), -- ブランデンブルク門
            CURRENT_TIMESTAMP + INTERVAL '7 days',
            'moderate',
            8
        );
        
        -- パリでのサンプルライドイベント
        INSERT INTO ride_events (
            organizer_id, title, description, start_location, start_time, difficulty, max_participants
        ) VALUES (
            sample_user_id,
            'Seine River Cycling Tour',
            'Explore Paris along the beautiful Seine River. Perfect for leisure cyclists.',
            ST_GeomFromText('POINT(2.3522 48.8566)', 4326), -- ルーブル美術館
            CURRENT_TIMESTAMP + INTERVAL '10 days',
            'easy',
            12
        );
        
        -- アムステルダムでのサンプルライドイベント
        INSERT INTO ride_events (
            organizer_id, title, description, start_location, start_time, difficulty, max_participants
        ) VALUES (
            sample_user_id,
            'Dutch Countryside Adventure',
            'Experience the classic Dutch cycling culture through beautiful countryside.',
            ST_GeomFromText('POINT(4.9041 52.3676)', 4326), -- アムステルダム中央駅
            CURRENT_TIMESTAMP + INTERVAL '14 days',
            'hard',
            6
        );
        
        RAISE NOTICE 'Sample ride events created successfully';
    ELSE
        RAISE NOTICE 'No users found. Please create users first before running sample data.';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- サンプルチャレンジ用の関数
CREATE OR REPLACE FUNCTION create_sample_challenges()
RETURNS void AS $$
DECLARE
    sample_user_id UUID;
BEGIN
    -- 既存のユーザーIDを取得（存在する場合）
    SELECT id INTO sample_user_id FROM auth.users LIMIT 1;
    
    IF sample_user_id IS NOT NULL THEN
        -- 探索チャレンジ
        INSERT INTO challenges (
            created_by, type, title, description, target_value, start_date, end_date, region, difficulty
        ) VALUES (
            sample_user_id,
            'exploration',
            'Berlin Explorer',
            'Explore 100 new map tiles in Berlin area',
            100,
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP + INTERVAL '30 days',
            'DE',
            'moderate'
        );
        
        -- 距離チャレンジ
        INSERT INTO challenges (
            created_by, type, title, description, target_value, start_date, end_date, difficulty
        ) VALUES (
            sample_user_id,
            'distance',
            '500km Challenge',
            'Cycle 500 kilometers in one month',
            500000, -- メートル単位
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP + INTERVAL '30 days',
            'hard'
        );
        
        -- グループ探索チャレンジ
        INSERT INTO challenges (
            created_by, type, title, description, target_value, start_date, end_date, region, difficulty
        ) VALUES (
            sample_user_id,
            'group_exploration',
            'European Cycling Community',
            'Together, let''s explore 1000 new areas across Europe',
            1000,
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP + INTERVAL '90 days',
            NULL, -- 全地域
            'easy'
        );
        
        RAISE NOTICE 'Sample challenges created successfully';
    ELSE
        RAISE NOTICE 'No users found. Please create users first before running sample data.';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 開発環境でのみ実行する警告
DO $$
BEGIN
    RAISE NOTICE '=== SAMPLE DATA CREATION ===';
    RAISE NOTICE 'This script creates sample data for development/testing purposes only.';
    RAISE NOTICE 'Do NOT run this in production environment.';
    RAISE NOTICE '';
    RAISE NOTICE 'To create sample data after user registration:';
    RAISE NOTICE '1. Register users through the app';
    RAISE NOTICE '2. Run: SELECT create_sample_ride_events();';
    RAISE NOTICE '3. Run: SELECT create_sample_challenges();';
END $$;