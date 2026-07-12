"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";
import {
  Flame,
  Bell,
  Sun,
  Moon,
  MapPin,
  Search,
  Menu,
  X,
  LayoutDashboard,
  Map,
  MessageSquare,
  Lightbulb,
  User,
  Settings,
} from "lucide-react";
import { useTheme } from "next-themes";
import { cn } from "@/lib/utils";

const navItems = [
  { label: "Dashboard", href: "/dashboard", icon: LayoutDashboard },
  { label: "Heat Map", href: "/heatmap", icon: Map },
  { label: "AI Assistant", href: "/assistant", icon: MessageSquare },
  { label: "Recommendations", href: "/recommendations", icon: Lightbulb },
  { label: "Profile", href: "/profile", icon: User },
  { label: "Settings", href: "/settings", icon: Settings },
];

export default function Navbar() {
  const { theme, setTheme } = useTheme();
  const pathname = usePathname();
  const [mobileOpen, setMobileOpen] = useState(false);

  return (
    <>
      <header
        className="sticky top-0 z-50 border-b border-[var(--border-primary)] backdrop-blur-md"
        style={{ backgroundColor: "var(--navbar-bg)" }}
      >
        <div className="flex items-center justify-between h-16 px-4 lg:px-6">
          {/* Left: Logo + Location */}
          <div className="flex items-center gap-4">
            {/* Mobile menu toggle */}
            <button
              onClick={() => setMobileOpen(!mobileOpen)}
              className="lg:hidden p-2 rounded-lg text-[var(--text-secondary)] hover:text-[var(--text-primary)] hover:bg-[var(--bg-tertiary)] transition-colors"
            >
              {mobileOpen ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
            </button>

            {/* Logo */}
            <Link href="/" className="flex items-center gap-2.5 group">
              <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-orange-500 to-red-500 flex items-center justify-center shadow-heat group-hover:shadow-heat-lg transition-shadow">
                <Flame className="w-4 h-4 text-white" />
              </div>
              <div className="hidden sm:block">
                <span className="font-display font-bold text-sm text-[var(--text-primary)]">
                  Escape{" "}
                  <span className="text-gradient">Heat</span>
                </span>
              </div>
            </Link>

            {/* Location pill */}
            <div className="hidden md:flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-[var(--bg-tertiary)] border border-[var(--border-primary)] text-xs text-[var(--text-secondary)]">
              <MapPin className="w-3.5 h-3.5 text-orange-500" />
              <span className="font-medium">Chennai, TN</span>
              <span className="text-[var(--text-muted)]">· 38°C</span>
            </div>
          </div>

          {/* Center: Search (desktop) */}
          <div className="hidden lg:flex flex-1 max-w-xs mx-8">
            <div className="relative w-full">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[var(--text-muted)]" />
              <input
                type="text"
                placeholder="Search locations..."
                className="w-full pl-9 pr-4 py-2 text-sm rounded-xl bg-[var(--bg-tertiary)] border border-[var(--border-primary)] text-[var(--text-primary)] placeholder:text-[var(--text-muted)] focus:outline-none focus:border-orange-500/50 transition-colors"
              />
            </div>
          </div>

          {/* Right: Actions */}
          <div className="flex items-center gap-2">
            {/* Risk Score Chip */}
            <div className="hidden sm:flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-orange-500/10 border border-orange-500/20">
              <span className="w-2 h-2 rounded-full bg-orange-500 animate-pulse" />
              <span className="text-xs font-semibold text-orange-500">
                Risk: 78
              </span>
            </div>

            {/* Notifications */}
            <button className="relative p-2 rounded-xl text-[var(--text-secondary)] hover:text-[var(--text-primary)] hover:bg-[var(--bg-tertiary)] transition-colors">
              <Bell className="w-5 h-5" />
              <span className="absolute top-1.5 right-1.5 w-2 h-2 rounded-full bg-orange-500" />
            </button>

            {/* Theme Toggle */}
            <button
              onClick={() => setTheme(theme === "dark" ? "light" : "dark")}
              className="p-2 rounded-xl text-[var(--text-secondary)] hover:text-[var(--text-primary)] hover:bg-[var(--bg-tertiary)] transition-colors"
              title="Toggle theme"
            >
              {theme === "dark" ? (
                <Sun className="w-5 h-5" />
              ) : (
                <Moon className="w-5 h-5" />
              )}
            </button>

            {/* Avatar */}
            <div className="w-8 h-8 rounded-xl bg-gradient-to-br from-orange-500 to-red-500 flex items-center justify-center text-white text-xs font-bold cursor-pointer hover:opacity-90 transition-opacity">
              AK
            </div>
          </div>
        </div>
      </header>

      {/* Mobile Drawer */}
      {mobileOpen && (
        <div className="lg:hidden fixed inset-0 z-40" onClick={() => setMobileOpen(false)}>
          <div className="absolute inset-0 bg-black/50 backdrop-blur-sm" />
          <nav
            className="absolute top-16 left-0 bottom-0 w-72 bg-[var(--sidebar-bg)] border-r border-[var(--border-primary)] p-4 space-y-1 overflow-y-auto animate-slide-in-right"
            onClick={(e) => e.stopPropagation()}
          >
            {navItems.map((item) => {
              const isActive = pathname === item.href || pathname.startsWith(item.href);
              const Icon = item.icon;
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  onClick={() => setMobileOpen(false)}
                  className={cn("nav-link", isActive && "active")}
                >
                  <Icon className={cn("w-5 h-5", isActive ? "text-orange-500" : "")} />
                  {item.label}
                </Link>
              );
            })}
          </nav>
        </div>
      )}
    </>
  );
}
