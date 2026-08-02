import Link from "next/link";

import { signUp } from "@/app/auth/actions";
import { FormMessage } from "@/components/form-message";
import { passwordRequirementsHelp } from "@/lib/auth/forms";

type SignUpPageProps = Readonly<{
  searchParams: Promise<{ error?: string }>;
}>;

export default async function SignUpPage({ searchParams }: SignUpPageProps) {
  const { error } = await searchParams;

  return (
    <>
      <div className="auth-heading">
        <p className="phase-label">Akun baru</p>
        <h1>Daftar ke Jasama</h1>
        <p>Setelah mendaftar, konfirmasi alamat email Anda sebelum masuk.</p>
      </div>
      <FormMessage error={error} />
      <form action={signUp} className="auth-form">
        <div className="field">
          <label htmlFor="displayName">Nama tampilan</label>
          <input
            autoComplete="name"
            id="displayName"
            maxLength={80}
            minLength={2}
            name="displayName"
            required
          />
        </div>
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
            aria-describedby="password-help"
            autoComplete="new-password"
            id="password"
            minLength={8}
            name="password"
            required
            type="password"
          />
          <p className="field-help" id="password-help">
            {passwordRequirementsHelp}
          </p>
        </div>
        <button className="button button-primary" type="submit">
          Daftar
        </button>
      </form>
      <nav className="auth-links" aria-label="Pilihan akun">
        <Link href="/auth/sign-in">Sudah punya akun? Masuk</Link>
      </nav>
    </>
  );
}
