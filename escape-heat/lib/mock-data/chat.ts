import type { ChatMessage, QuickPrompt } from "@/types";

export const initialMessages: ChatMessage[] = [
  {
    id: "msg_000",
    role: "assistant",
    content:
      "👋 Hi! I'm **Escape AI**, your personal urban heat intelligence assistant.\n\nI'm analyzing current conditions in **Chennai** — temperature is **38°C** with a heat index of **47°C** and UV Index of **9 (Very High)**.\n\nAsk me anything about heat safety, outdoor activity, travel, or local cooling resources. I'm here to help you make safer decisions today.",
    timestamp: new Date(Date.now() - 60000).toISOString(),
  },
];

export const mockResponses: Record<string, string> = {
  jogging:
    "🏃 **Is it safe to jog right now?**\n\nBased on current conditions — **No, jogging right now is not safe.**\n\n**Current Risk Factors:**\n- Temperature: 38°C (feels like 43°C)\n- UV Index: 9 (Very High)\n- Heat Index: 47°C\n- Risk Score: 78/100 (High)\n\n**Safe Jogging Window Today:**\n✅ **6:00 AM – 8:00 AM** — Temperature 28°C, UV Index 2, Risk Score ~25\n✅ **After 7:00 PM** — Temperature drops below 35°C, UV Index 0\n\n**If you must go out now:**\n- Limit to 15 minutes maximum\n- Stay fully shaded\n- Carry 1 litre of water\n- Stop immediately if you feel dizzy",

  walk:
    "🚶 **Is it safe to walk outside?**\n\nA brief walk (< 10 min) in shaded areas is acceptable, but I'd advise caution.\n\n**Current Conditions:**\n- Temperature: 38°C | Feels like: 43°C\n- UV Index: 9 — wear sunscreen and a hat\n- Heat Index: 47°C — danger zone for prolonged exposure\n\n**Tips for your walk:**\n1. Walk in shaded streets only\n2. Carry water and drink before you leave\n3. Wear light-colored, loose clothing\n4. Plan your route near Semmozhi Poonga (1.4 km) for natural shade\n5. Return indoors within 10–15 minutes",

  cooling:
    "❄️ **Nearest Cooling Centers:**\n\n1. **Central Railway Station Cooling Zone** — 0.6 km\n   - Air-conditioned waiting hall, open to all\n   - Free entry during heat advisories\n\n2. **Spencer Plaza Ground Floor** — 1.9 km\n   - Designated cool zone\n   - Open 10 AM – 9 PM\n\n3. **Metro Stations** — Various locations\n   - All Chennai Metro stations maintain ~22°C\n   - Use as rest stops during commute\n\nWould you like directions to any of these locations?",

  hydration:
    "💧 **Hydration Guidance for Today:**\n\nAt 38°C with 72% humidity, you're losing fluids faster than usual.\n\n**Recommended intake today:**\n- Minimum: **3.5–4 litres of water**\n- Add: 1 glass of ORS/coconut water\n\n**Hydration Schedule:**\n- ☀️ Morning: 500ml before 9 AM\n- 🕙 10 AM: 500ml\n- 🕛 12 PM: 500ml + electrolytes\n- 🕑 2 PM: 500ml (peak risk — most important)\n- 🕔 4 PM: 500ml\n- 🌆 Evening: 500ml\n\n**Warning signs of dehydration:**\nDark urine, dry mouth, dizziness, rapid heartbeat",

  heatstroke:
    "🚨 **Heat Stroke — Emergency Information**\n\n**Warning Signs:**\n- Body temperature above 40°C\n- Confusion, slurred speech\n- Dry, hot skin (no sweating)\n- Rapid, strong pulse\n- Loss of consciousness\n\n**Immediate Action:**\n1. **Call 108** (Emergency Services) immediately\n2. Move person to cool, shaded area\n3. Apply cold, wet cloths to neck, armpits, groin\n4. Fan the person vigorously\n5. Do NOT give water if unconscious\n\n**Nearest Hospital:**\n🏥 Rajiv Gandhi Govt Hospital — 0.8 km\n🏥 Apollo Hospital Greams Road — 2.1 km\n\n⚠️ Heat stroke is life-threatening. Act immediately.",

  aqi: "🌫️ **Air Quality Report:**\n\nCurrent AQI: **118** — Unhealthy for Sensitive Groups\n\n**What this means:**\n- Healthy adults: minor discomfort with prolonged outdoor exposure\n- Sensitive groups (elderly, children, respiratory conditions): avoid outdoor activity\n- Wear a mask (N95/KN95) if outdoors for more than 30 minutes\n\n**Main pollutants today:**\n- PM2.5: Elevated (vehicle emissions + heat-intensified smog)\n- Ozone: Moderate (UV + heat combination)\n\n**Recommendation:** Keep windows closed between 10 AM – 4 PM. Use air purifier indoors if available.",

  children:
    "👶 **Heat Safety for Children:**\n\nChildren are far more vulnerable to heat illness than adults — they heat up 3–5x faster.\n\n**At current conditions (38°C, UV 9):**\n- Keep children indoors between 10 AM – 5 PM\n- Never leave children in a parked car (temp can hit 70°C in minutes)\n\n**Keeping children cool:**\n1. Light, breathable cotton clothing\n2. Water every 20 minutes — don't wait for thirst\n3. Use SPF 50+ sunscreen\n4. Limit outdoor play to shaded areas before 9 AM\n5. Use wet towels on neck and wrists\n\n**Warning signs in children:** Irritability, no tears when crying, fewer wet diapers, sunken eyes",

  default:
    "🌡️ I've analyzed your question based on current conditions in Chennai.\n\n**Current Summary:**\n- Temperature: 38°C (Feels like 43°C)\n- UV Index: 9 — Very High\n- AQI: 118 — Moderate concern\n- Heat Risk Score: **78/100 (High)**\n\nFor personalized advice, try asking me:\n- \"Is it safe to jog?\"\n- \"Where are the nearest cooling centers?\"\n- \"How much water should I drink today?\"\n- \"What are heat stroke symptoms?\"\n- \"Is it safe for my children to play outside?\"",
};

export const quickPrompts: QuickPrompt[] = [
  {
    id: "qp_001",
    label: "Safe to jog?",
    prompt: "Is it safe to go jogging right now?",
    icon: "🏃",
  },
  {
    id: "qp_002",
    label: "Cooling centers",
    prompt: "Where are the nearest cooling centers?",
    icon: "❄️",
  },
  {
    id: "qp_003",
    label: "Hydration guide",
    prompt: "How much water should I drink today?",
    icon: "💧",
  },
  {
    id: "qp_004",
    label: "Air quality",
    prompt: "What is the current air quality and AQI?",
    icon: "🌫️",
  },
  {
    id: "qp_005",
    label: "Kids safety",
    prompt: "Is it safe for children to play outside today?",
    icon: "👶",
  },
  {
    id: "qp_006",
    label: "Heat stroke signs",
    prompt: "What are the warning signs of heat stroke?",
    icon: "🚨",
  },
];

export function getMockResponse(userMessage: string): string {
  const lower = userMessage.toLowerCase();
  if (lower.includes("jog") || lower.includes("run")) return mockResponses.jogging;
  if (lower.includes("walk") || lower.includes("outside") || lower.includes("outdoor"))
    return mockResponses.walk;
  if (
    lower.includes("cooling") ||
    lower.includes("cool center") ||
    lower.includes("ac") ||
    lower.includes("air condition")
  )
    return mockResponses.cooling;
  if (
    lower.includes("water") ||
    lower.includes("drink") ||
    lower.includes("hydrat")
  )
    return mockResponses.hydration;
  if (
    lower.includes("stroke") ||
    lower.includes("emergency") ||
    lower.includes("hospital")
  )
    return mockResponses.heatstroke;
  if (lower.includes("aqi") || lower.includes("air quality") || lower.includes("pollution"))
    return mockResponses.aqi;
  if (
    lower.includes("child") ||
    lower.includes("kid") ||
    lower.includes("baby") ||
    lower.includes("children")
  )
    return mockResponses.children;
  return mockResponses.default;
}
