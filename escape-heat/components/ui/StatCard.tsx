import { cn } from "@/lib/utils";
import { TrendingUp, TrendingDown, Minus } from "lucide-react";

interface StatCardProps {
  label: string;
  value: string | number;
  unit?: string;
  icon?: React.ReactNode;
  trend?: "up" | "down" | "stable";
  trendValue?: string;
  description?: string;
  accentColor?: string;
  className?: string;
  size?: "sm" | "md" | "lg";
}

export default function StatCard({
  label,
  value,
  unit,
  icon,
  trend,
  trendValue,
  description,
  accentColor = "#f97316",
  className,
  size = "md",
}: StatCardProps) {
  const TrendIcon =
    trend === "up" ? TrendingUp : trend === "down" ? TrendingDown : Minus;

  const trendColor =
    trend === "up"
      ? "text-red-400"
      : trend === "down"
      ? "text-green-400"
      : "text-[var(--text-muted)]";

  return (
    <div
      className={cn(
        "card p-4 group hover:shadow-card-dark transition-all duration-200 hover:-translate-y-0.5",
        className
      )}
    >
      <div className="flex items-start justify-between mb-3">
        <p className="text-xs font-medium text-[var(--text-muted)] uppercase tracking-wide">
          {label}
        </p>
        {icon && (
          <div
            className="w-8 h-8 rounded-lg flex items-center justify-center text-base"
            style={{ backgroundColor: `${accentColor}15`, color: accentColor }}
          >
            {icon}
          </div>
        )}
      </div>

      <div className="flex items-end gap-1 mb-2">
        <span
          className={cn(
            "font-display font-bold leading-none tabular-nums",
            size === "sm" ? "text-2xl" : size === "lg" ? "text-4xl" : "text-3xl"
          )}
          style={{ color: accentColor }}
        >
          {value}
        </span>
        {unit && (
          <span className="text-sm font-medium text-[var(--text-muted)] mb-0.5">
            {unit}
          </span>
        )}
      </div>

      {description && (
        <p className="text-xs text-[var(--text-secondary)] mb-2">{description}</p>
      )}

      {trend && trendValue && (
        <div className={cn("flex items-center gap-1 text-xs font-medium", trendColor)}>
          <TrendIcon className="w-3 h-3" />
          <span>{trendValue}</span>
        </div>
      )}

      {/* Accent bar */}
      <div
        className="absolute bottom-0 left-0 right-0 h-0.5 rounded-b-xl opacity-0 group-hover:opacity-100 transition-opacity"
        style={{ backgroundColor: accentColor }}
      />
    </div>
  );
}
