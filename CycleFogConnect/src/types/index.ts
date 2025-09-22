// 基本的な型定義

export interface User {
  id: string;
  email: string;
  displayName: string;
  cyclingLevel: 'leisure' | 'racer';
  region: 'DE' | 'FR' | 'NL';
  preferredLanguage: 'en' | 'de' | 'fr' | 'nl';
  avatarUrl?: string;
  bio?: string;
  privacySettings: {
    locationSharing: boolean;
    profilePublic: boolean;
  };
  notificationSettings: {
    proximityAlerts: boolean;
    challengeUpdates: boolean;
  };
  createdAt: Date;
  updatedAt: Date;
}

export interface GPSPoint {
  latitude: number;
  longitude: number;
  altitude?: number;
  timestamp: Date;
  accuracy?: number;
}

export interface GPSTrack {
  id: string;
  userId: string;
  name?: string;
  points: GPSPoint[];
  startTime: Date;
  endTime: Date;
  totalDistance: number; // メートル
  elevationGain: number; // メートル
  createdAt: Date;
}

export interface TileCoordinate {
  x: number;
  y: number;
  z: number; // zoom level
}

export interface TileStatus {
  id: string;
  userId: string;
  tileX: number;
  tileY: number;
  zoomLevel: number;
  firstExploredAt: Date;
  lastVisitedAt: Date;
  visitCount: number;
}

export interface RideEvent {
  id: string;
  organizerId: string;
  title: string;
  description?: string;
  startLocation: {
    latitude: number;
    longitude: number;
  };
  startTime: Date;
  difficulty: 'easy' | 'moderate' | 'hard';
  maxParticipants: number;
  status: 'open' | 'full' | 'started' | 'completed' | 'cancelled';
  createdAt: Date;
}

export interface RideParticipant {
  rideId: string;
  userId: string;
  status: 'pending' | 'approved' | 'declined';
  joinedAt: Date;
}

export interface Challenge {
  id: string;
  type: 'exploration' | 'distance' | 'group_exploration';
  title: string;
  description: string;
  targetValue: number;
  currentValue: number;
  startDate: Date;
  endDate: Date;
  participants: string[];
  createdBy: string;
  status: 'active' | 'completed' | 'expired';
}

export interface GeoLocation {
  latitude: number;
  longitude: number;
}

export interface BoundingBox {
  north: number;
  south: number;
  east: number;
  west: number;
}