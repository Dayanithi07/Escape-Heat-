"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";
import {
  LayoutDashboard,
  Map,
  MessageSquare,
  Lightbulb,
  User,
  Settings,
  Flame,
  ChevronLeft,
  ChevronRight,
  AlertTriangle,
} from "lucide-react";
import { cn } from "@/lib/utils";

const navItems = [
  { label: "Dashboard", href: "/dashboard", icon: LayoutDashboard },
  { label: "Heat Map", href: "/heatmap", icon: Map },
  { label: "AI Assistant", href: "/assistant", icon: MessageSquare, badge: "AI" },
  { label: "Recommendations", href: "/recommendations", icon: Lightbulb },
  { label: "Profile", href: "/profile", icon: User },
  { label: "Settings", href: "/settings", icon: Settings },
];

export default function Sidebar() {
  const pathname = usePathname();
  const [collapsed, setCollapsed] = useState(false);

  return (
    <aside
      className={cn(
        "hidden lg:flex flex-col border-r transition-all duration-300 ease-in-out relative",
        "border-[var(--border-primary)] bg-[var(--sidebar-bg)]",
        collapsed ? "w-[72px]" : "w-[240px]"
      )}
    >
      {/* Logo */}
      <div
        className={cn(
          "flex items-center gap-3 px-4 py-5 border-b border-[var(--border-primary)]",
          collapsed && "justify-center px-0"
        )}
      >
        <div className="flex-shrink-0 w-9 h-9 rounded-xl bg-gradient-to-br from-orange-500 to-red-500 flex items-center justify-center shadow-md">
          <Flame className="w-5 h-5 text-white" />
        </div>
        {!collapsed && (
          <div className="animate-fade-in">
            <p className="font-display font-bold text-base text-[var(--text-primary)] leading-none">
              Escape
            </p>
            <p className="text-[10px] text-orange-500 font-semibold tracking-widest uppercase">
              Heat
            </p>
          </div>
        )}
      </div>

      {/* Navigation */}
      <nav className="flex-1 px-3 py-4 space-y-1 overflow-y-auto no-scrollbar">
        {navItems.map((item) => {
          const isActive =
            pathname === item.href ||
            (item.href !== "/" && pathname.startsWith(item.href));
          const Icon = item.icon;
          return (
            <Link
              key={item.href}
              href={item.href}
              title={collapsed ? item.label : undefined}
              className={cn(
                "nav-link group relative",
                isActive && "active",
                collapsed && "justify-center px-0 py-3"
              )}
            >
              <Icon
                className={cn(
                  "w-5 h-5 flex-shrink-0 transition-colors",
                  isActive ? "text-orange-500" : "text-[var(--text-muted)] group-hover:text-[var(--text-primary)]"
                )}
              />
              {!collapsed && (
                <span className="flex-1 truncate">{item.label}</span>
              )}
              {!collapsed && item.badge && (
                <span className="text-[10px] font-bold px-1.5 py-0.5 rounded-md bg-orange-500/10 text-orange-500 border border-orange-500/20">
                  {item.badge}
                </span>
              )}
              {collapsed && item.badge && (
                <span className="absolute top-1 right-1 w-2 h-2 rounded-full bg-orange-500" />
              )}
              {/* Tooltip for collapsed */}
              {collapsed && (
                <div className="absolute left-full ml-3 px-2 py-1 rounded-lg bg-[var(--bg-card)] border border-[var(--border-primary)] text-[var(--text-primary)] text-xs font-medium whitespace-nowrap opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none z-50 shadow-lg">
                  {item.label}
                </div>
              )}
            </Link>
          );
        })}
      </nav>

      {/* Risk Alert Widget */}
      {!collapsed && (
        <div className="mx-3 mb-3 p-3 rounded-xl bg-orange-500/10 border border-orange-500/20 animate-fade-in">
          <div className="flex items-start gap-2">
            <AlertTriangle className="w-4 h-4 text-orange-500 flex-shrink-0 mt-0.5" />
            <div>
              <p className="text-xs font-semibold text-orange-400">High Heat Alert</p>
              <p className="text-[11px] text-[var(--text-muted)] mt-0.5">
                Risk score 78/100 · Stay hydrated
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Collapse Toggle */}
      <button
        onClick={() => setCollapsed(!collapsed)}
        className={cn(
          "mx-3 mb-4 flex items-center gap-2 px-3 py-2 rounded-xl text-xs font-medium",
          "text-[var(--text-muted)] hover:text-[var(--text-primary)] hover:bg-[var(--bg-tertiary)]",
          "transition-all duration-200",
          collapsed && "justify-center mx-2 px-0"
        )}
      >
        {collapsed ? (
          <ChevronRight className="w-4 h-4" />
        ) : (
          <>
            <ChevronLeft className="w-4 h-4" />
            <span>Collapse</span>
          </>
        )}
      </button>
    </aside>
  );
}
