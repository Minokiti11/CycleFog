-- ユーザープロフィールテーブル
-- Supabase Authと連携してユーザー情報を管理

CREATE TABLE profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    cycling_level VARCHAR(20) CHECK (cycling_level IN ('leisure', 'racer')) NOT NULL,
    region VARCHAR(10) CHECK (region IN ('DE', 'FR', 'NL')) NOT NULL,
    preferred_language VARCHAR(5) DEFAULT 'en',
    avatar_url VARCHAR(500),
    bio TEXT,
    privacy_settings JSONB DEFAULT '{"location_sharing": false, "profile_public": true}',
    notification_settings JSONB DEFAULT '{"proximity_alerts": true, "challenge_updates": true}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- インデックス作成
CREATE INDEX idx_profiles_region ON profiles(region);
CREATE INDEX idx_profiles_cycling_level ON profiles(cycling_level);
CREATE INDEX idx_profiles_created_at ON profiles(created_at);

-- Row Level Security (RLS) を有効化
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- RLSポリシー: ユーザーは自分のプロフィールのみ閲覧可能
CREATE POLICY "Users can view own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

-- RLSポリシー: ユーザーは自分のプロフィールのみ更新可能
CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

-- RLSポリシー: ユーザーは自分のプロフィールのみ挿入可能
CREATE POLICY "Users can insert own profile" ON profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- RLSポリシー: 公開設定されたプロフィールは他のユーザーも閲覧可能
CREATE POLICY "Users can view public profiles" ON profiles
    FOR SELECT USING (
        privacy_settings->>'profile_public' = 'true' 
        AND auth.uid() IS NOT NULL
    );

-- updated_at自動更新のトリガー関数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- updated_atトリガー
CREATE TRIGGER update_profiles_updated_at 
    BEFORE UPDATE ON profiles 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();