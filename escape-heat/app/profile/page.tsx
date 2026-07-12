"use client";

import { useState } from "react";
import AppShell from "@/components/layout/AppShell";
import { mockProfile, healthCategories, activityStats } from "@/lib/mock-data/profile";
import { MapPin, Calendar, Edit3, Check, Plus, X } from "lucide-react";
import { formatDate } from "@/lib/utils";
import { cn } from "@/lib/utils";

export default function ProfilePage() {
  const [profile, setProfile] = useState(mockProfile);
  const [editingName, setEditingName] = useState(false);
  const [nameInput, setNameInput] = useState(profile.name);

  return (
    <AppShell>
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <h1 className="font-display font-bold text-2xl text-[var(--text-primary)] mb-6">
          My Profile
        </h1>

        <div className="grid lg:grid-cols-3 gap-5">
          {/* Left Column */}
          <div className="flex flex-col gap-4">
            {/* Avatar Card */}
            <div className="card p-6 flex flex-col items-center text-center">
              <div className="relative mb-4">
                <div className="w-20 h-20 rounded-2xl bg-gradient-to-br from-orange-500 to-red-500 flex items-center justify-center text-white text-2xl font-bold shadow-heat">
                  {profile.avatar}
                </div>
                <button className="absolute -bottom-1 -right-1 w-6 h-6 rounded-full bg-[var(--bg-card)] border border-[var(--border-primary)] flex items-center justify-center text-[var(--text-muted)] hover:text-orange-400 transition-colors">
                  <Edit3 className="w-3 h-3" />
                </button>
              </div>

              {editingName ? (
                <div className="flex items-center gap-2 mb-1">
                  <input
                    value={nameInput}
                    onChange={(e) => setNameInput(e.target.value)}
                    className="text-center text-sm font-semibold bg-[var(--bg-tertiary)] border border-orange-500/50 rounded-lg px-2 py-1 text-[var(--text-primary)] focus:outline-none w-36"
                  />
                  <button
                    onClick={() => { setProfile((p) => ({ ...p, name: nameInput })); setEditingName(false); }}
                    className="text-green-400 hover:text-green-300"
                  >
                    <Check className="w-4 h-4" />
                  </button>
                </div>
              ) : (
                <div className="flex items-center gap-2 mb-1">
                  <h2 className="text-base font-semibold text-[var(--text-primary)]">{profile.name}</h2>
                  <button onClick={() => setEditingName(true)} className="text-[var(--text-muted)] hover:text-orange-400 transition-colors">
                    <Edit3 className="w-3.5 h-3.5" />
                  </button>
                </div>
              )}

              <p className="text-xs text-[var(--text-muted)]">{profile.email}</p>
              <div className="flex items-center gap-1.5 mt-2 text-xs text-[var(--text-muted)]">
                <MapPin className="w-3 h-3 text-orange-500" />
                <span>{profile.location.city}, {profile.location.state}</span>
              </div>
              <div className="flex items-center gap-1.5 mt-1 text-xs text-[var(--text-muted)]">
                <Calendar className="w-3 h-3" />
                <span>Joined {formatDate(profile.joinedDate)}</span>
              </div>
            </div>

            {/* Activity Stats */}
            <div className="card p-4">
              <p className="text-xs font-semibold text-[var(--text-muted)] uppercase tracking-wide mb-3">
                Activity Stats
              </p>
              <div className="grid grid-cols-2 gap-3">
                {activityStats.map((stat) => (
                  <div key={stat.label} className="text-center p-3 rounded-xl bg-[var(--bg-tertiary)]">
                    <p className="text-xl mb-0.5">{stat.icon}</p>
                    <p className="text-lg font-bold font-display text-[var(--text-primary)]">{stat.value}</p>
                    <p className="text-[10px] text-[var(--text-muted)]">{stat.label}</p>
                  </div>
                ))}
              </div>
            </div>

            {/* Saved Locations */}
            <div className="card p-4">
              <p className="text-xs font-semibold text-[var(--text-muted)] uppercase tracking-wide mb-3">
                Saved Locations
              </p>
              <div className="space-y-2">
                <div className="flex items-center gap-2 p-2 rounded-xl bg-orange-500/10 border border-orange-500/20">
                  <MapPin className="w-3.5 h-3.5 text-orange-500 flex-shrink-0" />
                  <div className="min-w-0 flex-1">
                    <p className="text-xs font-semibold text-orange-400 truncate">
                      {profile.location.city} (Current)
                    </p>
                    <p className="text-[10px] text-[var(--text-muted)]">{profile.location.state}</p>
                  </div>
                </div>
                {profile.savedLocations.map((loc) => (
                  <div key={loc.city} className="flex items-center gap-2 p-2 rounded-xl hover:bg-[var(--bg-tertiary)] transition-colors group">
                    <MapPin className="w-3.5 h-3.5 text-[var(--text-muted)] flex-shrink-0" />
                    <div className="min-w-0 flex-1">
                      <p className="text-xs font-medium text-[var(--text-primary)] truncate">{loc.city}</p>
                      <p className="text-[10px] text-[var(--text-muted)]">{loc.state}</p>
                    </div>
                    <button className="opacity-0 group-hover:opacity-100 text-[var(--text-muted)] hover:text-red-400 transition-all">
                      <X className="w-3.5 h-3.5" />
                    </button>
                  </div>
                ))}
                <button className="w-full flex items-center justify-center gap-2 p-2 rounded-xl border border-dashed border-[var(--border-primary)] text-xs text-[var(--text-muted)] hover:border-orange-500/50 hover:text-orange-400 transition-all">
                  <Plus className="w-3.5 h-3.5" />
                  Add Location
                </button>
              </div>
            </div>
          </div>

          {/* Right Column */}
          <div className="lg:col-span-2 flex flex-col gap-4">
            {/* Personal Info */}
            <div className="card p-5">
              <h3 className="text-sm font-semibold text-[var(--text-primary)] mb-4">Personal Information</h3>
              <div className="grid sm:grid-cols-2 gap-4">
                {[
                  { label: "Full Name", value: profile.name, type: "text" },
                  { label: "Email Address", value: profile.email, type: "email" },
                  { label: "Age", value: String(profile.age), type: "number" },
                  { label: "Occupation", value: profile.occupation, type: "text" },
                ].map((field) => (
                  <div key={field.label}>
                    <label className="block text-xs font-medium text-[var(--text-muted)] mb-1.5">
                      {field.label}
                    </label>
                    <input
                      type={field.type}
                      defaultValue={field.value}
                      className="w-full px-3 py-2 text-sm rounded-xl bg-[var(--bg-tertiary)] border border-[var(--border-primary)] text-[var(--text-primary)] focus:outline-none focus:border-orange-500/60 transition-colors"
                    />
                  </div>
                ))}
              </div>
            </div>

            {/* Health Profile */}
            <div className="card p-5">
              <h3 className="text-sm font-semibold text-[var(--text-primary)] mb-1">Health Profile</h3>
              <p className="text-xs text-[var(--text-muted)] mb-4">
                Helps personalize heat risk calculations and recommendations
              </p>
              <div className="grid sm:grid-cols-2 gap-3">
                {healthCategories.map((cat) => (
                  <button
                    key={cat.id}
                    onClick={() => setProfile((p) => ({ ...p, healthCategory: cat.id as typeof p.healthCategory }))}
                    className={cn(
                      "flex items-center gap-3 p-3 rounded-xl border text-left transition-all",
                      profile.healthCategory === cat.id
                        ? "border-orange-500 bg-orange-500/10"
                        : "border-[var(--border-primary)] hover:border-[var(--border-secondary)]"
                    )}
                  >
                    <span className="text-2xl">{cat.icon}</span>
                    <div>
                      <p className={cn(
                        "text-xs font-semibold",
                        profile.healthCategory === cat.id ? "text-orange-400" : "text-[var(--text-primary)]"
                      )}>
                        {cat.label}
                      </p>
                      <p className="text-[10px] text-[var(--text-muted)] mt-0.5">{cat.description}</p>
                    </div>
                    {profile.healthCategory === cat.id && (
                      <Check className="w-4 h-4 text-orange-400 ml-auto flex-shrink-0" />
                    )}
                  </button>
                ))}
              </div>
            </div>

            {/* Alert Threshold */}
            <div className="card p-5">
              <h3 className="text-sm font-semibold text-[var(--text-primary)] mb-1">Alert Threshold</h3>
              <p className="text-xs text-[var(--text-muted)] mb-4">
                Receive alerts when risk reaches or exceeds this level
              </p>
              <div className="flex gap-3">
                {(["low", "moderate", "high", "extreme"] as const).map((level) => (
                  <button
                    key={level}
                    onClick={() => setProfile((p) => ({ ...p, alertThreshold: level }))}
                    className={cn(
                      "flex-1 py-2 rounded-xl text-xs font-semibold capitalize border transition-all",
                      profile.alertThreshold === level
                        ? level === "low" ? "bg-green-500 text-white border-green-500"
                          : level === "moderate" ? "bg-yellow-500 text-white border-yellow-500"
                          : level === "high" ? "bg-orange-500 text-white border-orange-500"
                          : "bg-red-500 text-white border-red-500"
                        : "border-[var(--border-primary)] text-[var(--text-secondary)] hover:border-[var(--border-secondary)]"
                    )}
                  >
                    {level}
                  </button>
                ))}
              </div>
            </div>

            {/* Save Button */}
            <button className="btn-primary self-end px-8">
              <Check className="w-4 h-4" />
              Save Profile
            </button>
          </div>
        </div>
      </div>
    </AppShell>
  );
}
