"use client";

import { useState } from "react";
import AppShell from "@/components/layout/AppShell";
import RecommendationCard from "@/components/recommendations/RecommendationCard";
import { recommendations, categoryLabels } from "@/lib/mock-data/recommendations";
import type { RecommendationCategory, RecommendationPriority } from "@/types";
import { Filter, AlertCircle, RefreshCw } from "lucide-react";
import { cn } from "@/lib/utils";
import LoadingSkeleton from "@/components/ui/LoadingSkeleton";
import { EmptyState } from "@/components/ui/States";

type CategoryFilter = "all" | RecommendationCategory;
type PriorityFilter = "all" | RecommendationPriority;

const categoryIcons: Record<string, string> = {
  all: "🗂️",
  hydration: "💧",
  activity: "🏃",
  clothing: "👕",
  health: "🏥",
  travel: "🚌",
  timing: "⏰",
};

export default function RecommendationsPage() {
  const [categoryFilter, setCategoryFilter] = useState<CategoryFilter>("all");
  const [priorityFilter, setPriorityFilter] = useState<PriorityFilter>("all");
  const [isLoading, setIsLoading] = useState(false);

  const handleRefresh = () => {
    setIsLoading(true);
    setTimeout(() => {
      setIsLoading(false);
    }, 800);
  };

  const filtered = recommendations.filter((rec) => {
    const catMatch = categoryFilter === "all" || rec.category === categoryFilter;
    const priMatch = priorityFilter === "all" || rec.priority === priorityFilter;
    return catMatch && priMatch;
  });

  const urgentCount = recommendations.filter((r) => r.priority === "urgent").length;

  return (
    <AppShell>
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
        <div>
          <h1 className="font-display font-bold text-2xl text-[var(--text-primary)]">
            Recommendations
          </h1>
          <p className="text-sm text-[var(--text-muted)] mt-0.5">
            {recommendations.length} personalized actions · Updated for current conditions
          </p>
        </div>
        <div className="flex items-center gap-3">
          <button
            onClick={handleRefresh}
            disabled={isLoading}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-semibold bg-[var(--bg-card)] border border-[var(--border-primary)] text-[var(--text-secondary)] hover:border-orange-500/50 hover:text-orange-400 transition-all disabled:opacity-50"
            title="Refresh recommendations"
          >
            <RefreshCw className={cn("w-3.5 h-3.5", isLoading && "animate-spin")} />
            Refresh
          </button>
          {urgentCount > 0 && (
            <div className="flex items-center gap-2 px-4 py-2 rounded-xl bg-red-500/10 border border-red-500/25 text-red-400 text-sm font-medium">
              <AlertCircle className="w-4 h-4" />
              {urgentCount} urgent action{urgentCount > 1 ? "s" : ""} required
            </div>
          )}
        </div>
      </div>

      {/* Filters */}
      <div className="flex flex-col sm:flex-row gap-3 mb-6">
        {/* Category */}
        <div className="flex items-center gap-2 flex-wrap">
          <Filter className="w-4 h-4 text-[var(--text-muted)] flex-shrink-0" />
          {(Object.keys(categoryLabels) as CategoryFilter[]).map((cat) => (
            <button
              key={cat}
              onClick={() => setCategoryFilter(cat)}
              className={cn(
                "flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-semibold border transition-all",
                categoryFilter === cat
                  ? "bg-orange-500 text-white border-orange-500"
                  : "bg-[var(--bg-card)] text-[var(--text-secondary)] border-[var(--border-primary)] hover:border-orange-500/50"
              )}
            >
              <span>{categoryIcons[cat]}</span>
              {categoryLabels[cat]}
            </button>
          ))}
        </div>

        {/* Priority */}
        <div className="flex items-center gap-2 sm:ml-auto">
          {(["all", "urgent", "important", "advisory"] as PriorityFilter[]).map((pri) => (
            <button
              key={pri}
              onClick={() => setPriorityFilter(pri)}
              className={cn(
                "px-3 py-1.5 rounded-xl text-xs font-semibold border capitalize transition-all",
                priorityFilter === pri
                  ? "bg-[var(--text-primary)] text-[var(--bg-primary)] border-[var(--text-primary)]"
                  : "bg-[var(--bg-card)] text-[var(--text-secondary)] border-[var(--border-primary)] hover:border-[var(--border-secondary)]"
              )}
            >
              {pri === "all" ? "All Priority" : pri}
            </button>
          ))}
        </div>
      </div>

      {/* Results Count */}
      <p className="text-xs text-[var(--text-muted)] mb-4">
        Showing {isLoading ? "..." : filtered.length} of {recommendations.length} recommendations
      </p>

      {/* Cards Grid */}
      {isLoading ? (
        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
          <LoadingSkeleton variant="card" count={6} className="grid grid-cols-1 gap-4" />
        </div>
      ) : filtered.length === 0 ? (
        <EmptyState
          icon="🔍"
          title="No recommendations match your filters"
          description="Try changing the category or priority filters to see more advice."
          action={
            <button
              onClick={() => { setCategoryFilter("all"); setPriorityFilter("all"); }}
              className="btn-secondary text-xs"
            >
              Clear Filters
            </button>
          }
        />
      ) : (
        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {filtered.map((rec) => (
            <RecommendationCard key={rec.id} recommendation={rec} />
          ))}
        </div>
      )}
    </AppShell>
  );
}
