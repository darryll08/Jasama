import type { Metadata } from "next";
import { Barlow_Condensed, Source_Sans_3 } from "next/font/google";
import type { ReactNode } from "react";

import { AppShell } from "@/components/app-shell";
import { serverEnvironment } from "@/lib/env/server";

import "./globals.css";

const headingFont = Barlow_Condensed({
  display: "swap",
  subsets: ["latin"],
  variable: "--font-barlow-condensed",
  weight: ["400", "600"],
});

const bodyFont = Source_Sans_3({
  display: "swap",
  subsets: ["latin"],
  variable: "--font-source-sans-3",
  weight: ["400", "600", "700"],
});

export const metadata: Metadata = {
  title: "Jasama",
  description:
    "Fondasi aplikasi Jasama untuk pengembangan pasar jasa lokal dan digital.",
  robots: {
    follow: false,
    index: false,
  },
};

type RootLayoutProps = Readonly<{
  children: ReactNode;
}>;

export default function RootLayout({ children }: RootLayoutProps) {
  return (
    <html lang="id">
      <body
        className={`${headingFont.variable} ${bodyFont.variable}`}
        data-environment={serverEnvironment.APP_ENV}
      >
        <AppShell>{children}</AppShell>
      </body>
    </html>
  );
}
