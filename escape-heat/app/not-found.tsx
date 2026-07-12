import Link from "next/link";
import { Flame, Home, ArrowLeft } from "lucide-react";
import type { Metadata } from "next";

export const metadata: Metadata = { title: "404 — Page Not Found" };

export default function NotFound() {
  return (
    <div className="min-h-screen bg-[var(--bg-primary)] flex flex-col items-center justify-center px-4 text-center">
      {/* Background glow */}
      <div className="absolute top-1/3 left-1/2 -translate-x-1/2 -translate-y-1/2 w-96 h-96 bg-orange-500/8 rounded-full blur-3xl pointer-events-none" />

      <div className="relative">
        {/* Icon */}
        <div className="w-20 h-20 rounded-3xl bg-gradient-to-br from-orange-500/20 to-red-500/10 border border-orange-500/20 flex items-center justify-center mx-auto mb-6">
          <Flame className="w-10 h-10 text-orange-500" />
        </div>

        {/* 404 */}
        <div className="font-display font-bold text-[120px] leading-none text-gradient opacity-20 select-none absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 pointer-events-none">
          404
        </div>

        <div className="relative z-10">
          <h1 className="font-display font-bold text-3xl text-[var(--text-primary)] mb-3">
            Page Not Found
          </h1>
          <p className="text-[var(--text-secondary)] max-w-md mx-auto mb-8 text-sm leading-relaxed">
            The page you&apos;re looking for doesn&apos;t exist or has been moved.
            Let&apos;s get you back to safety.
          </p>

          <div className="flex flex-col sm:flex-row items-center justify-center gap-3">
            <Link href="/dashboard" className="btn-primary">
              <Home className="w-4 h-4" />
              Go to Dashboard
            </Link>
            <Link href="/" className="btn-secondary">
              <ArrowLeft className="w-4 h-4" />
              Back to Home
            </Link>
          </div>

          {/* Quick nav */}
          <div className="mt-10 flex flex-wrap justify-center gap-2">
            {[
              { label: "Heat Map", href: "/heatmap" },
              { label: "AI Assistant", href: "/assistant" },
              { label: "Recommendations", href: "/recommendations" },
              { label: "Profile", href: "/profile" },
            ].map((item) => (
              <Link
                key={item.href}
                href={item.href}
                className="px-3 py-1.5 rounded-xl text-xs font-medium bg-[var(--bg-card)] border border-[var(--border-primary)] text-[var(--text-secondary)] hover:border-orange-500/50 hover:text-orange-400 transition-all"
              >
                {item.label}
              </Link>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
