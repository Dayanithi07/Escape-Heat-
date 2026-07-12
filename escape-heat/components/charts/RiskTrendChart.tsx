"use client";

import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  Filler,
} from "chart.js";
import { Bar } from "react-chartjs-2";
import { weeklyTrend } from "@/lib/mock-data/weather";
import { getRiskColor } from "@/lib/utils";

ChartJS.register(
  CategoryScale,
  LinearScale,
  BarElement,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  Filler
);

export default function RiskTrendChart({ height = 220 }: { height?: number }) {
  const labels = weeklyTrend.map((d) => d.day);
  const scores = weeklyTrend.map((d) => d.riskScore);
  const colors = weeklyTrend.map((d) => getRiskColor(d.riskLevel));
  const borderColors = weeklyTrend.map((d) => getRiskColor(d.riskLevel));

  const data = {
    labels,
    datasets: [
      {
        label: "Risk Score",
        data: scores,
        backgroundColor: colors.map((c) => `${c}33`),
        borderColor: borderColors,
        borderWidth: 2,
        borderRadius: 8,
        borderSkipped: false,
      },
    ],
  };

  const options = {
    responsive: true,
    maintainAspectRatio: false,
    interaction: { mode: "index" as const, intersect: false },
    plugins: {
      legend: { display: false },
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
          label: (ctx: { parsed: { y: number } }) =>
            ` Risk Score: ${ctx.parsed.y}/100`,
        },
      },
    },
    scales: {
      x: {
        grid: { display: false },
        ticks: {
          color: "#475569",
          font: { size: 11, family: "Inter" },
        },
        border: { display: false },
      },
      y: {
        grid: { color: "rgba(255,255,255,0.04)" },
        ticks: {
          color: "#475569",
          font: { size: 10, family: "Inter" },
          maxTicksLimit: 5,
        },
        border: { display: false },
        min: 0,
        max: 100,
      },
    },
  };

  return (
    <div className="card p-4">
      <div className="flex items-center justify-between mb-4">
        <div>
          <h3 className="text-sm font-semibold text-[var(--text-primary)]">
            7-Day Risk Trend
          </h3>
          <p className="text-xs text-[var(--text-muted)]">Heat risk score history</p>
        </div>
        <div className="flex items-center gap-3 text-xs text-[var(--text-muted)]">
          <span className="flex items-center gap-1">
            <span className="w-2.5 h-2.5 rounded bg-green-500" /> Low
          </span>
          <span className="flex items-center gap-1">
            <span className="w-2.5 h-2.5 rounded bg-orange-500" /> High
          </span>
          <span className="flex items-center gap-1">
            <span className="w-2.5 h-2.5 rounded bg-red-500" /> Extreme
          </span>
        </div>
      </div>
      <div style={{ height }}>
        <Bar data={data} options={options} />
      </div>
    </div>
  );
}
