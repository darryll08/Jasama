create extension if not exists pgcrypto with schema extensions;

create schema if not exists private;
create schema if not exists provisioning;
revoke all on schema private, provisioning from public, anon, authenticated, service_role;

create type public.account_state as enum (
  'active', 'limited', 'suspended', 'banned', 'appeal_pending', 'deactivated'
);
create type public.contact_channel as enum ('email', 'phone');
create type public.contact_verification_state as enum (
  'pending', 'verified', 'expired', 'revoked'
);
create type public.admin_risk as enum ('ordinary', 'high');
create type public.admin_scope_type as enum ('global', 'locality');
create type public.admin_grant_source as enum ('admin', 'provisioning');
create type public.admin_permission_scope_request as (
  permission_code text,
  scope_type public.admin_scope_type,
  scope_id uuid
);
create type public.profile_update_code as enum (
  'ok', 'forbidden', 'validation_failed', 'stale_version'
);
create type public.profile_update_result as (
  success boolean,
  code public.profile_update_code,
  lock_version bigint
);
create type public.audit_actor_kind as enum (
  'user', 'admin', 'system', 'system_provisioning'
);
create type public.idempotency_state as enum (
  'processing', 'completed', 'failed'
);
create type public.outbox_delivery_state as enum (
  'pending', 'claimed', 'retry', 'processed', 'dead_letter'
);
create type public.deployment_environment as enum (
  'development', 'test', 'staging', 'production'
);

create function private.is_valid_timezone(value text)
returns boolean
language sql
stable
set search_path = pg_catalog
as $$
  select exists (select 1 from pg_timezone_names where name = value);
$$;

create table public.profiles (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid not null references auth.users(id) on delete restrict,
  display_name text not null,
  avatar_attachment_id uuid,
  locale text not null default 'id-ID',
  timezone text not null default 'Asia/Jakarta',
  account_state public.account_state not null default 'active',
  is_demo boolean not null default false,
  deactivated_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  lock_version bigint not null default 0,
  constraint profiles_auth_user_unique unique (auth_user_id),
  constraint profiles_display_name_check
    check (char_length(btrim(display_name)) between 2 and 80),
  constraint profiles_locale_check
    check (char_length(locale) between 2 and 35),
  constraint profiles_timezone_check check (private.is_valid_timezone(timezone)),
  constraint profiles_lock_version_check check (lock_version >= 0),
  constraint profiles_deactivated_check check (
    (account_state = 'deactivated' and deactivated_at is not null)
    or (account_state <> 'deactivated' and deactivated_at is null)
  )
);
create index profiles_account_state_idx on public.profiles(account_state);
create index profiles_is_demo_idx on public.profiles(is_demo);

create table public.contact_verifications (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete restrict,
  channel public.contact_channel not null,
  destination_hash text not null,
  state public.contact_verification_state not null default 'pending',
  verified_at timestamptz,
  expires_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint contact_destination_hash_check
    check (destination_hash ~ '^[0-9a-f]{64}$'),
  constraint contact_verified_at_check check (
    (state = 'verified' and verified_at is not null)
    or (state <> 'verified')
  ),
  constraint contact_expiry_check
    check (expires_at is null or expires_at > created_at),
  constraint contact_identity_unique
    unique (profile_id, channel, destination_hash)
);
create unique index contact_one_active_channel_idx
  on public.contact_verifications(profile_id, channel)
  where state in ('pending', 'verified');
create index contact_profile_state_idx
  on public.contact_verifications(profile_id, channel, state);

create table public.admin_permissions (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  risk public.admin_risk not null,
  description text not null,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint admin_permission_code_check
    check (code ~ '^[a-z][a-z0-9]*(\.[a-z][a-z0-9_]*)+$'),
  constraint admin_permission_description_check
    check (char_length(btrim(description)) between 3 and 240)
);

insert into public.admin_permissions(code, risk, description, active) values
  ('admin.permissions.manage', 'ordinary', 'Kelola izin administrator biasa.', true),
  ('profile.support', 'ordinary', 'Baca data profil minimum untuk dukungan.', true),
  ('account.moderate', 'ordinary', 'Kelola pembatasan akun dalam cakupan yang disetujui.', true),
  ('admin.permissions.high_risk', 'high', 'Izin berisiko tinggi yang belum tersedia.', false);

create table public.admin_permission_assignments (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete restrict,
  permission_id uuid not null references public.admin_permissions(id) on delete restrict,
  scope_type public.admin_scope_type not null,
  scope_id uuid,
  grant_source public.admin_grant_source not null,
  granted_by_profile_id uuid references public.profiles(id) on delete restrict,
  provisioning_change_ref text,
  starts_at timestamptz not null default now(),
  expires_at timestamptz,
  revoked_at timestamptz,
  reason text not null,
  created_at timestamptz not null default now(),
  constraint assignment_scope_check check (
    (scope_type = 'global' and scope_id is null)
    or (scope_type <> 'global' and scope_id is not null)
  ),
  constraint assignment_source_check check (
    (
      grant_source = 'admin'
      and granted_by_profile_id is not null
      and granted_by_profile_id <> profile_id
      and provisioning_change_ref is null
    )
    or (
      grant_source = 'provisioning'
      and granted_by_profile_id is null
      and char_length(btrim(provisioning_change_ref)) between 3 and 200
    )
  ),
  constraint assignment_expiry_check
    check (expires_at is null or expires_at > starts_at),
  constraint assignment_revocation_check
    check (revoked_at is null or revoked_at >= starts_at),
  constraint assignment_reason_check
    check (char_length(btrim(reason)) between 3 and 500)
);
create unique index assignment_active_unique_idx
  on public.admin_permission_assignments(
    profile_id, permission_id, scope_type, scope_id
  ) nulls not distinct
  where revoked_at is null;
create unique index assignment_provisioning_replay_idx
  on public.admin_permission_assignments(
    provisioning_change_ref,
    profile_id,
    permission_id,
    scope_type,
    coalesce(scope_id, '00000000-0000-0000-0000-000000000000'::uuid)
  )
  where provisioning_change_ref is not null;
create index assignment_subject_validity_idx
  on public.admin_permission_assignments(profile_id, revoked_at, expires_at);
create index assignment_permission_scope_idx
  on public.admin_permission_assignments(permission_id, scope_type, scope_id);
create index assignment_grantor_idx
  on public.admin_permission_assignments(granted_by_profile_id)
  where granted_by_profile_id is not null;
create index assignment_change_ref_idx
  on public.admin_permission_assignments(provisioning_change_ref)
  where provisioning_change_ref is not null;

create table public.audit_events (
  id uuid primary key default gen_random_uuid(),
  occurred_at timestamptz not null default now(),
  actor_profile_id uuid references public.profiles(id) on delete restrict,
  actor_kind public.audit_actor_kind not null,
  action text not null,
  object_type text not null,
  object_id uuid not null,
  from_state text,
  to_state text,
  reason_code text,
  permission_code text,
  correlation_id uuid not null,
  causation_id uuid,
  request_id uuid not null,
  ip_hash text,
  user_agent_hash text,
  safe_metadata jsonb not null default '{}'::jsonb,
  constraint audit_action_check check (char_length(btrim(action)) between 3 and 120),
  constraint audit_object_type_check
    check (char_length(btrim(object_type)) between 2 and 80),
  constraint audit_metadata_object_check
    check (jsonb_typeof(safe_metadata) = 'object'),
  constraint audit_actor_check check (
    (actor_kind in ('user', 'admin') and actor_profile_id is not null)
    or (
      actor_kind in ('system', 'system_provisioning')
      and actor_profile_id is null
    )
  )
);
create index audit_object_time_idx
  on public.audit_events(object_type, object_id, occurred_at desc);
create index audit_actor_time_idx
  on public.audit_events(actor_profile_id, occurred_at desc)
  where actor_profile_id is not null;
create index audit_correlation_idx on public.audit_events(correlation_id);
create index audit_action_time_idx on public.audit_events(action, occurred_at desc);

create table public.idempotency_records (
  id uuid primary key default gen_random_uuid(),
  scope text not null,
  command_name text not null,
  idempotency_key text not null,
  input_hash text not null,
  state public.idempotency_state not null default 'processing',
  result_code text,
  result_object_type text,
  result_object_id uuid,
  correlation_id uuid not null,
  completed_at timestamptz,
  expires_at timestamptz not null,
  created_at timestamptz not null default now(),
  constraint idempotency_identity_unique
    unique (scope, command_name, idempotency_key),
  constraint idempotency_scope_check
    check (char_length(btrim(scope)) between 1 and 160),
  constraint idempotency_command_check
    check (char_length(btrim(command_name)) between 2 and 120),
  constraint idempotency_key_check
    check (char_length(btrim(idempotency_key)) between 8 and 200),
  constraint idempotency_hash_check check (input_hash ~ '^[0-9a-f]{64}$'),
  constraint idempotency_expiry_check check (expires_at > created_at),
  constraint idempotency_completion_check check (
    (state = 'processing' and completed_at is null and result_code is null)
    or (state in ('completed', 'failed') and completed_at is not null and result_code is not null)
  )
);
create index idempotency_expiry_idx on public.idempotency_records(expires_at);

create table public.outbox_events (
  id uuid primary key default gen_random_uuid(),
  event_name text not null,
  aggregate_type text not null,
  aggregate_id uuid not null,
  aggregate_version bigint not null,
  correlation_id uuid not null,
  causation_id uuid,
  payload_version integer not null,
  payload jsonb not null,
  fanout_completed_at timestamptz,
  fully_processed_at timestamptz,
  terminal_failed_at timestamptz,
  created_at timestamptz not null default now(),
  constraint outbox_event_identity_unique
    unique (aggregate_type, aggregate_id, aggregate_version, event_name),
  constraint outbox_versions_check
    check (aggregate_version > 0 and payload_version > 0),
  constraint outbox_payload_object_check check (jsonb_typeof(payload) = 'object'),
  constraint outbox_terminal_check
    check (fully_processed_at is null or terminal_failed_at is null)
);
create index outbox_fanout_idx
  on public.outbox_events(fanout_completed_at, created_at);
create index outbox_processing_idx
  on public.outbox_events(fully_processed_at, created_at);
create index outbox_correlation_idx on public.outbox_events(correlation_id);

create table public.outbox_event_deliveries (
  event_id uuid not null references public.outbox_events(id) on delete restrict,
  consumer_name text not null,
  state public.outbox_delivery_state not null default 'pending',
  attempt_count integer not null default 0,
  available_at timestamptz not null default now(),
  claimed_at timestamptz,
  processed_at timestamptz,
  last_error_code text,
  primary key (event_id, consumer_name),
  constraint outbox_consumer_check
    check (consumer_name ~ '^[a-z][a-z0-9_.-]*\.v[1-9][0-9]*$'),
  constraint outbox_attempts_check check (attempt_count >= 0),
  constraint outbox_delivery_state_check check (
    (state in ('pending', 'retry') and claimed_at is null and processed_at is null)
    or (state = 'claimed' and claimed_at is not null and processed_at is null)
    or (state = 'processed' and claimed_at is not null and processed_at is not null)
    or (state = 'dead_letter' and processed_at is null)
  )
);
create index outbox_delivery_due_idx
  on public.outbox_event_deliveries(state, available_at, event_id)
  where state in ('pending', 'retry');
create index outbox_delivery_consumer_idx
  on public.outbox_event_deliveries(consumer_name, state, available_at);

create table public.app_environment (
  singleton boolean primary key default true check (singleton),
  environment public.deployment_environment not null,
  demo_allowed boolean not null,
  mock_payment_allowed boolean not null,
  provisioned_at timestamptz not null,
  provisioning_change_ref text not null,
  constraint environment_production_check check (
    environment <> 'production'
    or (not demo_allowed and not mock_payment_allowed)
  ),
  constraint environment_change_ref_check
    check (char_length(btrim(provisioning_change_ref)) between 3 and 200)
);
insert into public.app_environment(
  environment,
  demo_allowed,
  mock_payment_allowed,
  provisioned_at,
  provisioning_change_ref
) values ('development', true, true, now(), 'local-phase-1-foundation');

insert into public.audit_events(
  actor_kind, action, object_type, object_id, to_state, reason_code,
  correlation_id, request_id, safe_metadata
) values (
  'system_provisioning',
  'app_environment.seeded',
  'app_environment',
  '00000000-0000-0000-0000-000000000001',
  'development',
  'local_development_seed',
  gen_random_uuid(),
  gen_random_uuid(),
  jsonb_build_object(
    'provisioning_change_ref', 'local-phase-1-foundation',
    'configuration', jsonb_build_object(
      'environment', 'development',
      'demo_allowed', true,
      'mock_payment_allowed', true
    )
  )
);

create function private.reject_audit_mutation()
returns trigger
language plpgsql
set search_path = pg_catalog
as $$
begin
  raise exception 'audit_events is append-only' using errcode = '42501';
end;
$$;
create trigger audit_events_append_only
before update or delete on public.audit_events
for each row execute function private.reject_audit_mutation();

create function private.guard_environment_change()
returns trigger
language plpgsql
set search_path = pg_catalog
as $$
begin
  if old.environment = 'production' and new.environment <> 'production' then
    raise exception 'production environment cannot be downgraded'
      using errcode = '23514';
  end if;
  if new.environment = 'production' and exists (
    select 1 from public.profiles where is_demo
  ) then
    raise exception 'production environment cannot contain demo profiles'
      using errcode = '23514';
  end if;
  return new;
end;
$$;
create trigger app_environment_guard
before update on public.app_environment
for each row execute function private.guard_environment_change();

create function private.audit_environment_change()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  changed_fields jsonb;
begin
  select coalesce(jsonb_agg(field_name order by field_name), '[]'::jsonb)
  into changed_fields
  from (
    values
      ('demo_allowed', old.demo_allowed is distinct from new.demo_allowed),
      ('environment', old.environment is distinct from new.environment),
      (
        'mock_payment_allowed',
        old.mock_payment_allowed is distinct from new.mock_payment_allowed
      )
  ) changed(field_name, did_change)
  where did_change;

  if changed_fields = '[]'::jsonb then
    return new;
  end if;

  insert into public.audit_events(
    actor_kind, action, object_type, object_id, from_state, to_state,
    reason_code, correlation_id, request_id, safe_metadata
  ) values (
    'system_provisioning',
    'app_environment.changed',
    'app_environment',
    '00000000-0000-0000-0000-000000000001',
    old.environment,
    new.environment,
    'reviewed_environment_change',
    gen_random_uuid(),
    gen_random_uuid(),
    jsonb_build_object(
      'changed_fields', changed_fields,
      'provisioning_change_ref', new.provisioning_change_ref,
      'configuration', jsonb_build_object(
        'environment', new.environment,
        'demo_allowed', new.demo_allowed,
        'mock_payment_allowed', new.mock_payment_allowed
      )
    )
  );
  return new;
end;
$$;
create trigger app_environment_audit
after update on public.app_environment
for each row execute function private.audit_environment_change();

create function provisioning.configure_environment(
  requested_environment public.deployment_environment,
  requested_demo_allowed boolean,
  requested_mock_payment_allowed boolean,
  change_reference text
)
returns boolean
language plpgsql
security definer
set search_path = pg_catalog, public, provisioning
as $$
declare
  current_environment public.app_environment%rowtype;
  requested_configuration jsonb;
  reviewed_configuration jsonb;
  correlation uuid := gen_random_uuid();
begin
  requested_configuration := jsonb_build_object(
    'environment', requested_environment,
    'demo_allowed', requested_demo_allowed,
    'mock_payment_allowed', requested_mock_payment_allowed
  );

  select * into current_environment
  from public.app_environment
  where singleton
  for update;

  select safe_metadata -> 'configuration'
  into reviewed_configuration
  from public.audit_events
  where object_type = 'app_environment'
    and action in (
      'app_environment.seeded',
      'app_environment.changed',
      'app_environment.provision_noop'
    )
    and safe_metadata ->> 'provisioning_change_ref' = change_reference
  order by occurred_at
  limit 1;

  if found then
    if reviewed_configuration = requested_configuration then
      insert into public.audit_events(
        actor_kind, action, object_type, object_id, reason_code,
        correlation_id, request_id, safe_metadata
      ) values (
        'system_provisioning',
        'app_environment.provision_replayed',
        'app_environment',
        '00000000-0000-0000-0000-000000000001',
        'exact_replay',
        correlation,
        gen_random_uuid(),
        jsonb_build_object(
          'provisioning_change_ref', change_reference,
          'configuration', requested_configuration
        )
      );
      return true;
    end if;

    insert into public.audit_events(
      actor_kind, action, object_type, object_id, reason_code,
      correlation_id, request_id, safe_metadata
    ) values (
      'system_provisioning',
      'app_environment.provision_denied',
      'app_environment',
      '00000000-0000-0000-0000-000000000001',
      'change_reference_mismatch',
      correlation,
      gen_random_uuid(),
      jsonb_build_object(
        'provisioning_change_ref', change_reference,
        'configuration', requested_configuration
      )
    );
    return false;
  end if;

  if requested_environment is null
    or requested_demo_allowed is null
    or requested_mock_payment_allowed is null
    or change_reference is null
    or char_length(btrim(change_reference)) not between 3 and 200
  then
    insert into public.audit_events(
      actor_kind, action, object_type, object_id, reason_code,
      correlation_id, request_id, safe_metadata
    ) values (
      'system_provisioning',
      'app_environment.provision_denied',
      'app_environment',
      '00000000-0000-0000-0000-000000000001',
      'invalid_configuration',
      correlation,
      gen_random_uuid(),
      jsonb_build_object(
        'provisioning_change_ref', change_reference,
        'configuration', requested_configuration
      )
    );
    return false;
  end if;

  if current_environment.environment = 'production'
    and requested_environment <> 'production'
  then
    insert into public.audit_events(
      actor_kind, action, object_type, object_id, reason_code,
      correlation_id, request_id, safe_metadata
    ) values (
      'system_provisioning',
      'app_environment.provision_denied',
      'app_environment',
      '00000000-0000-0000-0000-000000000001',
      'production_downgrade_denied',
      correlation,
      gen_random_uuid(),
      jsonb_build_object(
        'provisioning_change_ref', change_reference,
        'configuration', requested_configuration
      )
    );
    return false;
  end if;

  if requested_environment = 'production' then
    insert into public.audit_events(
      actor_kind, action, object_type, object_id, reason_code,
      correlation_id, request_id, safe_metadata
    ) values (
      'system_provisioning',
      'app_environment.provision_denied',
      'app_environment',
      '00000000-0000-0000-0000-000000000001',
      case
        when requested_demo_allowed or requested_mock_payment_allowed
          then 'production_flags_denied'
        when exists (select 1 from public.profiles where is_demo)
          then 'demo_records_present'
        else 'production_reauthentication_unavailable'
      end,
      correlation,
      gen_random_uuid(),
      jsonb_build_object(
        'provisioning_change_ref', change_reference,
        'configuration', requested_configuration
      )
    );
    return false;
  end if;

  if current_environment.environment = requested_environment
    and current_environment.demo_allowed = requested_demo_allowed
    and current_environment.mock_payment_allowed =
      requested_mock_payment_allowed
  then
    insert into public.audit_events(
      actor_kind, action, object_type, object_id, reason_code,
      correlation_id, request_id, safe_metadata
    ) values (
      'system_provisioning',
      'app_environment.provision_noop',
      'app_environment',
      '00000000-0000-0000-0000-000000000001',
      'configuration_unchanged',
      correlation,
      gen_random_uuid(),
      jsonb_build_object(
        'provisioning_change_ref', change_reference,
        'configuration', requested_configuration
      )
    );
    return true;
  end if;

  update public.app_environment
  set environment = requested_environment,
      demo_allowed = requested_demo_allowed,
      mock_payment_allowed = requested_mock_payment_allowed,
      provisioned_at = statement_timestamp(),
      provisioning_change_ref = change_reference
  where singleton;

  return true;
end;
$$;

create function private.guard_demo_profile()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
begin
  if new.is_demo and not coalesce(
    (select demo_allowed from public.app_environment where singleton),
    false
  ) then
    raise exception 'demo profiles are disabled in this environment'
      using errcode = '23514';
  end if;
  return new;
end;
$$;
create trigger profiles_demo_guard
before insert or update of is_demo on public.profiles
for each row execute function private.guard_demo_profile();

create function private.touch_profile_update()
returns trigger
language plpgsql
set search_path = pg_catalog
as $$
begin
  new.updated_at := statement_timestamp();
  new.lock_version := old.lock_version + 1;
  return new;
end;
$$;
create trigger profiles_touch_update
before update on public.profiles
for each row execute function private.touch_profile_update();

create function private.sync_auth_profile()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog, public, extensions
as $$
declare
  target_profile_id uuid;
  target_contact_id uuid;
  target_display_name text;
  normalized_email text;
  email_hash text;
  target_state public.contact_verification_state;
  prior_state public.contact_verification_state;
  existing_contact record;
begin
  target_display_name := coalesce(
    nullif(btrim(new.raw_user_meta_data ->> 'display_name'), ''),
    nullif(split_part(coalesce(new.email, ''), '@', 1), ''),
    'Akun Jasama'
  );
  if char_length(target_display_name) < 2 then
    target_display_name := 'Akun Jasama';
  end if;

  insert into public.profiles(auth_user_id, display_name)
  values (new.id, left(target_display_name, 80))
  on conflict (auth_user_id) do nothing
  returning id into target_profile_id;

  if target_profile_id is not null then
    insert into public.audit_events(
      actor_kind, action, object_type, object_id,
      correlation_id, request_id
    ) values (
      'system',
      'profile.created',
      'profile',
      target_profile_id,
      gen_random_uuid(),
      gen_random_uuid()
    );
  else
    select id into target_profile_id
    from public.profiles
    where auth_user_id = new.id;
  end if;

  if new.email is not null then
    normalized_email := lower(btrim(new.email));
    email_hash := encode(digest(normalized_email, 'sha256'), 'hex');
    target_state := case
      when new.email_confirmed_at is null then 'pending'
      else 'verified'
    end;

    for existing_contact in
      select id, state
      from public.contact_verifications
      where profile_id = target_profile_id
        and channel = 'email'
        and destination_hash <> email_hash
        and state in ('pending', 'verified')
      for update
    loop
      update public.contact_verifications
      set state = 'revoked', updated_at = now()
      where id = existing_contact.id;

      insert into public.audit_events(
        actor_kind, action, object_type, object_id, from_state, to_state,
        correlation_id, request_id
      ) values (
        'system',
        'contact_verification.revoked',
        'contact_verification',
        existing_contact.id,
        existing_contact.state,
        'revoked',
        gen_random_uuid(),
        gen_random_uuid()
      );
    end loop;

    select id, state
    into target_contact_id, prior_state
    from public.contact_verifications
    where profile_id = target_profile_id
      and channel = 'email'
      and destination_hash = email_hash
    for update;

    if target_contact_id is null then
      insert into public.contact_verifications(
        profile_id,
        channel,
        destination_hash,
        state,
        verified_at
      )
      values (
        target_profile_id,
        'email',
        email_hash,
        target_state,
        case
          when target_state = 'verified'
          then coalesce(new.email_confirmed_at, now())
        end
      )
      returning id into target_contact_id;

      insert into public.audit_events(
        actor_kind, action, object_type, object_id, to_state,
        correlation_id, request_id
      ) values (
        'system',
        'contact_verification.created',
        'contact_verification',
        target_contact_id,
        target_state,
        gen_random_uuid(),
        gen_random_uuid()
      );
    elsif prior_state = 'pending' and target_state = 'verified' then
      update public.contact_verifications
      set state = 'verified',
          verified_at = coalesce(new.email_confirmed_at, now()),
          updated_at = now()
      where id = target_contact_id;

      insert into public.audit_events(
        actor_kind, action, object_type, object_id, from_state, to_state,
        correlation_id, request_id
      ) values (
        'system',
        'contact_verification.verified',
        'contact_verification',
        target_contact_id,
        'pending',
        'verified',
        gen_random_uuid(),
        gen_random_uuid()
      );
    elsif prior_state in ('revoked', 'expired') then
      update public.contact_verifications
      set state = target_state,
          verified_at = case
            when target_state = 'verified'
            then coalesce(new.email_confirmed_at, now())
          end,
          updated_at = now()
      where id = target_contact_id;

      insert into public.audit_events(
        actor_kind, action, object_type, object_id, from_state, to_state,
        correlation_id, request_id
      ) values (
        'system',
        'contact_verification.reactivated',
        'contact_verification',
        target_contact_id,
        prior_state,
        target_state,
        gen_random_uuid(),
        gen_random_uuid()
      );
    end if;
  end if;

  return new;
end;
$$;
create trigger auth_user_profile_sync
after insert or update of email, email_confirmed_at on auth.users
for each row execute function private.sync_auth_profile();

create function public.current_profile_id()
returns uuid
language sql
stable
security definer
set search_path = pg_catalog, public
as $$
  select id from public.profiles where auth_user_id = auth.uid();
$$;

create function public.update_current_profile(
  new_display_name text,
  new_locale text,
  new_timezone text,
  expected_lock_version bigint
)
returns public.profile_update_result
language plpgsql
security definer
set search_path = pg_catalog, public, private
as $$
declare
  actor_profile_id uuid;
  current_lock_version bigint;
  current_display_name text;
  current_locale text;
  current_timezone text;
  resulting_lock_version bigint;
  changed_fields jsonb;
  correlation uuid := gen_random_uuid();
begin
  if auth.uid() is null then
    return row(false, 'forbidden', null)::public.profile_update_result;
  end if;

  select id, lock_version, display_name, locale, timezone
  into
    actor_profile_id,
    current_lock_version,
    current_display_name,
    current_locale,
    current_timezone
  from public.profiles
  where auth_user_id = auth.uid()
    and account_state = 'active'
    and not is_demo
  for update;

  if actor_profile_id is null then
    return row(false, 'forbidden', null)::public.profile_update_result;
  end if;

  if new_display_name is null
    or char_length(btrim(new_display_name)) not between 2 and 80
    or new_locale is null
    or btrim(new_locale) <> 'id-ID'
    or new_timezone is null
    or not private.is_valid_timezone(btrim(new_timezone))
    or expected_lock_version is null
    or expected_lock_version < 0
  then
    return row(
      false,
      'validation_failed',
      current_lock_version
    )::public.profile_update_result;
  end if;

  if current_lock_version <> expected_lock_version then
    return row(
      false,
      'stale_version',
      current_lock_version
    )::public.profile_update_result;
  end if;

  select coalesce(jsonb_agg(field_name order by field_name), '[]'::jsonb)
  into changed_fields
  from (
    values
      (
        'display_name',
        current_display_name is distinct from btrim(new_display_name)
      ),
      ('locale', current_locale is distinct from btrim(new_locale)),
      (
        'timezone',
        current_timezone is distinct from btrim(new_timezone)
      )
  ) changed(field_name, did_change)
  where did_change;

  if changed_fields = '[]'::jsonb then
    return row(
      true,
      'ok',
      current_lock_version
    )::public.profile_update_result;
  end if;

  update public.profiles
  set display_name = btrim(new_display_name),
      locale = btrim(new_locale),
      timezone = btrim(new_timezone)
  where id = actor_profile_id
    and lock_version = expected_lock_version
  returning lock_version into resulting_lock_version;

  if resulting_lock_version is null then
    return row(
      false,
      'stale_version',
      current_lock_version
    )::public.profile_update_result;
  end if;

  insert into public.audit_events(
    actor_profile_id, actor_kind, action, object_type, object_id,
    correlation_id, request_id, safe_metadata
  ) values (
    actor_profile_id,
    'user',
    'profile.updated',
    'profile',
    actor_profile_id,
    correlation,
    gen_random_uuid(),
    jsonb_build_object('changed_fields', changed_fields)
  );

  return row(
    true,
    'ok',
    resulting_lock_version
  )::public.profile_update_result;
end;
$$;

create function public.has_admin_permission(
  permission_code text,
  requested_scope_type public.admin_scope_type default 'global',
  requested_scope_id uuid default null
)
returns boolean
language sql
stable
security definer
set search_path = pg_catalog, public
as $$
  select exists (
    select 1
    from public.profiles actor
    join public.admin_permission_assignments assignment
      on assignment.profile_id = actor.id
    join public.admin_permissions permission on permission.id = assignment.permission_id
    where auth.uid() is not null
      and actor.auth_user_id = auth.uid()
      and actor.account_state = 'active'
      and not actor.is_demo
      and permission.code = permission_code
      and permission.active
      and permission.risk = 'ordinary'
      and assignment.scope_type = requested_scope_type
      and assignment.scope_id is not distinct from requested_scope_id
      and assignment.starts_at <= now()
      and (assignment.expires_at is null or assignment.expires_at > now())
      and assignment.revoked_at is null
  );
$$;

create function public.current_effective_admin_permissions()
returns table(
  permission_code text,
  scope_type public.admin_scope_type,
  scope_id uuid,
  effective_start timestamptz,
  effective_expiry timestamptz
)
language sql
stable
security definer
set search_path = pg_catalog, public
as $$
  select
    permission.code,
    assignment.scope_type,
    assignment.scope_id,
    assignment.starts_at,
    assignment.expires_at
  from public.profiles actor
  join public.admin_permission_assignments assignment
    on assignment.profile_id = actor.id
  join public.admin_permissions permission
    on permission.id = assignment.permission_id
  where auth.uid() is not null
    and actor.auth_user_id = auth.uid()
    and actor.account_state = 'active'
    and not actor.is_demo
    and permission.active
    and permission.risk = 'ordinary'
    and assignment.starts_at <= now()
    and (assignment.expires_at is null or assignment.expires_at > now())
    and assignment.revoked_at is null;
$$;

create function public.grant_admin_permission(
  recipient_profile_id uuid,
  permission_code text,
  requested_scope_type public.admin_scope_type,
  requested_scope_id uuid,
  grant_reason text
)
returns uuid
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  grantor_id uuid := public.current_profile_id();
  target_permission public.admin_permissions%rowtype;
  assignment_id uuid;
  expired_assignment_id uuid;
  active_assignment_id uuid;
  manager_authorized boolean;
  correlation uuid := gen_random_uuid();
begin
  if grantor_id is null or recipient_profile_id is null then
    return null;
  end if;

  manager_authorized := public.has_admin_permission(
    'admin.permissions.manage',
    'global',
    null
  );

  select * into target_permission
  from public.admin_permissions
  where code = permission_code and active;

  if recipient_profile_id = grantor_id
    or grant_reason is null
    or char_length(btrim(grant_reason)) < 3
    or target_permission.id is null
    or target_permission.risk <> 'ordinary'
    or not exists (
      select 1
      from public.profiles
      where id = recipient_profile_id
        and account_state = 'active'
        and not is_demo
    )
    or not manager_authorized
    or not public.has_admin_permission(
      permission_code,
      requested_scope_type,
      requested_scope_id
    )
  then
    insert into public.audit_events(
      actor_profile_id, actor_kind, action, object_type, object_id,
      reason_code, permission_code, correlation_id, request_id
    ) values (
      grantor_id,
      (case when manager_authorized then 'admin' else 'user' end)
        ::public.audit_actor_kind,
      'admin_permission.grant_denied',
      'profile',
      recipient_profile_id,
      'forbidden',
      permission_code,
      correlation,
      gen_random_uuid()
    );
    return null;
  end if;

  perform pg_advisory_xact_lock(
    hashtextextended(
      concat_ws(
        ':',
        recipient_profile_id::text,
        target_permission.id::text,
        requested_scope_type::text,
        coalesce(requested_scope_id::text, 'global')
      ),
      0
    )
  );

  update public.admin_permission_assignments
  set revoked_at = statement_timestamp()
  where profile_id = recipient_profile_id
    and permission_id = target_permission.id
    and scope_type = requested_scope_type
    and scope_id is not distinct from requested_scope_id
    and revoked_at is null
    and expires_at <= statement_timestamp()
  returning id into expired_assignment_id;

  if expired_assignment_id is not null then
    insert into public.audit_events(
      actor_profile_id, actor_kind, action, object_type, object_id,
      from_state, to_state, reason_code, permission_code,
      correlation_id, request_id
    ) values (
      grantor_id,
      'admin',
      'admin_permission.expired',
      'admin_permission_assignment',
      expired_assignment_id,
      'expired_unrevoked',
      'expired_closed',
      'closed_before_regrant',
      permission_code,
      correlation,
      gen_random_uuid()
    );
  end if;

  select id into active_assignment_id
  from public.admin_permission_assignments
  where profile_id = recipient_profile_id
    and permission_id = target_permission.id
    and scope_type = requested_scope_type
    and scope_id is not distinct from requested_scope_id
    and revoked_at is null
    and starts_at <= statement_timestamp()
    and (expires_at is null or expires_at > statement_timestamp())
  for update;

  if active_assignment_id is not null then
    insert into public.audit_events(
      actor_profile_id, actor_kind, action, object_type, object_id,
      reason_code, permission_code, correlation_id, request_id
    ) values (
      grantor_id,
      'admin',
      'admin_permission.grant_denied',
      'admin_permission_assignment',
      active_assignment_id,
      'active_duplicate',
      permission_code,
      correlation,
      gen_random_uuid()
    );
    return null;
  end if;

  insert into public.admin_permission_assignments(
    profile_id, permission_id, scope_type, scope_id, grant_source,
    granted_by_profile_id, reason
  ) values (
    recipient_profile_id, target_permission.id, requested_scope_type,
    requested_scope_id, 'admin', grantor_id, grant_reason
  )
  returning id into assignment_id;

  insert into public.audit_events(
    actor_profile_id, actor_kind, action, object_type, object_id,
    permission_code, correlation_id, request_id
  ) values (
    grantor_id, 'admin', 'admin_permission.granted',
    'admin_permission_assignment', assignment_id, permission_code,
    correlation, gen_random_uuid()
  );
  return assignment_id;
end;
$$;

create function public.revoke_admin_permission(
  assignment_id uuid,
  revoke_reason text
)
returns boolean
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  grantor_id uuid := public.current_profile_id();
  target_profile_id uuid;
  target_scope_type public.admin_scope_type;
  target_scope_id uuid;
  target_code text;
  target_revoked_at timestamptz;
  manager_authorized boolean := false;
  permission_authorized boolean := false;
  reason_hash text;
  original_reason_hash text;
  correlation uuid := gen_random_uuid();
begin
  select
    assignment.profile_id,
    assignment.scope_type,
    assignment.scope_id,
    permission.code,
    assignment.revoked_at
  into
    target_profile_id,
    target_scope_type,
    target_scope_id,
    target_code,
    target_revoked_at
  from public.admin_permission_assignments assignment
  join public.admin_permissions permission on permission.id = assignment.permission_id
  where assignment.id = assignment_id
  for update of assignment;

  if grantor_id is null or target_profile_id is null then
    return false;
  end if;

  manager_authorized := public.has_admin_permission(
    'admin.permissions.manage',
    'global',
    null
  );
  permission_authorized := public.has_admin_permission(
    target_code,
    target_scope_type,
    target_scope_id
  );

  if target_profile_id = grantor_id
    or revoke_reason is null
    or char_length(btrim(revoke_reason)) < 3
    or not manager_authorized
    or not permission_authorized
  then
    insert into public.audit_events(
      actor_profile_id, actor_kind, action, object_type, object_id,
      reason_code, permission_code, correlation_id, request_id
    ) values (
      grantor_id,
      (case when manager_authorized then 'admin' else 'user' end)
        ::public.audit_actor_kind,
      'admin_permission.revoke_denied',
      'admin_permission_assignment',
      assignment_id,
      'forbidden',
      target_code,
      correlation,
      gen_random_uuid()
    );
    return false;
  end if;

  reason_hash := encode(
    extensions.digest(revoke_reason, 'sha256'),
    'hex'
  );

  if target_revoked_at is not null then
    select safe_metadata ->> 'revoke_reason_hash'
    into original_reason_hash
    from public.audit_events
    where object_type = 'admin_permission_assignment'
      and object_id = assignment_id
      and action = 'admin_permission.revoked'
    order by occurred_at
    limit 1;

    if original_reason_hash is distinct from reason_hash then
      insert into public.audit_events(
        actor_profile_id, actor_kind, action, object_type, object_id,
        reason_code, permission_code, correlation_id, request_id
      ) values (
        grantor_id, 'admin', 'admin_permission.revoke_denied',
        'admin_permission_assignment', assignment_id,
        'idempotency_mismatch', target_code, correlation, gen_random_uuid()
      );
      return false;
    end if;

    insert into public.audit_events(
      actor_profile_id, actor_kind, action, object_type, object_id,
      permission_code, correlation_id, request_id, safe_metadata
    ) values (
      grantor_id, 'admin', 'admin_permission.revoke_replayed',
      'admin_permission_assignment', assignment_id, target_code,
      correlation, gen_random_uuid(),
      jsonb_build_object('revoke_reason_hash', reason_hash)
    );
    return true;
  end if;

  update public.admin_permission_assignments
  set revoked_at = now()
  where id = assignment_id;

  insert into public.audit_events(
    actor_profile_id, actor_kind, action, object_type, object_id,
    permission_code, correlation_id, request_id, safe_metadata
  ) values (
    grantor_id, 'admin', 'admin_permission.revoked',
    'admin_permission_assignment', assignment_id, target_code,
    correlation, gen_random_uuid(),
    jsonb_build_object('revoke_reason_hash', reason_hash)
  );
  return true;
end;
$$;

create function provisioning.bootstrap_admin(
  target_auth_user_id uuid,
  permission_scope_set public.admin_permission_scope_request[],
  change_reference text,
  provision_reason text
)
returns boolean
language plpgsql
security definer
set search_path = pg_catalog, public, provisioning
as $$
declare
  target_profile uuid;
  requested_set public.admin_permission_scope_request[];
  existing_set public.admin_permission_scope_request[];
  requested_metadata jsonb;
  existing_target_count integer;
  permission_record record;
  expired_assignment_id uuid;
  replay boolean := false;
  correlation uuid := gen_random_uuid();
begin
  if target_auth_user_id is null then
    return false;
  end if;

  perform pg_advisory_xact_lock(
    hashtextextended(coalesce(change_reference, ''), 0)
  );

  select id into target_profile
  from public.profiles
  where auth_user_id = target_auth_user_id
    and account_state = 'active'
    and not is_demo;

  select
    array_agg(
      row(permission_code, scope_type, scope_id)
        ::public.admin_permission_scope_request
      order by permission_code, scope_type, scope_id nulls first
    ),
    jsonb_agg(
      jsonb_build_object(
        'permission_code', permission_code,
        'scope_type', scope_type,
        'scope_id', scope_id
      )
      order by permission_code, scope_type, scope_id nulls first
    )
  into requested_set, requested_metadata
  from (
    select distinct
      requested.permission_code,
      requested.scope_type,
      requested.scope_id
    from unnest(permission_scope_set) requested
  ) normalized;

  select
    array_agg(
      row(permission.code, assignment.scope_type, assignment.scope_id)
        ::public.admin_permission_scope_request
      order by permission.code, assignment.scope_type,
        assignment.scope_id nulls first
    ),
    count(distinct assignment.profile_id)
  into existing_set, existing_target_count
  from public.admin_permission_assignments assignment
  join public.admin_permissions permission on permission.id = assignment.permission_id
  where assignment.provisioning_change_ref = change_reference;

  replay := existing_set is not null;
  if target_profile is null
    or change_reference is null
    or char_length(btrim(change_reference)) < 3
    or provision_reason is null
    or char_length(btrim(provision_reason)) < 3
    or requested_set is null
    or cardinality(requested_set) <> cardinality(permission_scope_set)
    or exists (
      select 1
      from unnest(requested_set) requested
      where requested.permission_code is null
        or requested.scope_type is null
        or (
          requested.scope_type = 'global'
          and requested.scope_id is not null
        )
        or (
          requested.scope_type = 'locality'
          and requested.scope_id is null
        )
    )
    or exists (
      select 1
      from unnest(requested_set) requested
      left join public.admin_permissions permission
        on permission.code = requested.permission_code and permission.active
      where permission.id is null or permission.risk <> 'ordinary'
    )
    or (
      replay and (
        existing_target_count <> 1
        or existing_set <> requested_set
        or exists (
          select 1
          from public.admin_permission_assignments
          where provisioning_change_ref = change_reference
            and profile_id <> target_profile
        )
      )
    )
  then
    insert into public.audit_events(
      actor_kind, action, object_type, object_id, reason_code,
      correlation_id, request_id,
      safe_metadata
    ) values (
      'system_provisioning',
      'admin_provisioning.denied',
      'profile',
      coalesce(target_profile, target_auth_user_id),
      'invalid_exact_set',
      correlation,
      gen_random_uuid(),
      jsonb_build_object(
        'change_reference', change_reference,
        'permission_scope_set', coalesce(requested_metadata, '[]'::jsonb)
      )
    );
    return false;
  end if;

  if not replay then
    for permission_record in
      select
        permission.id,
        requested.permission_code,
        requested.scope_type,
        requested.scope_id
      from unnest(requested_set) requested
      join public.admin_permissions permission
        on permission.code = requested.permission_code
      order by requested.permission_code, requested.scope_type,
        requested.scope_id nulls first
    loop
      perform pg_advisory_xact_lock(
        hashtextextended(
          concat_ws(
            ':',
            target_profile::text,
            permission_record.id::text,
            permission_record.scope_type::text,
            coalesce(permission_record.scope_id::text, 'global')
          ),
          0
        )
      );
    end loop;

    if exists (
      select 1
      from unnest(requested_set) requested
      join public.admin_permissions permission
        on permission.code = requested.permission_code
      join public.admin_permission_assignments assignment
        on assignment.profile_id = target_profile
        and assignment.permission_id = permission.id
        and assignment.scope_type = requested.scope_type
        and assignment.scope_id is not distinct from requested.scope_id
      where assignment.revoked_at is null
        and assignment.starts_at <= statement_timestamp()
        and (
          assignment.expires_at is null
          or assignment.expires_at > statement_timestamp()
        )
    ) then
      insert into public.audit_events(
        actor_kind, action, object_type, object_id, reason_code,
        correlation_id, request_id, safe_metadata
      ) values (
        'system_provisioning',
        'admin_provisioning.denied',
        'profile',
        target_profile,
        'active_duplicate',
        correlation,
        gen_random_uuid(),
        jsonb_build_object(
          'change_reference', change_reference,
          'permission_scope_set', requested_metadata
        )
      );
      return false;
    end if;

    for permission_record in
      select
        permission.id,
        requested.permission_code,
        requested.scope_type,
        requested.scope_id
      from unnest(requested_set) requested
      join public.admin_permissions permission
        on permission.code = requested.permission_code
      order by requested.permission_code, requested.scope_type,
        requested.scope_id nulls first
    loop
      update public.admin_permission_assignments
      set revoked_at = statement_timestamp()
      where profile_id = target_profile
        and permission_id = permission_record.id
        and scope_type = permission_record.scope_type
        and scope_id is not distinct from permission_record.scope_id
        and revoked_at is null
        and expires_at <= statement_timestamp()
      returning id into expired_assignment_id;

      if expired_assignment_id is not null then
        insert into public.audit_events(
          actor_kind, action, object_type, object_id,
          from_state, to_state, reason_code, permission_code,
          correlation_id, request_id
        ) values (
          'system_provisioning',
          'admin_permission.expired',
          'admin_permission_assignment',
          expired_assignment_id,
          'expired_unrevoked',
          'expired_closed',
          'closed_before_regrant',
          permission_record.permission_code,
          correlation,
          gen_random_uuid()
        );
      end if;

      insert into public.admin_permission_assignments(
        profile_id, permission_id, scope_type, scope_id, grant_source,
        provisioning_change_ref, reason
      ) values (
        target_profile, permission_record.id, permission_record.scope_type,
        permission_record.scope_id, 'provisioning',
        change_reference, provision_reason
      );
    end loop;
  end if;

  insert into public.audit_events(
    actor_kind, action, object_type, object_id,
    correlation_id, request_id, safe_metadata
  ) values (
    'system_provisioning',
    case when replay
      then 'admin_provisioning.replayed'
      else 'admin_provisioning.completed'
    end,
    'profile',
    target_profile,
    correlation,
    gen_random_uuid(),
    jsonb_build_object(
      'change_reference', change_reference,
      'permission_scope_set', requested_metadata
    )
  );
  return true;
end;
$$;

alter table public.profiles enable row level security;
alter table public.contact_verifications enable row level security;
alter table public.admin_permissions enable row level security;
alter table public.admin_permission_assignments enable row level security;
alter table public.audit_events enable row level security;
alter table public.idempotency_records enable row level security;
alter table public.outbox_events enable row level security;
alter table public.outbox_event_deliveries enable row level security;
alter table public.app_environment enable row level security;

create policy profiles_owner_read
on public.profiles for select to authenticated
using (auth_user_id = auth.uid());
create policy contact_owner_read
on public.contact_verifications for select to authenticated
using (profile_id = public.current_profile_id());

revoke create on schema public from public, anon, authenticated, service_role;
revoke all on all tables in schema public
from public, anon, authenticated, service_role;
grant select(
  display_name, locale, timezone, account_state, lock_version
) on public.profiles to authenticated;
grant select(channel, state)
on public.contact_verifications to authenticated;

revoke all on function public.current_profile_id() from public;
revoke all on function public.update_current_profile(
  text, text, text, bigint
) from public;
revoke all on function public.has_admin_permission(text, public.admin_scope_type, uuid) from public;
revoke all on function public.current_effective_admin_permissions() from public;
revoke all on function public.grant_admin_permission(
  uuid, text, public.admin_scope_type, uuid, text
) from public;
revoke all on function public.revoke_admin_permission(uuid, text) from public;
grant execute on function public.current_profile_id() to authenticated;
grant execute on function public.update_current_profile(
  text, text, text, bigint
) to authenticated;
grant execute on function public.has_admin_permission(
  text, public.admin_scope_type, uuid
) to authenticated;
grant execute on function public.current_effective_admin_permissions()
to authenticated;
grant execute on function public.grant_admin_permission(
  uuid, text, public.admin_scope_type, uuid, text
) to authenticated;
grant execute on function public.revoke_admin_permission(uuid, text) to authenticated;

revoke all on function provisioning.bootstrap_admin(
  uuid, public.admin_permission_scope_request[], text, text
) from public, anon, authenticated, service_role;
revoke all on function provisioning.configure_environment(
  public.deployment_environment, boolean, boolean, text
) from public, anon, authenticated, service_role;

comment on schema provisioning is
  'Deployment-controlled administrator bootstrap; never exposed through the application.';
comment on function provisioning.bootstrap_admin(
  uuid, public.admin_permission_scope_request[], text, text
) is
  'Exact-set, idempotent provisioning path owned by the database deployment role.';
comment on function provisioning.configure_environment(
  public.deployment_environment, boolean, boolean, text
) is
  'Reviewed deployment-only environment operation; production remains unavailable until reauthentication is approved.';
comment on table public.audit_events is
  'Append-only security and domain audit without secret or private-content payloads.';
comment on table public.app_environment is
  'Deployment guard. The migration seed is local development only; staging and production require reviewed environment provisioning.';
