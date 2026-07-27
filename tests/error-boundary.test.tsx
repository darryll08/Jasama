import { fireEvent, render, screen } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";

import ErrorPage from "@/app/error";

describe("error boundary", () => {
  it("offers a native keyboard-accessible retry control", () => {
    const reset = vi.fn();

    render(<ErrorPage error={new Error("internal detail")} reset={reset} />);

    const retry = screen.getByRole("button", { name: "Coba lagi" });
    retry.focus();

    expect(retry).toHaveFocus();
    expect(retry.tagName).toBe("BUTTON");

    fireEvent.click(retry);
    expect(reset).toHaveBeenCalledOnce();
    expect(screen.queryByText("internal detail")).not.toBeInTheDocument();
  });
});
