import { cn } from "@/lib/utils";
import { Inbox } from "lucide-react";

interface EmptyStateProps {
  icon?: React.ReactNode;
  title: string;
  description?: string;
  action?: React.ReactNode;
  className?: string;
}

export function EmptyState({
  icon,
  title,
  description,
  action,
  className,
}: EmptyStateProps) {
  return (
    <div
      className={cn(
        "flex flex-col items-center justify-center py-16 px-6 text-center",
        className
      )}
    >
      <div className="w-16 h-16 rounded-2xl bg-[var(--bg-tertiary)] flex items-center justify-center mb-4 text-2xl">
        {icon ?? <Inbox className="w-8 h-8 text-[var(--text-muted)]" />}
      </div>
      <h3 className="text-base font-semibold text-[var(--text-primary)] mb-1.5">
        {title}
      </h3>
      {description && (
        <p className="text-sm text-[var(--text-muted)] max-w-xs">{description}</p>
      )}
      {action && <div className="mt-4">{action}</div>}
    </div>
  );
}

interface ErrorStateProps {
  title?: string;
  description?: string;
  onRetry?: () => void;
  className?: string;
}

export function ErrorState({
  title = "Something went wrong",
  description = "Unable to load data. Please try again.",
  onRetry,
  className,
}: ErrorStateProps) {
  return (
    <div
      className={cn(
        "flex flex-col items-center justify-center py-16 px-6 text-center",
        className
      )}
    >
      <div className="w-16 h-16 rounded-2xl bg-red-500/10 flex items-center justify-center mb-4 text-3xl">
        ⚠️
      </div>
      <h3 className="text-base font-semibold text-[var(--text-primary)] mb-1.5">
        {title}
      </h3>
      <p className="text-sm text-[var(--text-muted)] max-w-xs mb-4">
        {description}
      </p>
      {onRetry && (
        <button onClick={onRetry} className="btn-secondary text-sm">
          Try again
        </button>
      )}
    </div>
  );
}
