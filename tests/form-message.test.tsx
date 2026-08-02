import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";

import { FormMessage } from "@/components/form-message";

describe("account form messages", () => {
  it("announces errors immediately", () => {
    render(<FormMessage error="Periksa alamat email." />);
    expect(screen.getByRole("alert")).toHaveTextContent("Periksa alamat email.");
  });

  it("announces successful status without an urgent alert", () => {
    render(<FormMessage status="Profil berhasil disimpan." />);
    expect(screen.getByRole("status")).toHaveTextContent(
      "Profil berhasil disimpan.",
    );
  });
});
