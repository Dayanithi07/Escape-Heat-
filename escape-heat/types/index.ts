// ================================================================
// Escape Heat — TypeScript Type Definitions
// ================================================================

// ─── Risk Levels ────────────────────────────────────────────────
export type RiskLevel = "low" | "moderate" | "high" | "extreme";

export interface RiskInfo {
  level: RiskLevel;
  score: number; // 0–100
  label: string;
  color: string;
  bgColor: string;
  description: string;
}

// ─── Weather ────────────────────────────────────────────────────
export interface WeatherCondition {
  id: string;
  timestamp: string;
  location: LocationInfo;
  temperature: number; // °C
  feelsLike: number;
  humidity: number; // %
  uvIndex: number;
  windSpeed: number; // km/h
  windDirection: string;
  aqi: number; // Air Quality Index
  aqiCategory: string;
  visibility: number; // km
  dewPoint: number;
  heatIndex: number;
  cloudCover: number; // %
  pressure: number; // hPa
  condition: string;
  conditionIcon: string;
  riskScore: number;
  riskLevel: RiskLevel;
}

export interface HourlyData {
  hour: string;
  temperature: number;
  feelsLike: number;
  humidity: number;
  uvIndex: number;
  riskScore: number;
}

export interface DailyTrend {
  day: string;
  date: string;
  maxTemp: number;
  minTemp: number;
  avgHumidity: number;
  maxUV: number;
  riskLevel: RiskLevel;
  riskScore: number;
}

// ─── Location ───────────────────────────────────────────────────
export interface LocationInfo {
  city: string;
  district: string;
  state: string;
  country: string;
  lat: number;
  lng: number;
}

// ─── Heat Map ───────────────────────────────────────────────────
export type HeatZoneIntensity = "low" | "moderate" | "high" | "extreme";

export interface HeatZone {
  id: string;
  name: string;
  lat: number;
  lng: number;
  radius: number; // meters
  intensity: HeatZoneIntensity;
  temperature: number;
  description: string;
}

export type POICategory =
  | "park"
  | "hospital"
  | "cooling_center"
  | "water_station"
  | "shelter";

export interface PointOfInterest {
  id: string;
  name: string;
  category: POICategory;
  lat: number;
  lng: number;
  address: string;
  isOpen: boolean;
  distance: number; // km from user
  description?: string;
}

// ─── Recommendations ────────────────────────────────────────────
export type RecommendationCategory =
  | "hydration"
  | "activity"
  | "clothing"
  | "health"
  | "travel"
  | "timing";

export type RecommendationPriority = "urgent" | "important" | "advisory";

export interface Recommendation {
  id: string;
  category: RecommendationCategory;
  title: string;
  description: string;
  priority: RecommendationPriority;
  icon: string;
  actionItems: string[];
  validUntil?: string;
  riskLevel: RiskLevel;
}

// ─── Chat ────────────────────────────────────────────────────────
export type MessageRole = "user" | "assistant";

export interface ChatMessage {
  id: string;
  role: MessageRole;
  content: string;
  timestamp: string;
  isTyping?: boolean;
}

export interface QuickPrompt {
  id: string;
  label: string;
  prompt: string;
  icon: string;
}

// ─── Profile ─────────────────────────────────────────────────────
export type HealthCategory =
  | "healthy"
  | "vulnerable"
  | "elderly"
  | "outdoor_worker";

export interface UserProfile {
  id: string;
  name: string;
  email: string;
  avatar: string;
  age: number;
  occupation: string;
  healthCategory: HealthCategory;
  medicalConditions: string[];
  location: LocationInfo;
  savedLocations: LocationInfo[];
  temperatureUnit: "celsius" | "fahrenheit";
  notificationsEnabled: boolean;
  alertThreshold: RiskLevel;
  joinedDate: string;
}

// ─── Stats ───────────────────────────────────────────────────────
export interface StatCardData {
  label: string;
  value: string | number;
  unit?: string;
  icon: string;
  trend?: "up" | "down" | "stable";
  trendValue?: string;
  description?: string;
  color?: string;
}

// ─── Navigation ─────────────────────────────────────────────────
export interface NavItem {
  label: string;
  href: string;
  icon: string;
  badge?: string | number;
}
