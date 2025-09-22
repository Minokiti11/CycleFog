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

// データベース型定義
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
          privacy_settings: {
            location_sharing: boolean;
            profile_public: boolean;
          };
          notification_settings: {
            proximity_alerts: boolean;
            challenge_updates: boolean;
          };
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
          privacy_settings?: {
            location_sharing: boolean;
            profile_public: boolean;
          };
          notification_settings?: {
            proximity_alerts: boolean;
            challenge_updates: boolean;
          };
        };
        Update: {
          display_name?: string;
          cycling_level?: 'leisure' | 'racer';
          region?: 'DE' | 'FR' | 'NL';
          preferred_language?: string;
          avatar_url?: string;
          bio?: string;
          privacy_settings?: {
            location_sharing: boolean;
            profile_public: boolean;
          };
          notification_settings?: {
            proximity_alerts: boolean;
            challenge_updates: boolean;
          };
          updated_at?: string;
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
          created_at: string;
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
          updated_at: string;
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
          updated_at: string;
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
      ride_participants: {
        Row: {
          ride_id: string;
          user_id: string;
          status: 'pending' | 'approved' | 'declined';
          joined_at: string;
          updated_at: string;
        };
        Insert: {
          ride_id: string;
          user_id: string;
          status?: 'pending' | 'approved' | 'declined';
        };
        Update: {
          status?: 'pending' | 'approved' | 'declined';
        };
      };
      ride_locations: {
        Row: {
          ride_id: string;
          user_id: string;
          location: any; // PostGIS POINT
          accuracy?: number;
          speed?: number;
          heading?: number;
          updated_at: string;
        };
        Insert: {
          ride_id: string;
          user_id: string;
          location: any;
          accuracy?: number;
          speed?: number;
          heading?: number;
        };
        Update: {
          location?: any;
          accuracy?: number;
          speed?: number;
          heading?: number;
        };
      };
      challenges: {
        Row: {
          id: string;
          created_by: string;
          type: 'exploration' | 'distance' | 'group_exploration';
          title: string;
          description?: string;
          target_value: number;
          current_value: number;
          start_date: string;
          end_date: string;
          status: 'active' | 'completed' | 'expired';
          region?: 'DE' | 'FR' | 'NL';
          difficulty?: 'easy' | 'moderate' | 'hard';
          reward_data?: any;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          created_by: string;
          type: 'exploration' | 'distance' | 'group_exploration';
          title: string;
          description?: string;
          target_value: number;
          start_date: string;
          end_date: string;
          region?: 'DE' | 'FR' | 'NL';
          difficulty?: 'easy' | 'moderate' | 'hard';
          reward_data?: any;
        };
        Update: {
          title?: string;
          description?: string;
          target_value?: number;
          current_value?: number;
          status?: 'active' | 'completed' | 'expired';
          difficulty?: 'easy' | 'moderate' | 'hard';
          reward_data?: any;
        };
      };
      challenge_participants: {
        Row: {
          challenge_id: string;
          user_id: string;
          joined_at: string;
          individual_progress: number;
          last_activity_at?: string;
        };
        Insert: {
          challenge_id: string;
          user_id: string;
          individual_progress?: number;
        };
        Update: {
          individual_progress?: number;
          last_activity_at?: string;
        };
      };
    };
    Functions: {
      get_exploration_stats: {
        Args: {
          target_user_id: string;
          target_zoom_level?: number;
        };
        Returns: {
          total_tiles: number;
          unique_tiles: number;
          exploration_percentage: number;
        }[];
      };
      get_user_cycling_stats: {
        Args: {
          target_user_id: string;
        };
        Returns: {
          total_tracks: number;
          total_distance: number;
          total_elevation_gain: number;
          average_distance: number;
          longest_ride: number;
          first_ride_date: string;
          last_ride_date: string;
        }[];
      };
      find_nearby_ride_events: {
        Args: {
          center_lat: number;
          center_lng: number;
          radius_km?: number;
          target_difficulty?: string;
        };
        Returns: {
          id: string;
          title: string;
          description: string;
          organizer_id: string;
          start_time: string;
          difficulty: string;
          max_participants: number;
          current_participants: number;
          distance_km: number;
        }[];
      };
      update_challenge_progress: {
        Args: {
          target_challenge_id: string;
          target_user_id: string;
          progress_increment: number;
        };
        Returns: void;
      };
    };
  };
}