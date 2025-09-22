import { create } from 'zustand';
import { User } from '../types';
import { supabase } from '../services/supabase';

interface AuthState {
  user: User | null;
  loading: boolean;
  signIn: (email: string, password: string) => Promise<void>;
  signUp: (email: string, password: string, userData: Partial<User>) => Promise<void>;
  signOut: () => Promise<void>;
  updateProfile: (updates: Partial<User>) => Promise<void>;
  initialize: () => Promise<void>;
}

export const useAuthStore = create<AuthState>((set, get) => ({
  user: null,
  loading: true,

  signIn: async (email: string, password: string) => {
    try {
      set({ loading: true });
      
      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password,
      });

      if (error) throw error;

      if (data.user) {
        // プロフィール情報を取得
        const { data: profile, error: profileError } = await supabase
          .from('profiles')
          .select('*')
          .eq('id', data.user.id)
          .single();

        if (profileError) throw profileError;

        const user: User = {
          id: profile.id,
          email: profile.email,
          displayName: profile.display_name,
          cyclingLevel: profile.cycling_level,
          region: profile.region,
          preferredLanguage: profile.preferred_language,
          avatarUrl: profile.avatar_url,
          bio: profile.bio,
          privacySettings: profile.privacy_settings,
          notificationSettings: profile.notification_settings,
          createdAt: new Date(profile.created_at),
          updatedAt: new Date(profile.updated_at),
        };

        set({ user, loading: false });
      }
    } catch (error) {
      console.error('Sign in error:', error);
      set({ loading: false });
      throw error;
    }
  },

  signUp: async (email: string, password: string, userData: Partial<User>) => {
    try {
      set({ loading: true });

      const { data, error } = await supabase.auth.signUp({
        email,
        password,
      });

      if (error) throw error;

      if (data.user) {
        // プロフィール作成
        const { error: profileError } = await supabase
          .from('profiles')
          .insert({
            id: data.user.id,
            email,
            display_name: userData.displayName || '',
            cycling_level: userData.cyclingLevel || 'leisure',
            region: userData.region || 'DE',
            preferred_language: userData.preferredLanguage || 'en',
            privacy_settings: userData.privacySettings || {
              locationSharing: false,
              profilePublic: true,
            },
            notification_settings: userData.notificationSettings || {
              proximityAlerts: true,
              challengeUpdates: true,
            },
          });

        if (profileError) throw profileError;
      }

      set({ loading: false });
    } catch (error) {
      console.error('Sign up error:', error);
      set({ loading: false });
      throw error;
    }
  },

  signOut: async () => {
    try {
      const { error } = await supabase.auth.signOut();
      if (error) throw error;
      set({ user: null });
    } catch (error) {
      console.error('Sign out error:', error);
      throw error;
    }
  },

  updateProfile: async (updates: Partial<User>) => {
    try {
      const { user } = get();
      if (!user) throw new Error('No user logged in');

      const { error } = await supabase
        .from('profiles')
        .update({
          display_name: updates.displayName,
          cycling_level: updates.cyclingLevel,
          region: updates.region,
          preferred_language: updates.preferredLanguage,
          avatar_url: updates.avatarUrl,
          bio: updates.bio,
          privacy_settings: updates.privacySettings,
          notification_settings: updates.notificationSettings,
          updated_at: new Date().toISOString(),
        })
        .eq('id', user.id);

      if (error) throw error;

      set({
        user: {
          ...user,
          ...updates,
          updatedAt: new Date(),
        },
      });
    } catch (error) {
      console.error('Update profile error:', error);
      throw error;
    }
  },

  initialize: async () => {
    try {
      set({ loading: true });

      const { data: { session } } = await supabase.auth.getSession();

      if (session?.user) {
        const { data: profile, error } = await supabase
          .from('profiles')
          .select('*')
          .eq('id', session.user.id)
          .single();

        if (error) throw error;

        const user: User = {
          id: profile.id,
          email: profile.email,
          displayName: profile.display_name,
          cyclingLevel: profile.cycling_level,
          region: profile.region,
          preferredLanguage: profile.preferred_language,
          avatarUrl: profile.avatar_url,
          bio: profile.bio,
          privacySettings: profile.privacy_settings,
          notificationSettings: profile.notification_settings,
          createdAt: new Date(profile.created_at),
          updatedAt: new Date(profile.updated_at),
        };

        set({ user, loading: false });
      } else {
        set({ user: null, loading: false });
      }
    } catch (error) {
      console.error('Initialize auth error:', error);
      set({ user: null, loading: false });
    }
  },
}));