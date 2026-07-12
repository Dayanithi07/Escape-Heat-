"use client";

import { useState } from "react";
import AppShell from "@/components/layout/AppShell";
import RiskIndicator from "@/components/ui/RiskIndicator";
import StatCard from "@/components/ui/StatCard";
import RiskBadge from "@/components/ui/RiskBadge";
import TemperatureChart from "@/components/charts/TemperatureChart";
import HumidityChart from "@/components/charts/HumidityChart";
import RiskTrendChart from "@/components/charts/RiskTrendChart";
import LoadingSkeleton from "@/components/ui/LoadingSkeleton";
import { currentWeather, weeklyTrend } from "@/lib/mock-data/weather";
import { MapPin, Clock, Thermometer, Droplets, Wind, Sun, Cloud, Eye, RefreshCw } from "lucide-react";
import { cn } from "@/lib/utils";

const statItems = [
  {
    label: "Temperature",
    value: currentWeather.temperature,
    unit: "°C",
    icon: <Thermometer className="w-4 h-4" />,
    trend: "up" as const,
    trendValue: "+3°C from yesterday",
    description: "Dangerously high",
    color: "#ef4444",
  },
  {
    label: "Feels Like",
    value: currentWeather.feelsLike,
    unit: "°C",
    icon: "🌡️",
    trend: "up" as const,
    trendValue: "Heat index elevated",
    description: `Heat Index: ${currentWeather.heatIndex}°C`,
    color: "#f97316",
  },
  {
    label: "Humidity",
    value: currentWeather.humidity,
    unit: "%",
    icon: <Droplets className="w-4 h-4" />,
    trend: "stable" as const,
    trendValue: "High relative humidity",
    description: `Dew point: ${currentWeather.dewPoint}°C`,
    color: "#3b82f6",
  },
  {
    label: "UV Index",
    value: currentWeather.uvIndex,
    unit: "",
    icon: <Sun className="w-4 h-4" />,
    trend: "up" as const,
    trendValue: "Very High — protection needed",
    description: "Sunburn in 15 min",
    color: "#eab308",
  },
  {
    label: "Wind Speed",
    value: currentWeather.windSpeed,
    unit: "km/h",
    icon: <Wind className="w-4 h-4" />,
    trend: "stable" as const,
    trendValue: `Direction: ${currentWeather.windDirection}`,
    description: "Light breeze",
    color: "#06b6d4",
  },
  {
    label: "Air Quality",
    value: currentWeather.aqi,
    unit: "AQI",
    icon: <Cloud className="w-4 h-4" />,
    trend: "down" as const,
    trendValue: currentWeather.aqiCategory,
    description: "Sensitive groups affected",
    color: "#a855f7",
  },
];

export default function DashboardPage() {
  const [isLoading, setIsLoading] = useState(false);

  const handleRefresh = () => {
    setIsLoading(true);
    setTimeout(() => {
      setIsLoading(false);
    }, 850);
  };

  const now = new Date();
  const timeStr = now.toLocaleTimeString("en-IN", {
    hour: "2-digit",
    minute: "2-digit",
    hour12: true,
  });
  const dateStr = now.toLocaleDateString("en-IN", {
    weekday: "long",
    day: "numeric",
    month: "long",
    year: "numeric",
  });

  return (
    <AppShell>
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
        <div>
          <div className="flex items-center gap-2 text-sm text-[var(--text-muted)] mb-1">
            <MapPin className="w-3.5 h-3.5 text-orange-500" />
            <span>{currentWeather.location.city}, {currentWeather.location.state}</span>
            <span>·</span>
            <Clock className="w-3.5 h-3.5" />
            <span>{timeStr} · {dateStr}</span>
          </div>
          <h1 className="font-display font-bold text-2xl text-[var(--text-primary)]">
            Heat Dashboard
          </h1>
        </div>
        <div className="flex items-center gap-3">
          <button
            onClick={handleRefresh}
            disabled={isLoading}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-semibold bg-[var(--bg-card)] border border-[var(--border-primary)] text-[var(--text-secondary)] hover:border-orange-500/50 hover:text-orange-400 transition-all disabled:opacity-50"
            title="Refresh dashboard stats"
          >
            <RefreshCw className={cn("w-3.5 h-3.5", isLoading && "animate-spin")} />
            Refresh
          </button>
          <RiskBadge level={currentWeather.riskLevel} score={currentWeather.riskScore} showScore pulse />
          <span className="text-sm text-[var(--text-muted)]">
            {currentWeather.conditionIcon} {currentWeather.condition}
          </span>
        </div>
      </div>

      {/* Main Grid */}
      <div className="grid lg:grid-cols-3 gap-5">
        {/* Left: Risk Gauge + Quick Info */}
        <div className="lg:col-span-1 flex flex-col gap-4">
          {/* Risk Gauge Card */}
          <div className="card p-6 flex flex-col items-center text-center">
            <p className="text-xs font-medium text-[var(--text-muted)] uppercase tracking-wide mb-4">
              Current Heat Risk Score
            </p>
            {isLoading ? (
              <div className="w-36 h-36 rounded-full shimmer-effect flex items-center justify-center mb-2" />
            ) : (
              <RiskIndicator
                score={currentWeather.riskScore}
                level={currentWeather.riskLevel}
                size="lg"
              />
            )}
            <div className="mt-4 text-xs text-[var(--text-secondary)] max-w-[220px]">
              Heat conditions are dangerous. Minimize outdoor exposure between 10 AM – 5 PM.
            </div>
          </div>

          {/* Visibility + Pressure */}
          <div className="grid grid-cols-2 gap-3">
            {isLoading ? (
              <>
                <div className="card p-4 space-y-2">
                  <div className="h-4 w-12 bg-[var(--bg-tertiary)] rounded shimmer-effect mx-auto" />
                  <div className="h-6 w-16 bg-[var(--bg-tertiary)] rounded shimmer-effect mx-auto" />
                </div>
                <div className="card p-4 space-y-2">
                  <div className="h-4 w-12 bg-[var(--bg-tertiary)] rounded shimmer-effect mx-auto" />
                  <div className="h-6 w-16 bg-[var(--bg-tertiary)] rounded shimmer-effect mx-auto" />
                </div>
              </>
            ) : (
              <>
                <div className="card p-4 text-center">
                  <Eye className="w-5 h-5 text-[var(--text-muted)] mx-auto mb-2" />
                  <p className="text-xl font-bold font-display text-[var(--text-primary)]">
                    {currentWeather.visibility}
                  </p>
                  <p className="text-[10px] text-[var(--text-muted)] mt-0.5">Visibility (km)</p>
                </div>
                <div className="card p-4 text-center">
                  <span className="text-xl block mb-1">⏱️</span>
                  <p className="text-xl font-bold font-display text-[var(--text-primary)]">
                    {currentWeather.pressure}
                  </p>
                  <p className="text-[10px] text-[var(--text-muted)] mt-0.5">Pressure (hPa)</p>
                </div>
              </>
            )}
          </div>

          {/* Weekly Summary */}
          <div className="card p-4">
            <p className="text-xs font-semibold text-[var(--text-muted)] uppercase tracking-wide mb-3">
              7-Day Overview
            </p>
            {isLoading ? (
              <div className="space-y-3">
                {Array.from({ length: 7 }).map((_, i) => (
                  <div key={i} className="h-4 bg-[var(--bg-tertiary)] rounded shimmer-effect" />
                ))}
              </div>
            ) : (
              <div className="space-y-2">
                {weeklyTrend.map((day) => (
                  <div key={day.day} className="flex items-center justify-between text-xs">
                    <span className="text-[var(--text-secondary)] w-8">{day.day}</span>
                    <span className="text-[var(--text-muted)] flex-1 text-center">{day.date}</span>
                    <div className="flex items-center gap-2">
                      <span className="text-[var(--text-primary)] font-medium">{day.maxTemp}°</span>
                      <RiskBadge level={day.riskLevel} size="sm" />
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>

        {/* Right: Stats + Charts */}
        <div className="lg:col-span-2 flex flex-col gap-4">
          {/* Stat Cards */}
          <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
            {isLoading
              ? Array.from({ length: 6 }).map((_, i) => (
                  <div key={i} className="card p-4 space-y-3">
                    <div className="h-3 w-16 bg-[var(--bg-tertiary)] rounded shimmer-effect" />
                    <div className="h-8 w-24 bg-[var(--bg-tertiary)] rounded shimmer-effect" />
                    <div className="h-3 w-20 bg-[var(--bg-tertiary)] rounded shimmer-effect" />
                  </div>
                ))
              : statItems.map((stat) => (
                  <StatCard
                    key={stat.label}
                    label={stat.label}
                    value={stat.value}
                    unit={stat.unit}
                    icon={typeof stat.icon === "string" ? <span className="text-base">{stat.icon}</span> : stat.icon}
                    trend={stat.trend}
                    trendValue={stat.trendValue}
                    description={stat.description}
                    accentColor={stat.color}
                    className="relative overflow-hidden"
                  />
                ))}
          </div>

          {/* Temperature Chart */}
          {isLoading ? (
            <LoadingSkeleton variant="chart" className="h-[288px]" />
          ) : (
            <TemperatureChart height={220} />
          )}

          {/* Bottom Row Charts */}
          <div className="grid sm:grid-cols-2 gap-4">
            {isLoading ? (
              <>
                <LoadingSkeleton variant="chart" className="h-[248px]" />
                <LoadingSkeleton variant="chart" className="h-[248px]" />
              </>
            ) : (
              <>
                <HumidityChart height={180} />
                <RiskTrendChart height={180} />
              </>
            )}
          </div>
        </div>
      </div>

      {/* Safe/Unsafe Hours Banner */}
      <div className="mt-5 card p-4">
        <p className="text-xs font-semibold text-[var(--text-muted)] uppercase tracking-wide mb-3">
          Today&apos;s Activity Windows
        </p>
        <div className="grid grid-cols-3 gap-3 text-center text-sm">
          <div className="rounded-xl p-3 bg-green-500/10 border border-green-500/20">
            <p className="font-bold text-green-400">✅ Safe</p>
            <p className="text-xs text-green-300 mt-1">Before 9 AM</p>
            <p className="text-[10px] text-[var(--text-muted)] mt-0.5">Risk ~25/100</p>
          </div>
          <div className="rounded-xl p-3 bg-orange-500/10 border border-orange-500/20">
            <p className="font-bold text-orange-400">⚠️ Caution</p>
            <p className="text-xs text-orange-300 mt-1">9 AM – 12 PM</p>
            <p className="text-[10px] text-[var(--text-muted)] mt-0.5">Risk 48–78/100</p>
          </div>
          <div className="rounded-xl p-3 bg-red-500/10 border border-red-500/20">
            <p className="font-bold text-red-400">🚫 Avoid</p>
            <p className="text-xs text-red-300 mt-1">12 PM – 5 PM</p>
            <p className="text-[10px] text-[var(--text-muted)] mt-0.5">Risk 84–88/100</p>
          </div>
        </div>
      </div>
    </AppShell>
  );
}
