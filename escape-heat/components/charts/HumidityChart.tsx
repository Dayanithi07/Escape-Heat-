"use client";

import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  Filler,
} from "chart.js";
import { Line } from "react-chartjs-2";
import { hourlyData } from "@/lib/mock-data/weather";

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  Filler
);

export default function HumidityChart({ height = 180 }: { height?: number }) {
  const labels = hourlyData.map((d) => d.hour);
  const humidity = hourlyData.map((d) => d.humidity);
  const uv = hourlyData.map((d) => d.uvIndex);

  const data = {
    labels,
    datasets: [
      {
        label: "Humidity (%)",
        data: humidity,
        borderColor: "#3b82f6",
        backgroundColor: "rgba(59, 130, 246, 0.15)",
        borderWidth: 2,
        pointRadius: 0,
        pointHoverRadius: 4,
        fill: true,
        tension: 0.4,
        yAxisID: "y",
      },
      {
        label: "UV Index",
        data: uv,
        borderColor: "#eab308",
        backgroundColor: "rgba(234, 179, 8, 0.08)",
        borderWidth: 2,
        pointRadius: 0,
        pointHoverRadius: 4,
        fill: false,
        tension: 0.4,
        yAxisID: "y1",
      },
    ],
  };

  const options = {
    responsive: true,
    maintainAspectRatio: false,
    interaction: { mode: "index" as const, intersect: false },
    plugins: {
      legend: {
        position: "top" as const,
        align: "end" as const,
        labels: {
          boxWidth: 12,
          boxHeight: 12,
          borderRadius: 4,
          useBorderRadius: true,
          padding: 16,
          color: "#94a3b8",
          font: { size: 11, family: "Inter" },
        },
      },
      tooltip: {
        backgroundColor: "rgba(15, 23, 42, 0.95)",
        borderColor: "rgba(59, 130, 246, 0.3)",
        borderWidth: 1,
        padding: 12,
        cornerRadius: 10,
        titleColor: "#f1f5f9",
        bodyColor: "#94a3b8",
        titleFont: { size: 12, weight: "bold" as const, family: "Inter" },
        bodyFont: { size: 12, family: "Inter" },
      },
    },
    scales: {
      x: {
        grid: { display: false },
        ticks: {
          color: "#475569",
          font: { size: 10, family: "Inter" },
          maxTicksLimit: 8,
        },
        border: { display: false },
      },
      y: {
        grid: { color: "rgba(255,255,255,0.04)" },
        ticks: { color: "#475569", font: { size: 10, family: "Inter" }, callback: (v: string | number) => `${v}%` },
        border: { display: false },
        min: 60,
        max: 100,
        position: "left" as const,
      },
      y1: {
        grid: { display: false },
        ticks: { color: "#475569", font: { size: 10, family: "Inter" } },
        border: { display: false },
        min: 0,
        max: 12,
        position: "right" as const,
      },
    },
  };

  return (
    <div className="card p-4">
      <div className="flex items-center justify-between mb-4">
        <div>
          <h3 className="text-sm font-semibold text-[var(--text-primary)]">
            Humidity & UV Index
          </h3>
          <p className="text-xs text-[var(--text-muted)]">24h hourly breakdown</p>
        </div>
      </div>
      <div style={{ height }}>
        <Line data={data} options={options} />
      </div>
    </div>
  );
}
