"use client";

type ErrorPageProps = Readonly<{
  error: Error & { digest?: string };
  reset: () => void;
}>;

export default function ErrorPage({ reset }: ErrorPageProps) {
  return (
    <section className="boundary-message" aria-labelledby="error-title">
      <h1 id="error-title">Halaman belum bisa ditampilkan</h1>
      <p>
        Terjadi kendala sementara. Tidak ada detail teknis yang ditampilkan di
        halaman ini.
      </p>
      <button className="button button-primary" onClick={reset} type="button">
        Coba lagi
      </button>
    </section>
  );
}
