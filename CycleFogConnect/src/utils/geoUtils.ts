import { GPSPoint, TileCoordinate, BoundingBox } from '../types';

/**
 * 2点間の距離を計算（Haversine公式）
 */
export function calculateDistance(
  point1: { latitude: number; longitude: number },
  point2: { latitude: number; longitude: number }
): number {
  const R = 6371000; // 地球の半径（メートル）
  const φ1 = (point1.latitude * Math.PI) / 180;
  const φ2 = (point2.latitude * Math.PI) / 180;
  const Δφ = ((point2.latitude - point1.latitude) * Math.PI) / 180;
  const Δλ = ((point2.longitude - point1.longitude) * Math.PI) / 180;

  const a =
    Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
    Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  return R * c;
}

/**
 * GPSポイントの配列から総距離を計算
 */
export function calculateTotalDistance(points: GPSPoint[]): number {
  if (points.length < 2) return 0;

  let totalDistance = 0;
  for (let i = 1; i < points.length; i++) {
    totalDistance += calculateDistance(points[i - 1], points[i]);
  }

  return totalDistance;
}

/**
 * GPSポイントの配列から標高獲得を計算
 */
export function calculateElevationGain(points: GPSPoint[]): number {
  if (points.length < 2) return 0;

  let totalGain = 0;
  for (let i = 1; i < points.length; i++) {
    const prevAltitude = points[i - 1].altitude || 0;
    const currentAltitude = points[i].altitude || 0;
    const gain = currentAltitude - prevAltitude;
    if (gain > 0) {
      totalGain += gain;
    }
  }

  return totalGain;
}

/**
 * 緯度経度をタイル座標に変換
 */
export function latLngToTile(
  latitude: number,
  longitude: number,
  zoom: number
): TileCoordinate {
  const n = Math.pow(2, zoom);
  const x = Math.floor(((longitude + 180) / 360) * n);
  const y = Math.floor(
    ((1 - Math.log(Math.tan((latitude * Math.PI) / 180) + 1 / Math.cos((latitude * Math.PI) / 180)) / Math.PI) / 2) * n
  );

  return { x, y, z: zoom };
}

/**
 * タイル座標を緯度経度に変換
 */
export function tileToLatLng(x: number, y: number, zoom: number): { latitude: number; longitude: number } {
  const n = Math.pow(2, zoom);
  const longitude = (x / n) * 360 - 180;
  const latitude = (Math.atan(Math.sinh(Math.PI * (1 - (2 * y) / n))) * 180) / Math.PI;

  return { latitude, longitude };
}

/**
 * GPSトラックから通過したタイルを取得
 */
export function getTrackTiles(points: GPSPoint[], zoom: number = 16): TileCoordinate[] {
  const tiles = new Set<string>();
  const tileCoordinates: TileCoordinate[] = [];

  points.forEach(point => {
    const tile = latLngToTile(point.latitude, point.longitude, zoom);
    const tileKey = `${tile.x},${tile.y},${tile.z}`;
    
    if (!tiles.has(tileKey)) {
      tiles.add(tileKey);
      tileCoordinates.push(tile);
    }
  });

  return tileCoordinates;
}

/**
 * バウンディングボックス内のタイル数を計算
 */
export function getTilesInBounds(bounds: BoundingBox, zoom: number): TileCoordinate[] {
  const topLeft = latLngToTile(bounds.north, bounds.west, zoom);
  const bottomRight = latLngToTile(bounds.south, bounds.east, zoom);

  const tiles: TileCoordinate[] = [];

  for (let x = topLeft.x; x <= bottomRight.x; x++) {
    for (let y = topLeft.y; y <= bottomRight.y; y++) {
      tiles.push({ x, y, z: zoom });
    }
  }

  return tiles;
}

/**
 * 2つの地点が指定距離内にあるかチェック
 */
export function isWithinDistance(
  point1: { latitude: number; longitude: number },
  point2: { latitude: number; longitude: number },
  maxDistance: number
): boolean {
  return calculateDistance(point1, point2) <= maxDistance;
}

/**
 * GPSポイントの精度をチェック
 */
export function isAccurateGPSPoint(point: GPSPoint, minAccuracy: number = 50): boolean {
  return point.accuracy ? point.accuracy <= minAccuracy : true;
}

/**
 * GPSトラックをフィルタリング（精度の低いポイントを除去）
 */
export function filterAccuratePoints(points: GPSPoint[], minAccuracy: number = 50): GPSPoint[] {
  return points.filter(point => isAccurateGPSPoint(point, minAccuracy));
}