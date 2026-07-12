import { cn } from "@/lib/utils";
import type { Recommendation } from "@/types";
import { ChevronDown, ChevronUp, AlertCircle, Info, AlertTriangle } from "lucide-react";
import { useState } from "react";

const priorityConfig = {
  urgent: {
    label: "Urgent",
    icon: AlertCircle,
    classes: "bg-red-500/10 text-red-400 border-red-500/20",
  },
  important: {
    label: "Important",
    icon: AlertTriangle,
    classes: "bg-orange-500/10 text-orange-400 border-orange-500/20",
  },
  advisory: {
    label: "Advisory",
    icon: Info,
    classes: "bg-blue-500/10 text-blue-400 border-blue-500/20",
  },
};

interface RecommendationCardProps {
  recommendation: Recommendation;
  className?: string;
}

export default function RecommendationCard({
  recommendation: rec,
  className,
}: RecommendationCardProps) {
  const [expanded, setExpanded] = useState(false);
  const priority = priorityConfig[rec.priority];
  const PriorityIcon = priority.icon;

  return (
    <div
      className={cn(
        "card p-4 group transition-all duration-200 hover:-translate-y-0.5 hover:shadow-card-dark",
        className
      )}
    >
      {/* Header */}
      <div className="flex items-start gap-3 mb-3">
        <div className="w-10 h-10 rounded-xl bg-[var(--bg-tertiary)] flex items-center justify-center text-xl flex-shrink-0">
          {rec.icon}
        </div>
        <div className="flex-1 min-w-0">
          <div className="flex items-start justify-between gap-2 mb-1">
            <h3 className="text-sm font-semibold text-[var(--text-primary)] leading-snug">
              {rec.title}
            </h3>
            <span
              className={cn(
                "flex-shrink-0 inline-flex items-center gap-1 text-[10px] font-bold px-2 py-0.5 rounded-full border",
                priority.classes
              )}
            >
              <PriorityIcon className="w-2.5 h-2.5" />
              {priority.label}
            </span>
          </div>
          <p className="text-xs text-[var(--text-secondary)] leading-relaxed line-clamp-2">
            {rec.description}
          </p>
        </div>
      </div>

      {/* Tags */}
      <div className="flex items-center gap-2 mb-3">
        <span className="text-[10px] font-medium px-2 py-0.5 rounded-full bg-[var(--bg-tertiary)] text-[var(--text-muted)] capitalize border border-[var(--border-primary)]">
          {rec.category}
        </span>
        {rec.validUntil && (
          <span className="text-[10px] text-[var(--text-muted)]">
            ⏰ Valid until {rec.validUntil}
          </span>
        )}
      </div>

      {/* Action Items (expandable) */}
      <button
        onClick={() => setExpanded(!expanded)}
        className="w-full flex items-center justify-between text-xs font-medium text-[var(--text-secondary)] hover:text-orange-400 transition-colors py-1"
      >
        <span>{rec.actionItems.length} action items</span>
        {expanded ? <ChevronUp className="w-4 h-4" /> : <ChevronDown className="w-4 h-4" />}
      </button>

      {expanded && (
        <ul className="mt-2 space-y-1.5 animate-fade-in border-t border-[var(--border-primary)] pt-3">
          {rec.actionItems.map((item, i) => (
            <li key={i} className="flex items-start gap-2 text-xs text-[var(--text-secondary)]">
              <span className="w-4 h-4 rounded-full bg-orange-500/10 text-orange-500 font-bold text-[10px] flex items-center justify-center flex-shrink-0 mt-0.5">
                {i + 1}
              </span>
              <span>{item}</span>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
