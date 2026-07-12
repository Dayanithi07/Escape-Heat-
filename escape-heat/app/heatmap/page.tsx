"use client";

import AppShell from "@/components/layout/AppShell";
import dynamic from "next/dynamic";
import { pointsOfInterest } from "@/lib/mock-data/heatmap";
import { getPOIIcon } from "@/lib/utils";
import { MapPin, Info } from "lucide-react";

const HeatMapContainer = dynamic(
  () => import("@/components/map/HeatMapContainer"),
  { ssr: false, loading: () => (
    <div className="flex items-center justify-center h-full bg-[var(--bg-secondary)] rounded-2xl">
      <div className="text-center">
        <div className="w-10 h-10 border-2 border-orange-500 border-t-transparent rounded-full animate-spin mx-auto mb-3" />
        <p className="text-sm text-[var(--text-muted)]">Loading map...</p>
      </div>
    </div>
  )}
);

export default function HeatmapPage() {
  const nearbyOpen = pointsOfInterest.filter((p) => p.isOpen).slice(0, 5);

  return (
    <AppShell>
      <div className="flex flex-col h-[calc(100vh-5rem)] gap-4">
        {/* Header */}
        <div className="flex items-center justify-between flex-shrink-0">
          <div>
            <h1 className="font-display font-bold text-2xl text-[var(--text-primary)]">
              Interactive Heat Map
            </h1>
            <p className="text-sm text-[var(--text-muted)] flex items-center gap-1 mt-0.5">
              <MapPin className="w-3.5 h-3.5 text-orange-500" />
              Chennai Metropolitan Area · Live heat zone data
            </p>
          </div>
          <div className="flex items-center gap-2 px-3 py-1.5 rounded-xl bg-blue-500/10 border border-blue-500/20 text-blue-400 text-xs font-medium">
            <Info className="w-3.5 h-3.5" />
            Zoom in for detail
          </div>
        </div>

        <div className="flex flex-1 gap-4 min-h-0">
          {/* Map */}
          <div className="flex-1 min-h-0">
            <HeatMapContainer />
          </div>

          {/* Sidebar: Nearby POIs */}
          <div className="hidden xl:flex flex-col w-72 gap-3 overflow-y-auto no-scrollbar">
            <div className="card p-4 flex-shrink-0">
              <p className="text-xs font-semibold text-[var(--text-muted)] uppercase tracking-wide mb-3">
                Nearest Open Locations
              </p>
              <div className="space-y-3">
                {nearbyOpen.map((poi) => (
                  <div key={poi.id} className="flex items-start gap-3">
                    <span className="text-lg flex-shrink-0">{getPOIIcon(poi.category)}</span>
                    <div className="min-w-0">
                      <p className="text-xs font-semibold text-[var(--text-primary)] truncate">
                        {poi.name}
                      </p>
                      <p className="text-[10px] text-[var(--text-muted)] truncate mt-0.5">
                        {poi.address}
                      </p>
                      <div className="flex items-center gap-2 mt-1">
                        <span className="text-[10px] font-medium text-green-400">
                          ● Open
                        </span>
                        <span className="text-[10px] text-[var(--text-muted)]">
                          {poi.distance} km
                        </span>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Heat Zone Alert */}
            <div className="card p-4 bg-red-500/5 border-red-500/20 flex-shrink-0">
              <p className="text-xs font-semibold text-red-400 mb-2">🔥 Extreme Heat Zones</p>
              <p className="text-xs text-[var(--text-secondary)]">
                T. Nagar and Guindy Industrial Estate are showing extreme heat conditions (42–43°C).
                Avoid these areas between 11 AM – 4 PM.
              </p>
            </div>

            {/* Category Legend */}
            <div className="card p-4 flex-shrink-0">
              <p className="text-xs font-semibold text-[var(--text-muted)] uppercase tracking-wide mb-3">
                Map Legend
              </p>
              {[
                { icon: "🌳", label: "Parks & Green Spaces", color: "#22c55e" },
                { icon: "🏥", label: "Hospitals", color: "#ef4444" },
                { icon: "❄️", label: "Cooling Centers", color: "#3b82f6" },
                { icon: "💧", label: "Water Stations", color: "#06b6d4" },
              ].map((item) => (
                <div key={item.label} className="flex items-center gap-2 mb-2 last:mb-0">
                  <span className="text-base">{item.icon}</span>
                  <div className="flex-1">
                    <span className="text-xs text-[var(--text-secondary)]">{item.label}</span>
                  </div>
                  <span className="w-2.5 h-2.5 rounded-full" style={{ backgroundColor: item.color }} />
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </AppShell>
  );
}
