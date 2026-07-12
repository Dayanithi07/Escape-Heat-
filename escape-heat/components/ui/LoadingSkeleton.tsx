import { cn } from "@/lib/utils";

interface LoadingSkeletonProps {
  variant?: "card" | "chart" | "list" | "text" | "avatar";
  count?: number;
  className?: string;
}

function Bone({ className }: { className?: string }) {
  return (
    <div
      className={cn(
        "rounded-lg shimmer-effect",
        className
      )}
    />
  );
}

export default function LoadingSkeleton({
  variant = "card",
  count = 1,
  className,
}: LoadingSkeletonProps) {
  if (variant === "text") {
    return (
      <div className={cn("space-y-2", className)}>
        {Array.from({ length: count }).map((_, i) => (
          <Bone key={i} className={cn("h-4", i === count - 1 ? "w-3/4" : "w-full")} />
        ))}
      </div>
    );
  }

  if (variant === "avatar") {
    return (
      <div className={cn("flex items-center gap-3", className)}>
        <Bone className="w-10 h-10 rounded-full" />
        <div className="flex-1 space-y-2">
          <Bone className="h-4 w-2/3" />
          <Bone className="h-3 w-1/2" />
        </div>
      </div>
    );
  }

  if (variant === "chart") {
    return (
      <div className={cn("card p-4", className)}>
        <Bone className="h-4 w-1/3 mb-4" />
        <Bone className="h-48 w-full rounded-xl" />
      </div>
    );
  }

  if (variant === "list") {
    return (
      <div className={cn("space-y-3", className)}>
        {Array.from({ length: count }).map((_, i) => (
          <div key={i} className="card p-4 flex items-start gap-3">
            <Bone className="w-10 h-10 rounded-xl flex-shrink-0" />
            <div className="flex-1 space-y-2">
              <Bone className="h-4 w-2/3" />
              <Bone className="h-3 w-full" />
              <Bone className="h-3 w-4/5" />
            </div>
          </div>
        ))}
      </div>
    );
  }

  // Default: card
  return (
    <div className={cn("grid gap-4", className)}>
      {Array.from({ length: count }).map((_, i) => (
        <div key={i} className="card p-4 space-y-3">
          <div className="flex items-center justify-between">
            <Bone className="h-3 w-24" />
            <Bone className="h-8 w-8 rounded-lg" />
          </div>
          <Bone className="h-8 w-20" />
          <Bone className="h-3 w-32" />
        </div>
      ))}
    </div>
  );
}
