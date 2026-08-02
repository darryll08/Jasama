import Link from "next/link";

import { signIn } from "@/app/auth/actions";
import { FormMessage } from "@/components/form-message";

type SignInPageProps = Readonly<{
  searchParams: Promise<{ error?: string; status?: string }>;
}>;

export default async function SignInPage({ searchParams }: SignInPageProps) {
  const message = await searchParams;

  return (
    <>
      <div className="auth-heading">
        <p className="phase-label">Akun Jasama</p>
        <h1>Masuk ke akun</h1>
        <p>Gunakan email dan kata sandi yang sudah Anda daftarkan.</p>
      </div>
      <FormMessage error={message.error} status={message.status} />
      <form action={signIn} className="auth-form">
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
        <div className="field">
          <label htmlFor="password">Kata sandi</label>
          <input
            autoComplete="current-password"
            id="password"
            minLength={8}
            name="password"
            required
            type="password"
          />
        </div>
        <button className="button button-primary" type="submit">
          Masuk
        </button>
      </form>
      <nav className="auth-links" aria-label="Pilihan akun">
        <Link href="/auth/forgot-password">Lupa kata sandi?</Link>
        <Link href="/auth/sign-up">Belum punya akun? Daftar</Link>
      </nav>
    </>
  );
}
