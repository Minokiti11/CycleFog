-- ライドイベントテーブル
-- グループライドの募集・管理

CREATE TABLE ride_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organizer_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    start_location GEOMETRY(POINT, 4326) NOT NULL, -- PostGIS POINT
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    difficulty VARCHAR(20) CHECK (difficulty IN ('easy', 'moderate', 'hard')) NOT NULL,
    max_participants INTEGER DEFAULT 10,
    status VARCHAR(20) DEFAULT 'open' CHECK (status IN ('open', 'full', 'started', 'completed', 'cancelled')) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- 制約
    CONSTRAINT valid_max_participants CHECK (max_participants > 0),
    CONSTRAINT valid_future_start_time CHECK (start_time > CURRENT_TIMESTAMP)
);

-- インデックス作成
CREATE INDEX idx_ride_events_organizer ON ride_events(organizer_id);
CREATE INDEX idx_ride_events_start_time ON ride_events(start_time);
CREATE INDEX idx_ride_events_status ON ride_events(status);
CREATE INDEX idx_ride_events_difficulty ON ride_events(difficulty);
CREATE INDEX idx_ride_events_created_at ON ride_events(created_at);

-- 地理空間インデックス（PostGIS）
CREATE INDEX idx_ride_events_location ON ride_events USING GIST(start_location);

-- Row Level Security (RLS) を有効化
ALTER TABLE ride_events ENABLE ROW LEVEL SECURITY;

-- RLSポリシー: 誰でもオープンなライドイベントを閲覧可能
CREATE POLICY "Anyone can view open ride events" ON ride_events
    FOR SELECT USING (status = 'open' AND auth.uid() IS NOT NULL);

-- RLSポリシー: 主催者は自分のイベントを管理可能
CREATE POLICY "Organizers can manage their events" ON ride_events
    USING (auth.uid() = organizer_id);

-- RLSポリシー: 認証済みユーザーはライドイベントを作成可能
CREATE POLICY "Authenticated users can create ride events" ON ride_events
    FOR INSERT WITH CHECK (auth.uid() = organizer_id);

-- updated_atトリガー
CREATE TRIGGER update_ride_events_updated_at 
    BEFORE UPDATE ON ride_events 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- 地域内のライドイベントを検索する関数
CREATE OR REPLACE FUNCTION find_nearby_ride_events(
    center_lat DOUBLE PRECISION,
    center_lng DOUBLE PRECISION,
    radius_km DOUBLE PRECISION DEFAULT 50,
    target_difficulty VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    id UUID,
    title VARCHAR,
    description TEXT,
    organizer_id UUID,
    start_time TIMESTAMP WITH TIME ZONE,
    difficulty VARCHAR,
    max_participants INTEGER,
    current_participants BIGINT,
    distance_km DOUBLE PRECISION
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        re.id,
        re.title,
        re.description,
        re.organizer_id,
        re.start_time,
        re.difficulty,
        re.max_participants,
        COALESCE(participant_count.count, 0) as current_participants,
        ST_Distance(
            ST_GeogFromWKB(re.start_location),
            ST_GeogFromText('POINT(' || center_lng || ' ' || center_lat || ')')
        ) / 1000 as distance_km
    FROM ride_events re
    LEFT JOIN (
        SELECT ride_id, COUNT(*) as count
        FROM ride_participants 
        WHERE status = 'approved'
        GROUP BY ride_id
    ) participant_count ON re.id = participant_count.ride_id
    WHERE 
        re.status = 'open'
        AND ST_DWithin(
            ST_GeogFromWKB(re.start_location),
            ST_GeogFromText('POINT(' || center_lng || ' ' || center_lat || ')'),
            radius_km * 1000
        )
        AND (target_difficulty IS NULL OR re.difficulty = target_difficulty)
        AND re.start_time > CURRENT_TIMESTAMP
    ORDER BY distance_km ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;