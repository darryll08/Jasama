import { redirect } from "next/navigation";

import { signOut, updateProfile } from "@/app/auth/actions";
import { FormMessage } from "@/components/form-message";
import { createClient } from "@/lib/supabase/server";

type AccountPageProps = Readonly<{
  searchParams: Promise<{ error?: string; status?: string }>;
}>;

export default async function AccountPage({
  searchParams,
}: AccountPageProps) {
  const message = await searchParams;
  const supabase = await createClient();
  const { data: claims } = await supabase.auth.getClaims();
  if (!claims?.claims.sub) {
    redirect("/auth/sign-in");
  }

  const { data: profile, error: profileError } = await supabase
    .from("profiles")
    .select("display_name, locale, timezone, account_state, lock_version")
    .single();

  if (profileError || !profile) {
    return (
      <section className="account-surface">
        <h1>Profil belum tersedia</h1>
        <p role="alert">
          Profil akun belum dapat dimuat. Muat ulang halaman atau coba lagi.
        </p>
      </section>
    );
  }

  const { data: contact, error: contactError } = await supabase
    .from("contact_verifications")
    .select("state")
    .eq("channel", "email")
    .in("state", ["pending", "verified"])
    .maybeSingle();

  const emailStatus = contactError
    ? "Status email belum dapat dimuat."
    : contact?.state === "verified"
      ? "Terkonfirmasi"
      : contact?.state === "pending"
        ? "Menunggu konfirmasi"
        : "Belum ada email aktif";

  return (
    <section className="account-surface" aria-labelledby="account-title">
      <div className="account-heading">
        <div>
          <p className="phase-label">Profil akun</p>
          <h1 id="account-title">Data dasar Anda</h1>
        </div>
        <form action={signOut}>
          <button className="button button-secondary" type="submit">
            Keluar
          </button>
        </form>
      </div>
      <FormMessage error={message.error} status={message.status} />
      <dl className="account-facts">
        <div>
          <dt>Status akun</dt>
          <dd>{profile.account_state === "active" ? "Aktif" : "Dibatasi"}</dd>
        </div>
        <div>
          <dt>Status email</dt>
          <dd>{emailStatus}</dd>
        </div>
      </dl>
      <form action={updateProfile} className="auth-form account-form">
        <input
          name="expectedLockVersion"
          type="hidden"
          value={profile.lock_version}
        />
        <div className="field">
          <label htmlFor="displayName">Nama tampilan</label>
          <input
            defaultValue={profile.display_name}
            id="displayName"
            maxLength={80}
            minLength={2}
            name="displayName"
            required
          />
        </div>
        <div className="field">
          <label htmlFor="locale">Bahasa</label>
          <select defaultValue={profile.locale} id="locale" name="locale">
            <option value="id-ID">Bahasa Indonesia</option>
          </select>
        </div>
        <div className="field">
          <label htmlFor="timezone">Zona waktu</label>
          <select defaultValue={profile.timezone} id="timezone" name="timezone">
            <option value="Asia/Jakarta">Waktu Indonesia Barat</option>
          </select>
        </div>
        <button className="button button-primary" type="submit">
          Simpan profil
        </button>
      </form>
    </section>
  );
}
