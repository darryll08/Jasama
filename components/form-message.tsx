type FormMessageProps = Readonly<{
  error?: string;
  status?: string;
}>;

export function FormMessage({ error, status }: FormMessageProps) {
  if (!error && !status) {
    return null;
  }

  return (
    <div
      className={`form-message ${error ? "form-message-error" : "form-message-status"}`}
      role={error ? "alert" : "status"}
    >
      <strong>{error ? "Periksa kembali" : "Status"}</strong>
      <p>{error ?? status}</p>
    </div>
  );
}
