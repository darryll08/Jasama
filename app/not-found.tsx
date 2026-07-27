import Link from "next/link";

export default function NotFoundPage() {
  return (
    <section className="boundary-message" aria-labelledby="not-found-title">
      <h1 id="not-found-title">Halaman tidak ditemukan</h1>
      <p>Alamat ini tidak tersedia. Kembali ke halaman awal untuk melanjutkan.</p>
      <Link className="button button-secondary" href="/">
        Kembali ke halaman awal
      </Link>
    </section>
  );
}
