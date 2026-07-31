/*
THESIS: Account access reads like one calm work record, not a promotional funnel.
OWN-WORLD: Warm canvas, ivory form field, dark-green frame, and turmeric action.
STORY: The visitor identifies the task, completes it, and sees a plain recovery path.
FIRST VIEWPORT: A compact heading leads directly into one bordered form column.
FORM: Narrow extension of the established Koperasi Modern system; no concept seed.
*/
import type { ReactNode } from "react";

export default function AuthLayout({
  children,
}: Readonly<{ children: ReactNode }>) {
  return <section className="auth-surface">{children}</section>;
}
