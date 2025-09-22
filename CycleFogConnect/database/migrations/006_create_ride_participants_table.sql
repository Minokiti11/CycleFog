-- ライド参加者テーブル
-- ライドイベントへの参加管理

CREATE TABLE ride_participants (
    ride_id UUID REFERENCES ride_events(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'declined')) NOT NULL,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (ride_id, user_id)
);

-- インデックス作成
CREATE INDEX idx_ride_participants_ride_id ON ride_participants(ride_id);
CREATE INDEX idx_ride_participants_user_id ON ride_participants(user_id);
CREATE INDEX idx_ride_participants_status ON ride_participants(status);
CREATE INDEX idx_ride_participants_joined_at ON ride_participants(joined_at);

-- Row Level Security (RLS) を有効化
ALTER TABLE ride_participants ENABLE ROW LEVEL SECURITY;

-- RLSポリシー: ユーザーは自分の参加情報を閲覧可能
CREATE POLICY "Users can view own participation" ON ride_participants
    FOR SELECT USING (auth.uid() = user_id);

-- RLSポリシー: 主催者は自分のイベントの参加者を管理可能
CREATE POLICY "Organizers can manage event participants" ON ride_participants
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM ride_events 
            WHERE id = ride_participants.ride_id 
            AND organizer_id = auth.uid()
        )
    );

-- RLSポリシー: ユーザーは自分の参加申請を作成可能
CREATE POLICY "Users can join ride events" ON ride_participants
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- RLSポリシー: ユーザーは自分の参加状況を更新可能（キャンセル等）
CREATE POLICY "Users can update own participation" ON ride_participants
    FOR UPDATE USING (auth.uid() = user_id);

-- updated_atトリガー
CREATE TRIGGER update_ride_participants_updated_at 
    BEFORE UPDATE ON ride_participants 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- ライドイベントの参加者数を更新する関数
CREATE OR REPLACE FUNCTION update_ride_event_status()
RETURNS TRIGGER AS $$
DECLARE
    approved_count INTEGER;
    max_participants INTEGER;
BEGIN
    -- 承認された参加者数を取得
    SELECT COUNT(*) INTO approved_count
    FROM ride_participants 
    WHERE ride_id = COALESCE(NEW.ride_id, OLD.ride_id) 
    AND status = 'approved';
    
    -- 最大参加者数を取得
    SELECT ride_events.max_participants INTO max_participants
    FROM ride_events 
    WHERE id = COALESCE(NEW.ride_id, OLD.ride_id);
    
    -- ステータスを更新
    IF approved_count >= max_participants THEN
        UPDATE ride_events 
        SET status = 'full' 
        WHERE id = COALESCE(NEW.ride_id, OLD.ride_id) 
        AND status = 'open';
    ELSIF approved_count < max_participants THEN
        UPDATE ride_events 
        SET status = 'open' 
        WHERE id = COALESCE(NEW.ride_id, OLD.ride_id) 
        AND status = 'full';
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- 参加者数変更時にライドイベントステータスを自動更新するトリガー
CREATE TRIGGER update_ride_event_status_trigger
    AFTER INSERT OR UPDATE OR DELETE ON ride_participants
    FOR EACH ROW
    EXECUTE FUNCTION update_ride_event_status();