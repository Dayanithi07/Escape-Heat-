import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";
import type { RiskLevel } from "@/types";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function getRiskColor(level: RiskLevel): string {
  const colors: Record<RiskLevel, string> = {
    low: "#22c55e",
    moderate: "#eab308",
    high: "#f97316",
    extreme: "#ef4444",
  };
  return colors[level];
}

export function getRiskBgClass(level: RiskLevel): string {
  const classes: Record<RiskLevel, string> = {
    low: "bg-green-500/10 text-green-400 border-green-500/20",
    moderate: "bg-yellow-500/10 text-yellow-400 border-yellow-500/20",
    high: "bg-orange-500/10 text-orange-400 border-orange-500/20",
    extreme: "bg-red-500/10 text-red-400 border-red-500/20",
  };
  return classes[level];
}

export function getRiskLabel(level: RiskLevel): string {
  const labels: Record<RiskLevel, string> = {
    low: "Low Risk",
    moderate: "Moderate Risk",
    high: "High Risk",
    extreme: "Extreme Risk",
  };
  return labels[level];
}

export function getAQICategory(aqi: number): { label: string; color: string } {
  if (aqi <= 50) return { label: "Good", color: "#22c55e" };
  if (aqi <= 100) return { label: "Moderate", color: "#eab308" };
  if (aqi <= 150) return { label: "Unhealthy for Sensitive Groups", color: "#f97316" };
  if (aqi <= 200) return { label: "Unhealthy", color: "#ef4444" };
  if (aqi <= 300) return { label: "Very Unhealthy", color: "#a855f7" };
  return { label: "Hazardous", color: "#7f1d1d" };
}

export function formatTemperature(
  value: number,
  unit: "celsius" | "fahrenheit" = "celsius"
): string {
  if (unit === "fahrenheit") {
    return `${Math.round((value * 9) / 5 + 32)}°F`;
  }
  return `${Math.round(value)}°C`;
}

export function formatTime(timestamp: string): string {
  return new Date(timestamp).toLocaleTimeString("en-IN", {
    hour: "2-digit",
    minute: "2-digit",
    hour12: true,
  });
}

export function formatDate(timestamp: string): string {
  return new Date(timestamp).toLocaleDateString("en-IN", {
    day: "numeric",
    month: "short",
    year: "numeric",
  });
}

export function generateId(): string {
  return Math.random().toString(36).substring(2, 11);
}

export function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

export function getUVCategory(uv: number): { label: string; color: string } {
  if (uv <= 2) return { label: "Low", color: "#22c55e" };
  if (uv <= 5) return { label: "Moderate", color: "#eab308" };
  if (uv <= 7) return { label: "High", color: "#f97316" };
  if (uv <= 10) return { label: "Very High", color: "#ef4444" };
  return { label: "Extreme", color: "#7f1d1d" };
}

export function getPOIIcon(category: string): string {
  const icons: Record<string, string> = {
    park: "🌳",
    hospital: "🏥",
    cooling_center: "❄️",
    water_station: "💧",
    shelter: "🏠",
  };
  return icons[category] ?? "📍";
}
