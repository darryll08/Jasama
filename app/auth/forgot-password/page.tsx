import Link from "next/link";

import { requestPasswordReset } from "@/app/auth/actions";
import { FormMessage } from "@/components/form-message";

type ForgotPasswordPageProps = Readonly<{
  searchParams: Promise<{ status?: string }>;
}>;

export default async function ForgotPasswordPage({
  searchParams,
}: ForgotPasswordPageProps) {
  const { status } = await searchParams;

  return (
    <>
      <div className="auth-heading">
        <p className="phase-label">Pemulihan akun</p>
        <h1>Atur ulang kata sandi</h1>
        <p>Kami akan mengirim petunjuk ke email jika akun tersedia.</p>
      </div>
      <FormMessage status={status} />
      <form action={requestPasswordReset} className="auth-form">
        <div className="field">
          <label htmlFor="email">Email</label>
          <input
            autoComplete="email"
            id="email"
            name="email"
            required
            type="email"
          />
        </div>
        <button className="button button-primary" type="submit">
          Kirim petunjuk
        </button>
      </form>
      <nav className="auth-links" aria-label="Pilihan akun">
        <Link href="/auth/sign-in">Kembali ke halaman masuk</Link>
      </nav>
    </>
  );
}
