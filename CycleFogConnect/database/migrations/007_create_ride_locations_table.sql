-- ライド位置共有テーブル
-- グループライド中のリアルタイム位置共有

CREATE TABLE ride_locations (
    ride_id UUID REFERENCES ride_events(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    location GEOMETRY(POINT, 4326) NOT NULL, -- PostGIS POINT
    accuracy DOUBLE PRECISION, -- GPS精度（メートル）
    speed DOUBLE PRECISION, -- 速度（m/s）
    heading DOUBLE PRECISION, -- 方角（度）
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (ride_id, user_id)
);

-- インデックス作成
CREATE INDEX idx_ride_locations_ride_id ON ride_locations(ride_id);
CREATE INDEX idx_ride_locations_user_id ON ride_locations(user_id);
CREATE INDEX idx_ride_locations_updated_at ON ride_locations(updated_at);

-- 地理空間インデックス（PostGIS）
CREATE INDEX idx_ride_locations_geometry ON ride_locations USING GIST(location);

-- Row Level Security (RLS) を有効化
ALTER TABLE ride_locations ENABLE ROW LEVEL SECURITY;

-- RLSポリシー: 承認された参加者のみ位置情報を閲覧可能
CREATE POLICY "Approved participants can view ride locations" ON ride_locations
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM ride_participants 
            WHERE ride_id = ride_locations.ride_id 
            AND user_id = auth.uid() 
            AND status = 'approved'
        )
    );

-- RLSポリシー: ユーザーは自分の位置情報のみ更新可能
CREATE POLICY "Users can update own location" ON ride_locations
    FOR ALL USING (auth.uid() = user_id);

-- RLSポリシー: 承認された参加者のみ位置情報を挿入可能
CREATE POLICY "Approved participants can insert location" ON ride_locations
    FOR INSERT WITH CHECK (
        auth.uid() = user_id 
        AND EXISTS (
            SELECT 1 FROM ride_participants 
            WHERE ride_id = ride_locations.ride_id 
            AND user_id = auth.uid() 
            AND status = 'approved'
        )
    );

-- 古い位置情報を自動削除する関数（1時間以上古いデータ）
CREATE OR REPLACE FUNCTION cleanup_old_ride_locations()
RETURNS void AS $$
BEGIN
    DELETE FROM ride_locations 
    WHERE updated_at < CURRENT_TIMESTAMP - INTERVAL '1 hour';
END;
$$ LANGUAGE plpgsql;

-- 参加者間の距離を計算する関数
CREATE OR REPLACE FUNCTION get_participant_distances(target_ride_id UUID)
RETURNS TABLE (
    user1_id UUID,
    user2_id UUID,
    distance_meters DOUBLE PRECISION,
    last_updated TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        rl1.user_id as user1_id,
        rl2.user_id as user2_id,
        ST_Distance(
            ST_GeogFromWKB(rl1.location),
            ST_GeogFromWKB(rl2.location)
        ) as distance_meters,
        LEAST(rl1.updated_at, rl2.updated_at) as last_updated
    FROM ride_locations rl1
    CROSS JOIN ride_locations rl2
    WHERE 
        rl1.ride_id = target_ride_id
        AND rl2.ride_id = target_ride_id
        AND rl1.user_id < rl2.user_id  -- 重複を避ける
        AND rl1.updated_at > CURRENT_TIMESTAMP - INTERVAL '5 minutes'
        AND rl2.updated_at > CURRENT_TIMESTAMP - INTERVAL '5 minutes';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;