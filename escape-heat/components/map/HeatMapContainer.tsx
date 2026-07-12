"use client";

import { useEffect, useState } from "react";
import { heatZones, pointsOfInterest, mapCenter } from "@/lib/mock-data/heatmap";
import { getRiskColor, getPOIIcon } from "@/lib/utils";
import type { POICategory, HeatZoneIntensity } from "@/types";

const intensityToRisk: Record<HeatZoneIntensity, "low" | "moderate" | "high" | "extreme"> = {
  low: "low",
  moderate: "moderate",
  high: "high",
  extreme: "extreme",
};

const poiColors: Record<POICategory, string> = {
  park: "#22c55e",
  hospital: "#ef4444",
  cooling_center: "#3b82f6",
  water_station: "#06b6d4",
  shelter: "#a855f7",
};

type FilterCategory = "all" | POICategory;

type LeafletModule = typeof import("leaflet");

interface MapRefs {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  MapContainer: any;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  TileLayer: any;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  Circle: any;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  Marker: any;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  Popup: any;
  L: LeafletModule;
}

export default function HeatMapContainer() {
  const [mapRefs, setMapRefs] = useState<MapRefs | null>(null);
  const [activeFilter, setActiveFilter] = useState<FilterCategory>("all");
  const [showHeatZones, setShowHeatZones] = useState(true);

  useEffect(() => {
    // Dynamically import leaflet and react-leaflet (client only)
    Promise.all([import("react-leaflet"), import("leaflet")]).then(([rl, leaflet]) => {
      const L = leaflet.default;
      // Fix default icon paths
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      delete (L.Icon.Default.prototype as any)._getIconUrl;
      L.Icon.Default.mergeOptions({
        iconRetinaUrl: "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png",
        iconUrl: "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png",
        shadowUrl: "https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png",
      });
      setMapRefs({
        MapContainer: rl.MapContainer,
        TileLayer: rl.TileLayer,
        Circle: rl.Circle,
        Marker: rl.Marker,
        Popup: rl.Popup,
        L,
      });
    });

    // Load Leaflet CSS
    const link = document.createElement("link");
    link.rel = "stylesheet";
    link.href = "https://unpkg.com/leaflet@1.9.4/dist/leaflet.css";
    document.head.appendChild(link);
    return () => { document.head.removeChild(link); };
  }, []);

  const filteredPOIs =
    activeFilter === "all"
      ? pointsOfInterest
      : pointsOfInterest.filter((p) => p.category === activeFilter);

  const filterButtons: { id: FilterCategory; label: string; icon: string }[] = [
    { id: "all", label: "All", icon: "🗺️" },
    { id: "park", label: "Parks", icon: "🌳" },
    { id: "hospital", label: "Hospitals", icon: "🏥" },
    { id: "cooling_center", label: "Cooling", icon: "❄️" },
    { id: "water_station", label: "Water", icon: "💧" },
  ];

  if (!mapRefs) {
    return (
      <div className="flex flex-col h-full gap-3">
        <div className="flex items-center gap-2 flex-wrap h-10 animate-pulse">
          {filterButtons.map((b) => (
            <div key={b.id} className="h-8 w-20 rounded-xl bg-[var(--bg-tertiary)]" />
          ))}
        </div>
        <div className="flex-1 rounded-2xl bg-[var(--bg-secondary)] border border-[var(--border-primary)] flex items-center justify-center">
          <div className="text-center">
            <div className="w-10 h-10 border-2 border-orange-500 border-t-transparent rounded-full animate-spin mx-auto mb-3" />
            <p className="text-sm text-[var(--text-muted)]">Loading map...</p>
          </div>
        </div>
      </div>
    );
  }

  const { MapContainer, TileLayer, Circle, Marker, Popup, L } = mapRefs;

  const createPOIIcon = (category: POICategory) =>
    L.divIcon({
      html: `<div style="width:32px;height:32px;background:${
        poiColors[category]
      };border:3px solid white;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:14px;box-shadow:0 2px 8px rgba(0,0,0,0.3)">${getPOIIcon(
        category
      )}</div>`,
      className: "",
      iconSize: [32, 32],
      iconAnchor: [16, 16],
    });

  return (
    <div className="flex flex-col h-full gap-3">
      {/* Filter Bar */}
      <div className="flex items-center gap-2 flex-wrap flex-shrink-0">
        {filterButtons.map((btn) => (
          <button
            key={btn.id}
            onClick={() => setActiveFilter(btn.id)}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-semibold border transition-all ${
              activeFilter === btn.id
                ? "bg-orange-500 text-white border-orange-500"
                : "bg-[var(--bg-card)] text-[var(--text-secondary)] border-[var(--border-primary)] hover:border-orange-500/50"
            }`}
          >
            <span>{btn.icon}</span>
            {btn.label}
          </button>
        ))}
        <button
          onClick={() => setShowHeatZones(!showHeatZones)}
          className={`flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-semibold border transition-all ml-auto ${
            showHeatZones
              ? "bg-red-500/10 text-red-400 border-red-500/30"
              : "bg-[var(--bg-card)] text-[var(--text-secondary)] border-[var(--border-primary)]"
          }`}
        >
          🔥 Heat Zones
        </button>
      </div>

      {/* Map */}
      <div className="flex-1 rounded-2xl overflow-hidden border border-[var(--border-primary)] min-h-0">
        <MapContainer
          center={mapCenter}
          zoom={12}
          style={{ height: "100%", width: "100%" }}
        >
          <TileLayer
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          />

          {showHeatZones &&
            heatZones.map((zone) => (
              <Circle
                key={zone.id}
                center={[zone.lat, zone.lng]}
                radius={zone.radius}
                pathOptions={{
                  color: getRiskColor(intensityToRisk[zone.intensity]),
                  fillColor: getRiskColor(intensityToRisk[zone.intensity]),
                  fillOpacity: 0.25,
                  weight: 2,
                }}
              >
                <Popup>
                  <div style={{ padding: "4px", maxWidth: "220px" }}>
                    <p style={{ fontWeight: 600, fontSize: "13px", marginBottom: "4px" }}>{zone.name}</p>
                    <p style={{ fontSize: "11px", color: "#666", marginBottom: "4px" }}>{zone.description}</p>
                    <p style={{ fontSize: "11px", fontWeight: 600, color: getRiskColor(intensityToRisk[zone.intensity]) }}>
                      {zone.temperature}°C · {zone.intensity.toUpperCase()}
                    </p>
                  </div>
                </Popup>
              </Circle>
            ))}

          {filteredPOIs.map((poi) => (
            <Marker
              key={poi.id}
              position={[poi.lat, poi.lng]}
              icon={createPOIIcon(poi.category)}
            >
              <Popup>
                <div style={{ padding: "4px", minWidth: "180px" }}>
                  <div style={{ display: "flex", alignItems: "center", gap: "8px", marginBottom: "4px" }}>
                    <span style={{ fontSize: "18px" }}>{getPOIIcon(poi.category)}</span>
                    <p style={{ fontWeight: 600, fontSize: "13px" }}>{poi.name}</p>
                  </div>
                  <p style={{ fontSize: "11px", color: "#888", marginBottom: "4px" }}>{poi.address}</p>
                  <p style={{ fontSize: "11px", marginBottom: "6px" }}>{poi.description}</p>
                  <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
                    <span style={{
                      fontSize: "10px",
                      fontWeight: 700,
                      padding: "2px 6px",
                      borderRadius: "9999px",
                      background: poi.isOpen ? "#dcfce7" : "#fee2e2",
                      color: poi.isOpen ? "#166534" : "#991b1b",
                    }}>
                      {poi.isOpen ? "Open" : "Closed"}
                    </span>
                    <span style={{ fontSize: "11px", color: "#888" }}>{poi.distance} km away</span>
                  </div>
                </div>
              </Popup>
            </Marker>
          ))}
        </MapContainer>
      </div>

      {/* Legend */}
      <div className="flex items-center gap-4 px-1 flex-wrap text-xs text-[var(--text-muted)] flex-shrink-0">
        <span className="font-medium text-[var(--text-secondary)]">Heat Zones:</span>
        {(["low", "moderate", "high", "extreme"] as const).map((level) => (
          <span key={level} className="flex items-center gap-1">
            <span className="w-3 h-3 rounded-full inline-block" style={{ backgroundColor: getRiskColor(level) }} />
            {level.charAt(0).toUpperCase() + level.slice(1)}
          </span>
        ))}
        <span className="ml-auto text-[10px]">{filteredPOIs.length} locations shown</span>
      </div>
    </div>
  );
}
