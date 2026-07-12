import { cn, getRiskColor, getRiskLabel } from "@/lib/utils";
import type { RiskLevel } from "@/types";

interface RiskIndicatorProps {
  score: number; // 0–100
  level: RiskLevel;
  size?: "sm" | "md" | "lg";
  showLabel?: boolean;
  className?: string;
}

export default function RiskIndicator({
  score,
  level,
  size = "md",
  showLabel = true,
  className,
}: RiskIndicatorProps) {
  const color = getRiskColor(level);

  const dims = {
    sm: { r: 36, cx: 44, cy: 44, vb: "0 0 88 88", strokeW: 7, textSize: "text-xl", labelSize: "text-[10px]" },
    md: { r: 54, cx: 64, cy: 64, vb: "0 0 128 128", strokeW: 10, textSize: "text-3xl", labelSize: "text-xs" },
    lg: { r: 72, cx: 88, cy: 88, vb: "0 0 176 176", strokeW: 12, textSize: "text-4xl", labelSize: "text-sm" },
  };

  const d = dims[size];
  const circumference = 2 * Math.PI * d.r;
  const dashOffset = circumference - (score / 100) * circumference;

  return (
    <div className={cn("relative inline-flex flex-col items-center gap-2", className)}>
      <div className="relative">
        <svg
          viewBox={d.vb}
          className={cn(
            size === "sm" ? "w-24 h-24" : size === "lg" ? "w-48 h-48" : "w-36 h-36",
            "-rotate-90"
          )}
        >
          {/* Background track */}
          <circle
            cx={d.cx}
            cy={d.cy}
            r={d.r}
            fill="none"
            stroke="currentColor"
            strokeWidth={d.strokeW}
            className="text-[var(--bg-tertiary)]"
          />
          {/* Progress arc */}
          <circle
            cx={d.cx}
            cy={d.cy}
            r={d.r}
            fill="none"
            stroke={color}
            strokeWidth={d.strokeW}
            strokeLinecap="round"
            strokeDasharray={circumference}
            strokeDashoffset={dashOffset}
            style={{
              transition: "stroke-dashoffset 1s ease",
              filter: `drop-shadow(0 0 6px ${color}80)`,
            }}
          />
        </svg>

        {/* Center content */}
        <div className="absolute inset-0 flex flex-col items-center justify-center rotate-0">
          <span
            className={cn("font-display font-bold tabular-nums leading-none", d.textSize)}
            style={{ color }}
          >
            {score}
          </span>
          {showLabel && (
            <span className={cn("text-[var(--text-muted)] font-medium mt-1", d.labelSize)}>
              / 100
            </span>
          )}
        </div>
      </div>

      {showLabel && (
        <div className="flex flex-col items-center">
          <span
            className={cn("font-semibold", d.labelSize)}
            style={{ color }}
          >
            {getRiskLabel(level)}
          </span>
        </div>
      )}
    </div>
  );
}
