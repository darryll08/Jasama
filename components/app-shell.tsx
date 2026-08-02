import type { ReactNode } from "react";
import Link from "next/link";

type AppShellProps = Readonly<{
  children: ReactNode;
}>;

export function AppShell({ children }: AppShellProps) {
  return (
    <>
      <a className="skip-link" href="#main-content">
        Lewati ke konten utama
      </a>
      <header className="site-header">
        <div className="site-container site-navigation">
          <Link className="wordmark" href="/">
            Jasama
          </Link>
          <nav aria-label="Navigasi akun">
            <Link href="/auth/sign-in">Masuk</Link>
            <Link href="/account">Akun</Link>
          </nav>
        </div>
      </header>
      <main className="site-main" id="main-content" tabIndex={-1}>
        {children}
      </main>
      <footer className="site-footer">
        <div className="site-container">
          <p>Jasama sedang dalam verifikasi lokal Tahap 1.</p>
        </div>
      </footer>
    </>
  );
}
