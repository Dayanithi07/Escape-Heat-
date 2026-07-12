"use client";

import { useState } from "react";
import AppShell from "@/components/layout/AppShell";
import { useTheme } from "next-themes";
import {
  Sun,
  Moon,
  Monitor,
  Bell,
  BellOff,
  Thermometer,
  Globe,
  Shield,
  Trash2,
  Download,
  Check,
  Wind,
} from "lucide-react";
import { cn } from "@/lib/utils";

function Toggle({
  checked,
  onChange,
}: {
  checked: boolean;
  onChange: (v: boolean) => void;
}) {
  return (
    <button
      role="switch"
      aria-checked={checked}
      onClick={() => onChange(!checked)}
      className={cn(
        "relative w-11 h-6 rounded-full transition-colors duration-200",
        checked ? "bg-orange-500" : "bg-[var(--bg-tertiary)] border border-[var(--border-secondary)]"
      )}
    >
      <span
        className={cn(
          "absolute top-0.5 left-0.5 w-5 h-5 rounded-full bg-white shadow-sm transition-transform duration-200",
          checked ? "translate-x-5" : "translate-x-0"
        )}
      />
    </button>
  );
}

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div className="card p-5">
      <h3 className="text-sm font-semibold text-[var(--text-primary)] mb-4 pb-3 border-b border-[var(--border-primary)]">
        {title}
      </h3>
      <div className="space-y-4">{children}</div>
    </div>
  );
}

function SettingRow({
  icon,
  label,
  description,
  control,
}: {
  icon: React.ReactNode;
  label: string;
  description?: string;
  control: React.ReactNode;
}) {
  return (
    <div className="flex items-center justify-between gap-4">
      <div className="flex items-center gap-3">
        <div className="w-8 h-8 rounded-lg bg-[var(--bg-tertiary)] flex items-center justify-center flex-shrink-0">
          {icon}
        </div>
        <div>
          <p className="text-sm font-medium text-[var(--text-primary)]">{label}</p>
          {description && (
            <p className="text-xs text-[var(--text-muted)]">{description}</p>
          )}
        </div>
      </div>
      {control}
    </div>
  );
}

export default function SettingsPage() {
  const { theme, setTheme } = useTheme();
  const [settings, setSettings] = useState({
    notifications: true,
    heatAlerts: true,
    uvAlerts: true,
    weeklyReport: false,
    soundAlerts: false,
    tempUnit: "celsius" as "celsius" | "fahrenheit",
    windUnit: "kmh" as "kmh" | "mph",
    language: "en",
    locationAccess: true,
    dataCollection: false,
  });

  const toggle = (key: keyof typeof settings) =>
    setSettings((s) => ({ ...s, [key]: !s[key] }));

  return (
    <AppShell>
      <div className="max-w-2xl mx-auto">
        <div className="mb-6">
          <h1 className="font-display font-bold text-2xl text-[var(--text-primary)]">Settings</h1>
          <p className="text-sm text-[var(--text-muted)] mt-0.5">
            Customize your Escape Heat experience
          </p>
        </div>

        <div className="flex flex-col gap-4">
          {/* Appearance */}
          <Section title="Appearance">
            <div>
              <p className="text-sm font-medium text-[var(--text-primary)] mb-3">Theme</p>
              <div className="grid grid-cols-3 gap-3">
                {(["light", "dark", "system"] as const).map((t) => {
                  const Icon = t === "light" ? Sun : t === "dark" ? Moon : Monitor;
                  return (
                    <button
                      key={t}
                      onClick={() => setTheme(t)}
                      className={cn(
                        "flex flex-col items-center gap-2 p-4 rounded-xl border capitalize text-sm font-medium transition-all",
                        theme === t
                          ? "border-orange-500 bg-orange-500/10 text-orange-400"
                          : "border-[var(--border-primary)] text-[var(--text-secondary)] hover:border-[var(--border-secondary)]"
                      )}
                    >
                      <Icon className="w-5 h-5" />
                      {t}
                      {theme === t && <Check className="w-3.5 h-3.5 text-orange-400" />}
                    </button>
                  );
                })}
              </div>
            </div>
          </Section>

          {/* Notifications */}
          <Section title="Notifications">
            <SettingRow
              icon={<Bell className="w-4 h-4 text-orange-500" />}
              label="Push Notifications"
              description="Receive alerts on your device"
              control={<Toggle checked={settings.notifications} onChange={() => toggle("notifications")} />}
            />
            <SettingRow
              icon={<span className="text-red-400 text-sm">🔥</span>}
              label="Heat Risk Alerts"
              description="Alert when risk exceeds your threshold"
              control={<Toggle checked={settings.heatAlerts} onChange={() => toggle("heatAlerts")} />}
            />
            <SettingRow
              icon={<span className="text-yellow-400 text-sm">☀️</span>}
              label="UV Index Alerts"
              description="Alert when UV reaches Very High or Extreme"
              control={<Toggle checked={settings.uvAlerts} onChange={() => toggle("uvAlerts")} />}
            />
            <SettingRow
              icon={<span className="text-blue-400 text-sm">📊</span>}
              label="Weekly Report"
              description="Sunday summary of your week's risk data"
              control={<Toggle checked={settings.weeklyReport} onChange={() => toggle("weeklyReport")} />}
            />
            <SettingRow
              icon={<BellOff className="w-4 h-4 text-[var(--text-muted)]" />}
              label="Sound Alerts"
              description="Play sound for critical alerts"
              control={<Toggle checked={settings.soundAlerts} onChange={() => toggle("soundAlerts")} />}
            />
          </Section>

          {/* Units */}
          <Section title="Units & Localization">
            <SettingRow
              icon={<Thermometer className="w-4 h-4 text-orange-400" />}
              label="Temperature Unit"
              description="Display temperatures in Celsius or Fahrenheit"
              control={
                <div className="flex rounded-xl overflow-hidden border border-[var(--border-primary)]">
                  {(["celsius", "fahrenheit"] as const).map((unit) => (
                    <button
                      key={unit}
                      onClick={() => setSettings((s) => ({ ...s, tempUnit: unit }))}
                      className={cn(
                        "px-3 py-1.5 text-xs font-semibold transition-colors",
                        settings.tempUnit === unit
                          ? "bg-orange-500 text-white"
                          : "text-[var(--text-secondary)] hover:bg-[var(--bg-tertiary)]"
                      )}
                    >
                      {unit === "celsius" ? "°C" : "°F"}
                    </button>
                  ))}
                </div>
              }
            />
            <SettingRow
              icon={<Wind className="w-4 h-4 text-cyan-400" />}
              label="Wind Speed Unit"
              control={
                <div className="flex rounded-xl overflow-hidden border border-[var(--border-primary)]">
                  {(["kmh", "mph"] as const).map((unit) => (
                    <button
                      key={unit}
                      onClick={() => setSettings((s) => ({ ...s, windUnit: unit }))}
                      className={cn(
                        "px-3 py-1.5 text-xs font-semibold transition-colors",
                        settings.windUnit === unit
                          ? "bg-orange-500 text-white"
                          : "text-[var(--text-secondary)] hover:bg-[var(--bg-tertiary)]"
                      )}
                    >
                      {unit === "kmh" ? "km/h" : "mph"}
                    </button>
                  ))}
                </div>
              }
            />
            <SettingRow
              icon={<Globe className="w-4 h-4 text-blue-400" />}
              label="Language"
              control={
                <select
                  value={settings.language}
                  onChange={(e) => setSettings((s) => ({ ...s, language: e.target.value }))}
                  className="text-xs font-medium px-3 py-1.5 rounded-xl bg-[var(--bg-tertiary)] border border-[var(--border-primary)] text-[var(--text-primary)]"
                >
                  <option value="en">English</option>
                  <option value="ta">தமிழ் (Tamil)</option>
                  <option value="hi">हिन्दी (Hindi)</option>
                  <option value="te">తెలుగు (Telugu)</option>
                </select>
              }
            />
          </Section>

          {/* Privacy */}
          <Section title="Privacy & Data">
            <SettingRow
              icon={<Shield className="w-4 h-4 text-green-400" />}
              label="Location Access"
              description="Allow app to use your current location"
              control={<Toggle checked={settings.locationAccess} onChange={() => toggle("locationAccess")} />}
            />
            <SettingRow
              icon={<span className="text-sm">📈</span>}
              label="Usage Analytics"
              description="Share anonymized usage data to improve the app"
              control={<Toggle checked={settings.dataCollection} onChange={() => toggle("dataCollection")} />}
            />
            <div className="flex gap-3 pt-1">
              <button className="btn-secondary text-xs flex items-center gap-2">
                <Download className="w-3.5 h-3.5" />
                Export My Data
              </button>
              <button className="flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-semibold text-red-400 border border-red-500/20 hover:bg-red-500/10 transition-colors">
                <Trash2 className="w-3.5 h-3.5" />
                Delete Account
              </button>
            </div>
          </Section>

          {/* About */}
          <div className="card p-4 text-center">
            <p className="text-xs text-[var(--text-muted)]">
              Escape Heat v1.0.0 · AI-Powered Urban Heat Intelligence
            </p>
            <p className="text-[10px] text-[var(--text-muted)] mt-1">
              Built for the Gen AI Cohort Hackathon 2026
            </p>
          </div>
        </div>
      </div>
    </AppShell>
  );
}
