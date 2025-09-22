import { createClient } from '@supabase/supabase-js';

// 環境変数（後で.envファイルから読み込み）
const SUPABASE_URL = process.env.EXPO_PUBLIC_SUPABASE_URL || '';
const SUPABASE_ANON_KEY = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY || '';

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  throw new Error('Supabase URL and Anon Key are required');
}

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
});

// データベース型定義（後でSupabaseから自動生成）
export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string;
          email: string;
          display_name: string;
          cycling_level: 'leisure' | 'racer';
          region: 'DE' | 'FR' | 'NL';
          preferred_language: string;
          avatar_url?: string;
          bio?: string;
          privacy_settings: any;
          notification_settings: any;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id: string;
          email: string;
          display_name: string;
          cycling_level: 'leisure' | 'racer';
          region: 'DE' | 'FR' | 'NL';
          preferred_language?: string;
          avatar_url?: string;
          bio?: string;
          privacy_settings?: any;
          notification_settings?: any;
        };
        Update: {
          display_name?: string;
          cycling_level?: 'leisure' | 'racer';
          region?: 'DE' | 'FR' | 'NL';
          preferred_language?: string;
          avatar_url?: string;
          bio?: string;
          privacy_settings?: any;
          notification_settings?: any;
          updated_at?: string;
        };
      };
      gps_tracks: {
        Row: {
          id: string;
          user_id: string;
          name?: string;
          start_time: string;
          end_time: string;
          total_distance: number;
          elevation_gain: number;
          track_data: any; // PostGIS GEOMETRY
          gpx_file_path?: string;
          created_at: string;
        };
        Insert: {
          user_id: string;
          name?: string;
          start_time: string;
          end_time: string;
          total_distance: number;
          elevation_gain: number;
          track_data: any;
          gpx_file_path?: string;
        };
        Update: {
          name?: string;
          total_distance?: number;
          elevation_gain?: number;
        };
      };
      explored_tiles: {
        Row: {
          id: string;
          user_id: string;
          tile_x: number;
          tile_y: number;
          zoom_level: number;
          first_explored_at: string;
          last_visited_at: string;
          visit_count: number;
        };
        Insert: {
          user_id: string;
          tile_x: number;
          tile_y: number;
          zoom_level?: number;
          first_explored_at: string;
          last_visited_at: string;
          visit_count?: number;
        };
        Update: {
          last_visited_at: string;
          visit_count: number;
        };
      };
      ride_events: {
        Row: {
          id: string;
          organizer_id: string;
          title: string;
          description?: string;
          start_location: any; // PostGIS POINT
          start_time: string;
          difficulty: 'easy' | 'moderate' | 'hard';
          max_participants: number;
          status: 'open' | 'full' | 'started' | 'completed' | 'cancelled';
          created_at: string;
        };
        Insert: {
          organizer_id: string;
          title: string;
          description?: string;
          start_location: any;
          start_time: string;
          difficulty: 'easy' | 'moderate' | 'hard';
          max_participants?: number;
          status?: 'open' | 'full' | 'started' | 'completed' | 'cancelled';
        };
        Update: {
          title?: string;
          description?: string;
          start_time?: string;
          difficulty?: 'easy' | 'moderate' | 'hard';
          max_participants?: number;
          status?: 'open' | 'full' | 'started' | 'completed' | 'cancelled';
        };
      };
    };
  };
}