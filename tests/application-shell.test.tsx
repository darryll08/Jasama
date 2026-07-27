import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";

import HomePage from "@/app/page";
import { AppShell } from "@/components/app-shell";

describe("Phase 0 application shell", () => {
  it("links the skip action to the primary content", () => {
    render(
      <AppShell>
        <HomePage />
      </AppShell>,
    );

    const skipLink = screen.getByRole("link", {
      name: "Lewati ke konten utama",
    });
    const main = screen.getByRole("main");

    expect(skipLink).toHaveAttribute("href", "#main-content");
    expect(main).toHaveAttribute("id", "main-content");
  });

  it("renders one clear primary heading", () => {
    render(<HomePage />);

    expect(screen.getAllByRole("heading", { level: 1 })).toHaveLength(1);
    expect(
      screen.getByRole("heading", {
        name: "Fondasi aplikasi Jasama telah disiapkan.",
      }),
    ).toBeInTheDocument();
  });

  it("contains no fabricated marketplace evidence", () => {
    const { container } = render(<HomePage />);
    const content = container.textContent ?? "";

    expect(content).not.toMatch(
      /rating|ulasan pelanggan|testimoni|mitra terbaik|pesanan selesai|\d+[.,]\d\s*\/\s*5/i,
    );
  });
});
