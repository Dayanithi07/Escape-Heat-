import type { Recommendation } from "@/types";

export const recommendations: Recommendation[] = [
  // ─── Hydration ────────────────────────────────────────────────
  {
    id: "rec_001",
    category: "hydration",
    title: "Increase Water Intake Immediately",
    description:
      "Current heat index of 47°C demands aggressive hydration. Dehydration risk is critically elevated at current temperatures.",
    priority: "urgent",
    icon: "💧",
    actionItems: [
      "Drink at least 500ml of water every hour",
      "Add ORS (Oral Rehydration Salts) to one glass per day",
      "Avoid caffeinated beverages — they accelerate dehydration",
      "Carry a 1-litre insulated bottle at all times",
      "Set a phone reminder every 45 minutes to hydrate",
    ],
    riskLevel: "high",
  },
  {
    id: "rec_002",
    category: "hydration",
    title: "Electrolyte Replenishment",
    description:
      "Sweating in high humidity causes rapid loss of sodium and potassium. Replace electrolytes proactively.",
    priority: "important",
    icon: "🥤",
    actionItems: [
      "Consume coconut water, nimbu pani, or ORS",
      "Eat foods rich in potassium (banana, curd)",
      "Avoid sugary sports drinks — they worsen dehydration",
      "Monitor urine color — dark yellow indicates dehydration",
    ],
    riskLevel: "moderate",
  },
  // ─── Activity ─────────────────────────────────────────────────
  {
    id: "rec_003",
    category: "activity",
    title: "Avoid Outdoor Exercise Between 10 AM – 5 PM",
    description:
      "UV Index of 9 (Very High) and peak heat hours make outdoor activity dangerous. Risk of heat stroke is significant.",
    priority: "urgent",
    icon: "🚶",
    actionItems: [
      "Postpone runs, walks, or sports to 6 AM–9 AM or after 6 PM",
      "If exercising outdoors, limit sessions to 20 minutes maximum",
      "Take 10-minute shaded breaks every 15 minutes",
      "Stop immediately if you feel dizzy, nauseated, or faint",
    ],
    validUntil: "5:00 PM today",
    riskLevel: "high",
  },
  {
    id: "rec_004",
    category: "activity",
    title: "Optimal Jogging Window: 6:00–8:00 AM",
    description:
      "Early morning hours have the lowest temperature (27°C), lowest UV, and highest humidity for running safely.",
    priority: "advisory",
    icon: "🏃",
    actionItems: [
      "Start run before 6:30 AM for best conditions",
      "Stay on shaded routes (Semmozhi Poonga, Marina walkway)",
      "Hydrate 500ml 30 minutes before starting",
      "Wear moisture-wicking, light-colored clothing",
    ],
    riskLevel: "low",
  },
  // ─── Clothing ─────────────────────────────────────────────────
  {
    id: "rec_005",
    category: "clothing",
    title: "Dress for Heat Protection",
    description:
      "Clothing choices significantly impact heat absorption. Light-colored, breathable fabrics reduce heat stress by up to 5°C (perceived).",
    priority: "important",
    icon: "👕",
    actionItems: [
      "Wear loose, light-colored (white/cream) cotton clothing",
      "Use a wide-brimmed hat or cap when outdoors",
      "Apply SPF 50+ sunscreen on exposed skin — reapply every 2 hours",
      "Carry a UV-protective umbrella",
      "Avoid dark, synthetic, or tight-fitting clothes",
    ],
    riskLevel: "moderate",
  },
  // ─── Health ───────────────────────────────────────────────────
  {
    id: "rec_006",
    category: "health",
    title: "Watch for Heat Stroke Warning Signs",
    description:
      "At current conditions, heat stroke risk is elevated. Know the signs and act immediately.",
    priority: "urgent",
    icon: "🏥",
    actionItems: [
      "Warning signs: confusion, slurred speech, rapid heartbeat, no sweating",
      "Call 108 (Emergency) immediately if symptoms appear",
      "Move to cool, shaded area — apply cold wet cloths to neck/armpits",
      "Do NOT give water to an unconscious person",
      "Nearest hospital: Rajiv Gandhi Govt Hospital (0.8 km away)",
    ],
    riskLevel: "extreme",
  },
  {
    id: "rec_007",
    category: "health",
    title: "Medication & Heat Interactions",
    description:
      "Some medications reduce heat tolerance. Consult your doctor if you take blood pressure, diuretic, or psychiatric medications.",
    priority: "important",
    icon: "💊",
    actionItems: [
      "Blood pressure meds may cause dizziness in heat — monitor carefully",
      "Diuretics increase dehydration risk — double fluid intake",
      "Antihistamines and antidepressants reduce sweating capacity",
      "Store medications below 25°C — do not leave in a car",
    ],
    riskLevel: "moderate",
  },
  // ─── Travel ───────────────────────────────────────────────────
  {
    id: "rec_008",
    category: "travel",
    title: "Plan Travel During Cooler Hours",
    description:
      "Surface road temperatures can exceed 55°C in afternoon. Plan commutes strategically to minimize exposure.",
    priority: "important",
    icon: "🚌",
    actionItems: [
      "Travel before 9 AM or after 6 PM when possible",
      "Use shaded bus stops and metro stations",
      "Avoid direct sun exposure while waiting for transport",
      "Keep car cabin cool before entering (open doors, run AC for 2 mins)",
      "NEVER leave children or pets in parked vehicles",
    ],
    riskLevel: "high",
  },
  {
    id: "rec_009",
    category: "travel",
    title: "Use Cooling Centers on Your Route",
    description:
      "Multiple air-conditioned public spaces are available along major Chennai routes for heat relief breaks.",
    priority: "advisory",
    icon: "❄️",
    actionItems: [
      "Central Railway Station Cooling Zone — free access (0.6 km)",
      "Spencer Plaza ground floor — designated cool zone (1.9 km)",
      "Metro stations maintain 22°C — use them as rest stops",
    ],
    riskLevel: "moderate",
  },
  // ─── Timing ───────────────────────────────────────────────────
  {
    id: "rec_010",
    category: "timing",
    title: "Best & Worst Times Today",
    description:
      "Today's risk profile shows extreme risk between 12 PM–4 PM. Plan all essential outdoor tasks outside this window.",
    priority: "important",
    icon: "⏰",
    actionItems: [
      "✅ Safe: Before 9 AM (risk score: 35/100)",
      "⚠️ Caution: 9 AM – 12 PM (risk score: 48–78/100)",
      "🚫 Avoid: 12 PM – 4 PM (risk score: 84–88/100)",
      "✅ Recovering: After 6 PM (risk score: <60/100)",
    ],
    riskLevel: "high",
  },
];

export const categoryLabels: Record<string, string> = {
  all: "All",
  hydration: "Hydration",
  activity: "Activity",
  clothing: "Clothing",
  health: "Health",
  travel: "Travel",
  timing: "Timing",
};
