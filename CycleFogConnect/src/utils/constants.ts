// アプリケーション定数

export const REGIONS = {
  DE: {
    name: 'Germany',
    code: 'DE',
    language: 'de',
    center: { latitude: 51.1657, longitude: 10.4515 },
  },
  FR: {
    name: 'France',
    code: 'FR',
    language: 'fr',
    center: { latitude: 46.2276, longitude: 2.2137 },
  },
  NL: {
    name: 'Netherlands',
    code: 'NL',
    language: 'nl',
    center: { latitude: 52.1326, longitude: 5.2913 },
  },
} as const;

export const CYCLING_LEVELS = {
  leisure: {
    name: 'Leisure',
    description: 'Casual cycling for enjoyment and fitness',
  },
  racer: {
    name: 'Racer',
    description: 'Competitive cycling with focus on speed and performance',
  },
} as const;

export const DIFFICULTY_LEVELS = {
  easy: {
    name: 'Easy',
    description: 'Suitable for beginners, flat terrain, short distance',
    color: '#4CAF50',
  },
  moderate: {
    name: 'Moderate',
    description: 'Some hills, medium distance, regular fitness required',
    color: '#FF9800',
  },
  hard: {
    name: 'Hard',
    description: 'Challenging terrain, long distance, high fitness required',
    color: '#F44336',
  },
} as const;

export const MAP_CONFIG = {
  DEFAULT_ZOOM: 16,
  MIN_ZOOM: 10,
  MAX_ZOOM: 18,
  TILE_SIZE: 256,
  PROXIMITY_THRESHOLD: 500, // メートル
  GPS_ACCURACY_THRESHOLD: 50, // メートル
} as const;

export const COLORS = {
  primary: '#2196F3',
  secondary: '#4CAF50',
  accent: '#FF5722',
  background: '#FAFAFA',
  surface: '#FFFFFF',
  error: '#F44336',
  warning: '#FF9800',
  success: '#4CAF50',
  text: {
    primary: '#212121',
    secondary: '#757575',
    disabled: '#BDBDBD',
  },
  fog: {
    explored: 'rgba(33, 150, 243, 0.3)', // 青色半透明
    unexplored: 'rgba(0, 0, 0, 0.1)', // グレー半透明
  },
} as const;