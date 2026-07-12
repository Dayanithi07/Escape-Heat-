import Link from "next/link";
import type { Metadata } from "next";
import {
  Flame,
  BarChart2,
  Map,
  MessageSquare,
  Lightbulb,
  Shield,
  Zap,
  Globe,
  ArrowRight,
  ChevronRight,
  Thermometer,
  Droplets,
  Wind,
  Sun,
} from "lucide-react";

export const metadata: Metadata = {
  title: "Escape Heat — AI Urban Heat Decision Intelligence",
  description:
    "Convert real-time environmental data into personalized heat safety recommendations powered by AI.",
};

const features = [
  {
    icon: BarChart2,
    title: "Heat Intelligence Dashboard",
    description:
      "Real-time heat risk scores, temperature, humidity, UV index, AQI, and wind data — all in one actionable view.",
    color: "#f97316",
  },
  {
    icon: Map,
    title: "Interactive Heat Map",
    description:
      "Visualize urban heat islands, find nearby parks, cooling centers, hospitals, and water stations on a live map.",
    color: "#ef4444",
  },
  {
    icon: MessageSquare,
    title: "Escape AI Assistant",
    description:
      "Ask natural language questions — 'Is it safe to jog?' — and get context-aware answers powered by environmental AI.",
    color: "#a855f7",
  },
  {
    icon: Lightbulb,
    title: "Smart Recommendations",
    description:
      "Personalized, prioritized action items for hydration, activity, clothing, health, travel, and optimal timing.",
    color: "#eab308",
  },
  {
    icon: Shield,
    title: "Risk Assessment",
    description:
      "Deterministic heat risk scoring (0–100) calculated from temperature, humidity, UV index, and personal health factors.",
    color: "#22c55e",
  },
  {
    icon: Globe,
    title: "Community Intelligence",
    description:
      "Community heat exposure data helps city planners and authorities prioritize urban cooling interventions.",
    color: "#3b82f6",
  },
];

const stats = [
  { value: "38°C", label: "Current Temperature", icon: Thermometer, color: "#f97316" },
  { value: "72%", label: "Relative Humidity", icon: Droplets, color: "#3b82f6" },
  { value: "14 km/h", label: "Wind Speed", icon: Wind, color: "#06b6d4" },
  { value: "UV 9", label: "UV Index (Very High)", icon: Sun, color: "#eab308" },
];

const targetUsers = [
  { icon: "🧑‍💻", label: "Citizens" },
  { icon: "👷", label: "Outdoor Workers" },
  { icon: "👴", label: "Elderly People" },
  { icon: "❤️", label: "Vulnerable Groups" },
  { icon: "🏢", label: "Organizations" },
  { icon: "🏛️", label: "City Authorities" },
];

export default function LandingPage() {
  return (
    <div className="min-h-screen bg-[var(--bg-primary)]">
      {/* Navbar */}
      <header className="sticky top-0 z-50 border-b border-[var(--border-primary)] backdrop-blur-md" style={{ backgroundColor: "var(--navbar-bg)" }}>
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex items-center justify-between h-16">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-orange-500 to-red-500 flex items-center justify-center shadow-heat">
              <Flame className="w-4 h-4 text-white" />
            </div>
            <span className="font-display font-bold text-[var(--text-primary)]">
              Escape <span className="text-gradient">Heat</span>
            </span>
          </div>
          <nav className="hidden md:flex items-center gap-6 text-sm text-[var(--text-secondary)]">
            <a href="#features" className="hover:text-orange-400 transition-colors">Features</a>
            <a href="#how-it-works" className="hover:text-orange-400 transition-colors">How It Works</a>
            <a href="#users" className="hover:text-orange-400 transition-colors">Who It&apos;s For</a>
          </nav>
          <Link href="/dashboard" className="btn-primary text-sm">
            Open Dashboard <ArrowRight className="w-4 h-4" />
          </Link>
        </div>
      </header>

      {/* Hero Section */}
      <section className="relative overflow-hidden py-24 lg:py-36">
        {/* Background gradients */}
        <div className="absolute inset-0 bg-[var(--bg-primary)]" />
        <div className="absolute top-0 left-1/4 w-96 h-96 bg-orange-500/10 rounded-full blur-3xl" />
        <div className="absolute bottom-0 right-1/4 w-96 h-96 bg-red-500/8 rounded-full blur-3xl" />
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-orange-500/5 rounded-full blur-3xl" />

        <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          {/* Alert Badge */}
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-orange-500/10 border border-orange-500/25 text-orange-400 text-sm font-medium mb-8 animate-bounce-subtle">
            <span className="w-2 h-2 rounded-full bg-orange-500 animate-pulse" />
            Heat Risk Alert Active · Chennai · Score 78/100
            <ChevronRight className="w-4 h-4" />
          </div>

          <h1 className="font-display font-bold text-5xl sm:text-6xl lg:text-7xl text-[var(--text-primary)] leading-tight mb-6">
            Stay Safe in the{" "}
            <span className="text-gradient">Urban Heat</span>
          </h1>

          <p className="text-lg lg:text-xl text-[var(--text-secondary)] max-w-3xl mx-auto mb-10 leading-relaxed">
            Escape Heat converts real-time environmental data into personalized,
            AI-powered recommendations — so you know exactly what to do during
            extreme heat conditions.
          </p>

          <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
            <Link href="/dashboard" className="btn-primary text-base px-8 py-3">
              <Zap className="w-5 h-5" />
              Open Dashboard
            </Link>
            <Link href="/assistant" className="btn-secondary text-base px-8 py-3">
              <MessageSquare className="w-5 h-5" />
              Ask Escape AI
            </Link>
          </div>

          {/* Live stats */}
          <div className="mt-16 grid grid-cols-2 md:grid-cols-4 gap-4 max-w-3xl mx-auto">
            {stats.map((stat) => {
              const Icon = stat.icon;
              return (
                <div
                  key={stat.label}
                  className="card p-4 text-center hover:-translate-y-1 transition-transform"
                >
                  <Icon className="w-6 h-6 mx-auto mb-2" style={{ color: stat.color }} />
                  <div className="text-2xl font-display font-bold" style={{ color: stat.color }}>
                    {stat.value}
                  </div>
                  <div className="text-xs text-[var(--text-muted)] mt-1">{stat.label}</div>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* How It Works */}
      <section id="how-it-works" className="py-20 border-t border-[var(--border-primary)]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-12">
            <h2 className="font-display font-bold text-3xl lg:text-4xl text-[var(--text-primary)] mb-4">
              How Escape Heat Works
            </h2>
            <p className="text-[var(--text-secondary)] max-w-xl mx-auto">
              A deterministic AI pipeline that turns raw environmental data into actionable intelligence
            </p>
          </div>

          <div className="flex flex-col md:flex-row items-center justify-center gap-0">
            {[
              { step: "01", label: "Collect Data", desc: "Weather APIs, satellite data, environmental sensors", icon: "📡" },
              { step: "02", label: "Analyze Conditions", desc: "Temperature, humidity, UV, AQI, wind patterns", icon: "🔬" },
              { step: "03", label: "Calculate Risk", desc: "Deterministic heat risk score (0–100)", icon: "📊" },
              { step: "04", label: "Generate Insights", desc: "AI explains conditions in plain language", icon: "🤖" },
              { step: "05", label: "Recommend Actions", desc: "Personalized, prioritized safety guidance", icon: "✅" },
            ].map((item, i) => (
              <div key={i} className="flex items-center">
                <div className="flex flex-col items-center text-center p-6 max-w-[180px]">
                  <div className="text-3xl mb-3">{item.icon}</div>
                  <div className="text-xs font-bold text-orange-500 mb-1">{item.step}</div>
                  <div className="font-semibold text-sm text-[var(--text-primary)] mb-1">{item.label}</div>
                  <div className="text-xs text-[var(--text-muted)]">{item.desc}</div>
                </div>
                {i < 4 && (
                  <ArrowRight className="w-5 h-5 text-[var(--border-secondary)] flex-shrink-0 hidden md:block" />
                )}
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Features */}
      <section id="features" className="py-20 border-t border-[var(--border-primary)]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-12">
            <h2 className="font-display font-bold text-3xl lg:text-4xl text-[var(--text-primary)] mb-4">
              Everything You Need to Beat the Heat
            </h2>
            <p className="text-[var(--text-secondary)] max-w-xl mx-auto">
              Six powerful modules working together to keep you safe
            </p>
          </div>

          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
            {features.map((feature) => {
              const Icon = feature.icon;
              return (
                <div
                  key={feature.title}
                  className="card p-6 group hover:-translate-y-1 transition-all duration-200 hover:shadow-card-dark"
                >
                  <div
                    className="w-12 h-12 rounded-2xl flex items-center justify-center mb-4"
                    style={{ backgroundColor: `${feature.color}15` }}
                  >
                    <Icon className="w-6 h-6" style={{ color: feature.color }} />
                  </div>
                  <h3 className="font-display font-semibold text-base text-[var(--text-primary)] mb-2">
                    {feature.title}
                  </h3>
                  <p className="text-sm text-[var(--text-secondary)] leading-relaxed">
                    {feature.description}
                  </p>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* Target Users */}
      <section id="users" className="py-20 border-t border-[var(--border-primary)]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="font-display font-bold text-3xl lg:text-4xl text-[var(--text-primary)] mb-4">
            Built for Everyone at Risk
          </h2>
          <p className="text-[var(--text-secondary)] mb-10">
            From individual citizens to city planners — Escape Heat adapts to your needs
          </p>
          <div className="flex flex-wrap justify-center gap-4">
            {targetUsers.map((user) => (
              <div
                key={user.label}
                className="flex items-center gap-2 px-5 py-3 rounded-2xl card hover:-translate-y-0.5 transition-transform"
              >
                <span className="text-2xl">{user.icon}</span>
                <span className="font-medium text-sm text-[var(--text-primary)]">{user.label}</span>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="py-20 border-t border-[var(--border-primary)]">
        <div className="max-w-3xl mx-auto px-4 text-center">
          <div className="relative rounded-3xl overflow-hidden p-12 bg-gradient-to-br from-orange-500/15 to-red-500/10 border border-orange-500/20">
            <div className="absolute inset-0 bg-noise opacity-30" />
            <div className="relative">
              <div className="text-4xl mb-4">🌡️</div>
              <h2 className="font-display font-bold text-3xl text-[var(--text-primary)] mb-4">
                Don&apos;t Wait for the Heat to Hit
              </h2>
              <p className="text-[var(--text-secondary)] mb-8">
                Check your real-time risk score, explore the heat map, and get AI-powered guidance — right now.
              </p>
              <Link href="/dashboard" className="btn-primary text-base px-10 py-3.5">
                <Zap className="w-5 h-5" />
                Get Started Free
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t border-[var(--border-primary)] py-8">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex flex-col sm:flex-row items-center justify-between gap-4 text-sm text-[var(--text-muted)]">
          <div className="flex items-center gap-2">
            <Flame className="w-4 h-4 text-orange-500" />
            <span>Escape Heat — AI Urban Heat Intelligence Platform</span>
          </div>
          <div className="flex items-center gap-6">
            <Link href="/dashboard" className="hover:text-orange-400 transition-colors">Dashboard</Link>
            <Link href="/heatmap" className="hover:text-orange-400 transition-colors">Heat Map</Link>
            <Link href="/assistant" className="hover:text-orange-400 transition-colors">AI Assistant</Link>
          </div>
        </div>
      </footer>
    </div>
  );
}
