"use client";

import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
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
  BarElement,
  Title,
  Tooltip,
  Legend,
  Filler
);

interface TemperatureChartProps {
  height?: number;
}

export default function TemperatureChart({ height = 220 }: TemperatureChartProps) {
  const labels = hourlyData.map((d) => d.hour);
  const temps = hourlyData.map((d) => d.temperature);
  const feelsLike = hourlyData.map((d) => d.feelsLike);

  const data = {
    labels,
    datasets: [
      {
        label: "Temperature (°C)",
        data: temps,
        borderColor: "#f97316",
        backgroundColor: "rgba(249, 115, 22, 0.12)",
        borderWidth: 2.5,
        pointRadius: 0,
        pointHoverRadius: 5,
        pointHoverBackgroundColor: "#f97316",
        fill: true,
        tension: 0.4,
      },
      {
        label: "Feels Like (°C)",
        data: feelsLike,
        borderColor: "#ef4444",
        backgroundColor: "rgba(239, 68, 68, 0.06)",
        borderWidth: 2,
        borderDash: [6, 3],
        pointRadius: 0,
        pointHoverRadius: 4,
        pointHoverBackgroundColor: "#ef4444",
        fill: false,
        tension: 0.4,
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
        borderColor: "rgba(249, 115, 22, 0.3)",
        borderWidth: 1,
        padding: 12,
        cornerRadius: 10,
        titleColor: "#f1f5f9",
        bodyColor: "#94a3b8",
        titleFont: { size: 12, weight: "bold" as const, family: "Inter" },
        bodyFont: { size: 12, family: "Inter" },
        callbacks: {
          label: (ctx: { dataset: { label?: string }; parsed: { y: number } }) =>
            ` ${ctx.dataset.label}: ${ctx.parsed.y}°C`,
        },
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
        ticks: {
          color: "#475569",
          font: { size: 10, family: "Inter" },
          callback: (v: string | number) => `${v}°`,
        },
        border: { display: false },
        min: 24,
        max: 48,
      },
    },
  };

  return (
    <div className="card p-4">
      <div className="flex items-center justify-between mb-4">
        <div>
          <h3 className="text-sm font-semibold text-[var(--text-primary)]">
            24h Temperature
          </h3>
          <p className="text-xs text-[var(--text-muted)]">Today · Chennai</p>
        </div>
        <span className="text-xs font-medium px-2 py-1 rounded-lg bg-orange-500/10 text-orange-400 border border-orange-500/20">
          Peak: 40°C at 2 PM
        </span>
      </div>
      <div style={{ height }}>
        <Line data={data} options={options} />
      </div>
    </div>
  );
}
