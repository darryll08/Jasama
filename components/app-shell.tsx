import type { ReactNode } from "react";

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
        <div className="site-container">
          <p className="wordmark">Jasama</p>
        </div>
      </header>
      <main className="site-main" id="main-content" tabIndex={-1}>
        {children}
      </main>
      <footer className="site-footer">
        <div className="site-container">
          <p>Jasama sedang dalam tahap pengembangan.</p>
        </div>
      </footer>
    </>
  );
}
