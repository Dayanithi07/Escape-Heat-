"use client";

import AppShell from "@/components/layout/AppShell";
import ChatWindow from "@/components/chat/ChatWindow";
import { Bot, Zap, Shield, Clock } from "lucide-react";

const capabilities = [
  { icon: Zap, label: "Heat Risk Analysis", desc: "Real-time risk assessment" },
  { icon: Shield, label: "Safety Guidance", desc: "Personalized recommendations" },
  { icon: Clock, label: "Timing Advice", desc: "Best hours for activities" },
  { icon: Bot, label: "Context-Aware", desc: "Uses environmental data" },
];

export default function AssistantPage() {
  return (
    <AppShell>
      <div className="flex flex-col lg:flex-row gap-5 h-[calc(100vh-5rem)]">
        {/* Sidebar Info */}
        <div className="lg:w-72 flex-shrink-0 flex flex-col gap-4">
          {/* AI Identity Card */}
          <div className="card p-5">
            <div className="flex items-center gap-3 mb-4">
              <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-orange-500 to-red-500 flex items-center justify-center shadow-heat">
                <Bot className="w-6 h-6 text-white" />
              </div>
              <div>
                <h2 className="font-display font-bold text-base text-[var(--text-primary)]">
                  Escape AI
                </h2>
                <div className="flex items-center gap-1.5 mt-0.5">
                  <span className="w-2 h-2 rounded-full bg-green-500 animate-pulse" />
                  <span className="text-xs text-green-400 font-medium">Online</span>
                </div>
              </div>
            </div>
            <p className="text-xs text-[var(--text-secondary)] leading-relaxed">
              Your personal urban heat intelligence assistant. I analyze current
              environmental conditions and provide context-aware safety guidance.
            </p>
          </div>

          {/* Current Context */}
          <div className="card p-4">
            <p className="text-xs font-semibold text-[var(--text-muted)] uppercase tracking-wide mb-3">
              Current Context
            </p>
            <div className="space-y-2 text-xs">
              {[
                ["📍 Location", "Chennai, Tamil Nadu"],
                ["🌡️ Temperature", "38°C (Feels 43°C)"],
                ["💧 Humidity", "72%"],
                ["☀️ UV Index", "9 — Very High"],
                ["🌫️ AQI", "118 — Moderate"],
                ["⚠️ Risk Score", "78/100 (High)"],
              ].map(([label, val]) => (
                <div key={label} className="flex justify-between">
                  <span className="text-[var(--text-muted)]">{label}</span>
                  <span className="text-[var(--text-primary)] font-medium">{val}</span>
                </div>
              ))}
            </div>
          </div>

          {/* Capabilities */}
          <div className="card p-4">
            <p className="text-xs font-semibold text-[var(--text-muted)] uppercase tracking-wide mb-3">
              Capabilities
            </p>
            <div className="space-y-2">
              {capabilities.map((cap) => {
                const Icon = cap.icon;
                return (
                  <div key={cap.label} className="flex items-center gap-2">
                    <div className="w-7 h-7 rounded-lg bg-orange-500/10 flex items-center justify-center flex-shrink-0">
                      <Icon className="w-3.5 h-3.5 text-orange-500" />
                    </div>
                    <div>
                      <p className="text-xs font-medium text-[var(--text-primary)]">{cap.label}</p>
                      <p className="text-[10px] text-[var(--text-muted)]">{cap.desc}</p>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>

        {/* Chat Panel */}
        <div className="flex-1 card flex flex-col min-h-0 overflow-hidden">
          <div className="flex items-center gap-3 px-4 py-3 border-b border-[var(--border-primary)] flex-shrink-0">
            <div className="w-8 h-8 rounded-xl bg-gradient-to-br from-orange-500 to-red-500 flex items-center justify-center">
              <Bot className="w-4 h-4 text-white" />
            </div>
            <div className="flex-1">
              <p className="text-sm font-semibold text-[var(--text-primary)]">Escape AI Assistant</p>
              <p className="text-xs text-[var(--text-muted)]">Heat intelligence · Powered by environmental data</p>
            </div>
            <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-green-500/10 border border-green-500/20">
              <span className="w-1.5 h-1.5 rounded-full bg-green-500 animate-pulse" />
              <span className="text-[10px] font-semibold text-green-400">Active</span>
            </div>
          </div>
          <div className="flex-1 min-h-0">
            <ChatWindow />
          </div>
        </div>
      </div>
    </AppShell>
  );
}
