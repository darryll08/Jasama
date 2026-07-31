import { updatePassword } from "@/app/auth/actions";
import { FormMessage } from "@/components/form-message";
import { passwordRequirementsHelp } from "@/lib/auth/forms";

type UpdatePasswordPageProps = Readonly<{
  searchParams: Promise<{ error?: string }>;
}>;

export default async function UpdatePasswordPage({
  searchParams,
}: UpdatePasswordPageProps) {
  const { error } = await searchParams;

  return (
    <>
      <div className="auth-heading">
        <p className="phase-label">Pemulihan akun</p>
        <h1>Buat kata sandi baru</h1>
        <p>Gunakan kata sandi baru yang tidak dipakai di akun lain.</p>
      </div>
      <FormMessage error={error} />
      <form action={updatePassword} className="auth-form">
        <div className="field">
          <label htmlFor="password">Kata sandi baru</label>
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
        <div className="field">
          <label htmlFor="confirmation">Ulangi kata sandi baru</label>
          <input
            aria-describedby="password-help"
            autoComplete="new-password"
            id="confirmation"
            minLength={8}
            name="confirmation"
            required
            type="password"
          />
        </div>
        <button className="button button-primary" type="submit">
          Simpan kata sandi
        </button>
      </form>
    </>
  );
}
