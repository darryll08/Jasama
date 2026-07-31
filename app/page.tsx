import Link from "next/link";

export default function HomePage() {
  return (
    <section className="foundation-message" aria-labelledby="foundation-title">
      <p className="phase-label">Tahap 1A lokal</p>
      <h1 id="foundation-title">Fondasi akun Jasama siap diuji secara lokal.</h1>
      <p>
        Pendaftaran, masuk, pemulihan kata sandi, dan profil dasar tersedia
        untuk verifikasi pengembangan. Fitur pasar jasa belum dimulai.
      </p>
      <Link className="button button-primary" href="/auth/sign-in">
        Masuk ke akun
      </Link>
    </section>
  );
}
