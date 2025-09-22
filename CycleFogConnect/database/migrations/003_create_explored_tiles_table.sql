-- 探索済み地図タイルテーブル
-- ユーザーが走行した地図タイルの情報を管理

CREATE TABLE explored_tiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    tile_x INTEGER NOT NULL,
    tile_y INTEGER NOT NULL,
    zoom_level INTEGER NOT NULL DEFAULT 16,
    first_explored_at TIMESTAMP WITH TIME ZONE NOT NULL,
    last_visited_at TIMESTAMP WITH TIME ZONE NOT NULL,
    visit_count INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, tile_x, tile_y, zoom_level)
);

-- インデックス作成
CREATE INDEX idx_explored_tiles_user_id ON explored_tiles(user_id);
CREATE INDEX idx_explored_tiles_coordinates ON explored_tiles(tile_x, tile_y, zoom_level);
CREATE INDEX idx_explored_tiles_first_explored ON explored_tiles(first_explored_at);
CREATE INDEX idx_explored_tiles_last_visited ON explored_tiles(last_visited_at);

-- 複合インデックス（効率的なクエリのため）
CREATE INDEX idx_explored_tiles_user_zoom ON explored_tiles(user_id, zoom_level);

-- Row Level Security (RLS) を有効化
ALTER TABLE explored_tiles ENABLE ROW LEVEL SECURITY;

-- RLSポリシー: ユーザーは自分の探索タイルのみ管理可能
CREATE POLICY "Users can manage own explored tiles" ON explored_tiles
    USING (auth.uid() = user_id);

-- RLSポリシー: ユーザーは自分の探索タイルのみ挿入可能
CREATE POLICY "Users can insert own explored tiles" ON explored_tiles
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 探索タイル統計を取得する関数
CREATE OR REPLACE FUNCTION get_exploration_stats(target_user_id UUID, target_zoom_level INTEGER DEFAULT 16)
RETURNS TABLE (
    total_tiles BIGINT,
    unique_tiles BIGINT,
    exploration_percentage NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*) as total_tiles,
        COUNT(DISTINCT (tile_x, tile_y)) as unique_tiles,
        ROUND(
            (COUNT(DISTINCT (tile_x, tile_y))::NUMERIC / NULLIF(COUNT(*), 0)) * 100, 
            2
        ) as exploration_percentage
    FROM explored_tiles 
    WHERE user_id = target_user_id 
    AND zoom_level = target_zoom_level;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;