import { cn, getRiskBgClass, getRiskLabel } from "@/lib/utils";
import type { RiskLevel } from "@/types";

interface RiskBadgeProps {
  level: RiskLevel;
  score?: number;
  size?: "sm" | "md" | "lg";
  showScore?: boolean;
  pulse?: boolean;
  className?: string;
}

export default function RiskBadge({
  level,
  score,
  size = "md",
  showScore = false,
  pulse = false,
  className,
}: RiskBadgeProps) {
  const sizeClasses = {
    sm: "text-[10px] px-2 py-0.5 gap-1",
    md: "text-xs px-2.5 py-1 gap-1.5",
    lg: "text-sm px-3 py-1.5 gap-2",
  };

  const dotSizes = {
    sm: "w-1.5 h-1.5",
    md: "w-2 h-2",
    lg: "w-2.5 h-2.5",
  };

  return (
    <span
      className={cn(
        "inline-flex items-center rounded-full font-semibold border",
        sizeClasses[size],
        getRiskBgClass(level),
        className
      )}
    >
      <span
        className={cn(
          "rounded-full flex-shrink-0",
          dotSizes[size],
          {
            "bg-green-400": level === "low",
            "bg-yellow-400": level === "moderate",
            "bg-orange-400": level === "high",
            "bg-red-400": level === "extreme",
          },
          pulse && "animate-pulse"
        )}
      />
      {getRiskLabel(level)}
      {showScore && score !== undefined && (
        <span className="ml-1 opacity-70">· {score}</span>
      )}
    </span>
  );
}
