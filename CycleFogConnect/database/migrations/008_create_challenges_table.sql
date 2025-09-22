-- チャレンジテーブル
-- 個人・グループチャレンジの管理

CREATE TABLE challenges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_by UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    type VARCHAR(20) CHECK (type IN ('exploration', 'distance', 'group_exploration')) NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    target_value DECIMAL(12,2) NOT NULL, -- 目標値（距離はメートル、探索はタイル数）
    current_value DECIMAL(12,2) DEFAULT 0, -- 現在値
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'expired')) NOT NULL,
    region VARCHAR(10) CHECK (region IN ('DE', 'FR', 'NL')), -- 地域限定チャレンジ
    difficulty VARCHAR(20) CHECK (difficulty IN ('easy', 'moderate', 'hard')),
    reward_data JSONB, -- 報酬情報
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- 制約
    CONSTRAINT valid_target_value CHECK (target_value > 0),
    CONSTRAINT valid_current_value CHECK (current_value >= 0),
    CONSTRAINT valid_date_range CHECK (end_date > start_date),
    CONSTRAINT valid_progress CHECK (current_value <= target_value * 1.1) -- 10%のオーバーシュートを許可
);

-- チャレンジ参加者テーブル
CREATE TABLE challenge_participants (
    challenge_id UUID REFERENCES challenges(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    individual_progress DECIMAL(12,2) DEFAULT 0,
    last_activity_at TIMESTAMP WITH TIME ZONE,
    
    PRIMARY KEY (challenge_id, user_id)
);

-- インデックス作成
CREATE INDEX idx_challenges_created_by ON challenges(created_by);
CREATE INDEX idx_challenges_type ON challenges(type);
CREATE INDEX idx_challenges_status ON challenges(status);
CREATE INDEX idx_challenges_region ON challenges(region);
CREATE INDEX idx_challenges_start_date ON challenges(start_date);
CREATE INDEX idx_challenges_end_date ON challenges(end_date);

CREATE INDEX idx_challenge_participants_challenge_id ON challenge_participants(challenge_id);
CREATE INDEX idx_challenge_participants_user_id ON challenge_participants(user_id);

-- Row Level Security (RLS) を有効化
ALTER TABLE challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenge_participants ENABLE ROW LEVEL SECURITY;

-- RLSポリシー: 誰でもアクティブなチャレンジを閲覧可能
CREATE POLICY "Anyone can view active challenges" ON challenges
    FOR SELECT USING (status = 'active' AND auth.uid() IS NOT NULL);

-- RLSポリシー: 作成者は自分のチャレンジを管理可能
CREATE POLICY "Creators can manage their challenges" ON challenges
    USING (auth.uid() = created_by);

-- RLSポリシー: 認証済みユーザーはチャレンジを作成可能
CREATE POLICY "Authenticated users can create challenges" ON challenges
    FOR INSERT WITH CHECK (auth.uid() = created_by);

-- RLSポリシー: ユーザーは自分の参加情報を閲覧可能
CREATE POLICY "Users can view own participation" ON challenge_participants
    FOR SELECT USING (auth.uid() = user_id);

-- RLSポリシー: チャレンジ作成者は参加者情報を閲覧可能
CREATE POLICY "Challenge creators can view participants" ON challenge_participants
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM challenges 
            WHERE id = challenge_participants.challenge_id 
            AND created_by = auth.uid()
        )
    );

-- RLSポリシー: ユーザーはチャレンジに参加可能
CREATE POLICY "Users can join challenges" ON challenge_participants
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- updated_atトリガー
CREATE TRIGGER update_challenges_updated_at 
    BEFORE UPDATE ON challenges 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- チャレンジの進捗を更新する関数
CREATE OR REPLACE FUNCTION update_challenge_progress(
    target_challenge_id UUID,
    target_user_id UUID,
    progress_increment DECIMAL
)
RETURNS void AS $$
DECLARE
    challenge_type VARCHAR;
    total_progress DECIMAL;
    target_value DECIMAL;
BEGIN
    -- チャレンジタイプと目標値を取得
    SELECT type, challenges.target_value INTO challenge_type, target_value
    FROM challenges 
    WHERE id = target_challenge_id;
    
    -- 個人進捗を更新
    UPDATE challenge_participants 
    SET 
        individual_progress = individual_progress + progress_increment,
        last_activity_at = CURRENT_TIMESTAMP
    WHERE challenge_id = target_challenge_id 
    AND user_id = target_user_id;
    
    -- グループチャレンジの場合は全体進捗も更新
    IF challenge_type = 'group_exploration' THEN
        SELECT SUM(individual_progress) INTO total_progress
        FROM challenge_participants 
        WHERE challenge_id = target_challenge_id;
        
        UPDATE challenges 
        SET 
            current_value = total_progress,
            status = CASE 
                WHEN total_progress >= target_value THEN 'completed'
                ELSE status 
            END,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = target_challenge_id;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 期限切れチャレンジを自動更新する関数
CREATE OR REPLACE FUNCTION expire_old_challenges()
RETURNS void AS $$
BEGIN
    UPDATE challenges 
    SET status = 'expired', updated_at = CURRENT_TIMESTAMP
    WHERE end_date < CURRENT_TIMESTAMP 
    AND status = 'active';
END;
$$ LANGUAGE plpgsql;