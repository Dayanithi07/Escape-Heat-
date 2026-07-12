# Escape Heat — AI Urban Heat Decision Intelligence Platform

> **Frontend Module** · Production-ready UI with mock data · Next.js 16 + React + Tailwind CSS v4 · Deployed on Vercel

---

## 🚀 Quick Start

```bash
cd escape-heat
npm install
npm run dev       # http://localhost:3000
npm run build     # Production build
```

---

## 📁 Project Structure

```
escape-heat/
├── app/
│   ├── layout.tsx              # Root layout (theme provider, SEO metadata)
│   ├── page.tsx                # Landing page
│   ├── dashboard/page.tsx      # Heat dashboard
│   ├── heatmap/page.tsx        # Interactive heat map
│   ├── assistant/page.tsx      # AI chat assistant
│   ├── recommendations/page.tsx
│   ├── profile/page.tsx
│   ├── settings/page.tsx
│   ├── not-found.tsx           # Custom 404
│   ├── providers.tsx           # next-themes provider
│   └── globals.css             # Design system + Tailwind v4 theme
│
├── components/
│   ├── layout/
│   │   ├── AppShell.tsx        # Sidebar + Navbar wrapper
│   │   ├── Navbar.tsx          # Sticky top bar with theme toggle
│   │   └── Sidebar.tsx         # Collapsible navigation sidebar
│   ├── ui/
│   │   ├── RiskBadge.tsx       # Color-coded risk level badges
│   │   ├── RiskIndicator.tsx   # SVG circular risk gauge
│   │   ├── StatCard.tsx        # Metric cards with trend indicators
│   │   ├── LoadingSkeleton.tsx # Shimmer loading states
│   │   └── States.tsx          # EmptyState + ErrorState
│   ├── charts/
│   │   ├── TemperatureChart.tsx # 24h dual-line chart
│   │   ├── HumidityChart.tsx    # Humidity + UV dual-axis chart
│   │   └── RiskTrendChart.tsx   # 7-day risk bar chart
│   ├── map/
│   │   └── HeatMapContainer.tsx # Leaflet map (dynamic import, no SSR)
│   ├── chat/
│   │   └── ChatWindow.tsx       # AI chat UI with typing animation
│   └── recommendations/
│       └── RecommendationCard.tsx
│
├── lib/
│   ├── mock-data/
│   │   ├── weather.ts          # Current conditions + 24h + 7-day data
│   │   ├── heatmap.ts          # Heat zones + POI coordinates (Chennai)
│   │   ├── recommendations.ts  # 10 categorized recommendations
│   │   ├── chat.ts             # AI response pairs + quick prompts
│   │   └── profile.ts          # User profile mock data
│   └── utils.ts                # cn(), risk colors, temperature formatting
│
├── types/
│   └── index.ts                # All TypeScript interfaces
│
└── tailwind.config.ts
```

---

## 🎨 Design System

- **Theme**: Dark by default, toggleable to light via navbar
- **Primary Color**: Orange (`#f97316`) — heat brand color
- **Risk Colors**: Green (Low) → Yellow (Moderate) → Orange (High) → Red (Extreme)
- **Typography**: Inter (body) + Outfit (headings) from Google Fonts
- **Border radius**: 12px cards, 8–10px buttons, 16px larger containers
- **Animations**: fade-in, slide-up, shimmer, bounce-subtle, pulse

---

## 📄 Pages

| Route | Page | Features |
|-------|------|---------|
| `/` | Landing | Hero, features, how-it-works, CTA |
| `/dashboard` | Dashboard | Risk gauge, 6 stat cards, 3 charts, 7-day view |
| `/heatmap` | Heat Map | Leaflet map, heat zones, POI markers, filters |
| `/assistant` | AI Assistant | Chat UI, quick prompts, typing animation |
| `/recommendations` | Recommendations | 10 cards, category/priority filters |
| `/profile` | Profile | Editable info, health selector, locations |
| `/settings` | Settings | Theme, notifications, units, privacy |
| `*` | 404 | Custom not-found with navigation |

---

## 🔌 Backend Integration Notes

All data lives in `lib/mock-data/`. To integrate with the FastAPI backend:

1. **Replace mock functions** in each `lib/mock-data/*.ts` file with API calls
2. **Add React Query / SWR** for data fetching and caching
3. **Add Supabase Auth** — wrap the AppShell with an auth guard
4. **Environment variables**: Add `NEXT_PUBLIC_API_URL`, `NEXT_PUBLIC_SUPABASE_URL`, etc.

The interface types in `types/index.ts` are designed to match the Supabase schema defined in the database module.

---

## ⚙️ Technology Stack

| Tool | Version | Purpose |
|------|---------|---------|
| Next.js | 16.2.10 | Framework (App Router) |
| React | 19.2 | UI library |
| Tailwind CSS | 4.x | Styling |
| Chart.js + react-chartjs-2 | 4.x | Data visualizations |
| Leaflet + react-leaflet | 1.9 / 5.x | Interactive map |
| next-themes | 0.4 | Dark/light theme |
| lucide-react | Latest | Icons |
| TypeScript | 5.x | Type safety |
