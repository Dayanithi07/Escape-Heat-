import type { Metadata, Viewport } from "next";
import "./globals.css";
import { Providers } from "./providers";

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  themeColor: [
    { media: "(prefers-color-scheme: dark)", color: "#0a0f1e" },
    { media: "(prefers-color-scheme: light)", color: "#f8fafc" },
  ],
};

export const metadata: Metadata = {
  title: {
    default: "Escape Heat — AI Urban Heat Intelligence Platform",
    template: "%s | Escape Heat",
  },
  description:
    "AI-powered Urban Heat Decision Intelligence Platform. Get personalized heat risk analysis, real-time environmental data, and actionable recommendations to stay safe during extreme heat.",
  keywords: [
    "urban heat island",
    "heat risk",
    "heat wave",
    "AI recommendations",
    "environmental intelligence",
    "heat safety",
    "temperature forecast",
    "outdoor safety",
  ],
  authors: [{ name: "Escape Heat Team" }],
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" data-scroll-behavior="smooth" suppressHydrationWarning>
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
      </head>
      <body className="antialiased min-h-screen bg-[var(--bg-primary)]">
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
