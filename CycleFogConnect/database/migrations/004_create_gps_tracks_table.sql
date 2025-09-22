-- GPSトラックテーブル
-- ユーザーの走行記録を管理

CREATE TABLE gps_tracks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    name VARCHAR(200),
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    total_distance DECIMAL(10,2) NOT NULL, -- メートル
    elevation_gain DECIMAL(8,2) DEFAULT 0, -- メートル
    track_data GEOMETRY(LINESTRING, 4326), -- PostGIS LINESTRING
    gpx_file_path VARCHAR(500), -- Supabase Storage path
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- 制約
    CONSTRAINT valid_distance CHECK (total_distance >= 0),
    CONSTRAINT valid_elevation CHECK (elevation_gain >= 0),
    CONSTRAINT valid_time_range CHECK (end_time > start_time)
);

-- インデックス作成
CREATE INDEX idx_gps_tracks_user_id ON gps_tracks(user_id);
CREATE INDEX idx_gps_tracks_start_time ON gps_tracks(start_time);
CREATE INDEX idx_gps_tracks_created_at ON gps_tracks(created_at);
CREATE INDEX idx_gps_tracks_distance ON gps_tracks(total_distance);

-- 地理空間インデックス（PostGIS）
CREATE INDEX idx_gps_tracks_geometry ON gps_tracks USING GIST(track_data);

-- Row Level Security (RLS) を有効化
ALTER TABLE gps_tracks ENABLE ROW LEVEL SECURITY;

-- RLSポリシー: ユーザーは自分のトラックのみ管理可能
CREATE POLICY "Users can manage own tracks" ON gps_tracks
    USING (auth.uid() = user_id);

-- RLSポリシー: ユーザーは自分のトラックのみ挿入可能
CREATE POLICY "Users can insert own tracks" ON gps_tracks
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- updated_atトリガー
CREATE TRIGGER update_gps_tracks_updated_at 
    BEFORE UPDATE ON gps_tracks 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- ユーザーの走行統計を取得する関数
CREATE OR REPLACE FUNCTION get_user_cycling_stats(target_user_id UUID)
RETURNS TABLE (
    total_tracks INTEGER,
    total_distance NUMERIC,
    total_elevation_gain NUMERIC,
    average_distance NUMERIC,
    longest_ride NUMERIC,
    first_ride_date TIMESTAMP WITH TIME ZONE,
    last_ride_date TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*)::INTEGER as total_tracks,
        COALESCE(SUM(gps_tracks.total_distance), 0) as total_distance,
        COALESCE(SUM(gps_tracks.elevation_gain), 0) as total_elevation_gain,
        COALESCE(AVG(gps_tracks.total_distance), 0) as average_distance,
        COALESCE(MAX(gps_tracks.total_distance), 0) as longest_ride,
        MIN(gps_tracks.start_time) as first_ride_date,
        MAX(gps_tracks.start_time) as last_ride_date
    FROM gps_tracks 
    WHERE user_id = target_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;