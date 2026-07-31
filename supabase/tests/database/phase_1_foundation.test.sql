create extension if not exists pgtap with schema extensions;

begin;
select plan(213);

select has_table('public', 'profiles', 'profiles exists');
select has_table('public', 'contact_verifications', 'contact_verifications exists');
select has_table('public', 'admin_permissions', 'admin_permissions exists');
select has_table('public', 'admin_permission_assignments', 'assignments exists');
select has_table('public', 'audit_events', 'audit_events exists');
select has_table('public', 'idempotency_records', 'idempotency_records exists');
select has_table('public', 'outbox_events', 'outbox_events exists');
select has_table('public', 'outbox_event_deliveries', 'outbox deliveries exists');
select has_table('public', 'app_environment', 'app_environment exists');
select has_column('public', 'profiles', 'auth_user_id', 'profile has Auth identity');
select has_column(
  'public',
  'admin_permission_assignments',
  'grant_source',
  'assignment records grant provenance'
);
select has_column(
  'public',
  'admin_permission_assignments',
  'provisioning_change_ref',
  'assignment records provisioning change reference'
);
select has_column(
  'public',
  'audit_events',
  'correlation_id',
  'audit records correlation identity'
);
select has_column(
  'public',
  'idempotency_records',
  'input_hash',
  'idempotency records request fingerprint'
);
select has_column(
  'public',
  'outbox_event_deliveries',
  'consumer_name',
  'outbox delivery records consumer identity'
);
select has_index(
  'public',
  'profiles',
  'profiles_auth_user_unique',
  'profile Auth identity is unique'
);
select has_index(
  'public',
  'admin_permission_assignments',
  'assignment_active_unique_idx',
  'active assignment identity is unique'
);
select has_index(
  'public',
  'outbox_event_deliveries',
  'outbox_event_deliveries_pkey',
  'outbox delivery identity is unique'
);

select ok(
  (
    select bool_and(relrowsecurity)
    from pg_class
    where oid = any(array[
      'public.profiles'::regclass,
      'public.contact_verifications'::regclass,
      'public.admin_permissions'::regclass,
      'public.admin_permission_assignments'::regclass,
      'public.audit_events'::regclass,
      'public.idempotency_records'::regclass,
      'public.outbox_events'::regclass,
      'public.outbox_event_deliveries'::regclass,
      'public.app_environment'::regclass
    ])
  ),
  'RLS is enabled on every Phase 1 table'
);

insert into auth.users(
  instance_id, id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) values
(
  '00000000-0000-0000-0000-000000000000',
  '10000000-0000-0000-0000-000000000001',
  'authenticated', 'authenticated', 'owner@example.test',
  crypt('local-password', gen_salt('bf')), now(),
  '{"provider":"email","providers":["email"]}',
  '{"display_name":"Pemilik"}', now(), now()
),
(
  '00000000-0000-0000-0000-000000000000',
  '10000000-0000-0000-0000-000000000002',
  'authenticated', 'authenticated', 'other@example.test',
  crypt('local-password', gen_salt('bf')), null,
  '{"provider":"email","providers":["email"]}',
  '{"display_name":"Pengguna Lain"}', now(), now()
);

select set_config(
  'test.owner_profile_id',
  (select id::text from public.profiles where auth_user_id =
    '10000000-0000-0000-0000-000000000001'),
  true
);
select set_config(
  'test.other_profile_id',
  (select id::text from public.profiles where auth_user_id =
    '10000000-0000-0000-0000-000000000002'),
  true
);

select is(
  (select count(*) from public.profiles where auth_user_id in (
    '10000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000002'
  )),
  2::bigint,
  'Auth creates exactly one profile per user'
);
select is(
  (select count(*) from public.contact_verifications),
  2::bigint,
  'Auth records one hashed email fact per user'
);
select is(
  (
    select state::text
    from public.contact_verifications verification
    join public.profiles profile on profile.id = verification.profile_id
    where profile.auth_user_id = '10000000-0000-0000-0000-000000000001'
  ),
  'verified',
  'trusted Auth confirmation creates a verified email fact'
);
select is(
  (
    select count(*)
    from public.audit_events
    where action = 'profile.created'
      and object_id in (
        current_setting('test.owner_profile_id')::uuid,
        current_setting('test.other_profile_id')::uuid
      )
  ),
  2::bigint,
  'initial profile creation is audited exactly once per profile'
);
select is(
  (
    select count(*)
    from public.audit_events
    where action = 'contact_verification.created'
      and object_type = 'contact_verification'
  ),
  2::bigint,
  'initial email facts are audited exactly once'
);
select ok(
  not exists (
    select 1
    from public.audit_events
    where action in (
      'profile.created',
      'contact_verification.created',
      'contact_verification.verified',
      'contact_verification.revoked',
      'contact_verification.reactivated'
    )
      and (
        actor_kind <> 'system'
        or actor_profile_id is not null
        or safe_metadata::text ~* '(example\\.test|destination_hash|email)'
      )
  ),
  'Auth lifecycle audit has system provenance and no email or destination hash'
);
select set_config(
  'test.other_contact_id',
  (
    select verification.id::text
    from public.contact_verifications verification
    where verification.profile_id =
      current_setting('test.other_profile_id')::uuid
  ),
  true
);
select set_config(
  'test.other_contact_updated_at',
  (
    select updated_at::text
    from public.contact_verifications
    where id = current_setting('test.other_contact_id')::uuid
  ),
  true
);
select set_config(
  'test.auth_lifecycle_audit_count',
  (
    select count(*)::text
    from public.audit_events
    where object_id = current_setting('test.other_contact_id')::uuid
  ),
  true
);
update auth.users
set email = email,
    email_confirmed_at = email_confirmed_at
where id = '10000000-0000-0000-0000-000000000002';
select is(
  (
    select updated_at
    from public.contact_verifications
    where id = current_setting('test.other_contact_id')::uuid
  ),
  current_setting('test.other_contact_updated_at')::timestamptz,
  'repeated Auth update does not touch an unchanged contact fact'
);
select is(
  (
    select count(*)
    from public.audit_events
    where object_id = current_setting('test.other_contact_id')::uuid
  ),
  current_setting('test.auth_lifecycle_audit_count')::bigint,
  'repeated Auth update appends no duplicate contact audit'
);
update auth.users
set email_confirmed_at = statement_timestamp()
where id = '10000000-0000-0000-0000-000000000002';
select is(
  (
    select state::text
    from public.contact_verifications
    where id = current_setting('test.other_contact_id')::uuid
  ),
  'verified',
  'pending email becomes verified'
);
select is(
  (
    select count(*)
    from public.audit_events
    where object_id = current_setting('test.other_contact_id')::uuid
      and action = 'contact_verification.verified'
      and from_state = 'pending'
      and to_state = 'verified'
  ),
  1::bigint,
  'pending-to-verified transition is audited exactly once'
);
update auth.users
set email = 'other-new@example.test',
    email_confirmed_at = null
where id = '10000000-0000-0000-0000-000000000002';
select is(
  (
    select state::text
    from public.contact_verifications
    where id = current_setting('test.other_contact_id')::uuid
  ),
  'revoked',
  'old active email fact is revoked after an Auth email change'
);
select is(
  (
    select count(*)
    from public.audit_events
    where object_id = current_setting('test.other_contact_id')::uuid
      and action = 'contact_verification.revoked'
      and from_state = 'verified'
      and to_state = 'revoked'
  ),
  1::bigint,
  'old active email revocation is audited exactly once'
);
select set_config(
  'test.other_new_contact_id',
  (
    select id::text
    from public.contact_verifications
    where profile_id = current_setting('test.other_profile_id')::uuid
      and state = 'pending'
  ),
  true
);
select is(
  (
    select count(*)
    from public.audit_events
    where object_id = current_setting('test.other_new_contact_id')::uuid
      and action = 'contact_verification.created'
      and to_state = 'pending'
  ),
  1::bigint,
  'new active email fact creation is audited exactly once'
);
update auth.users
set email = 'other@example.test',
    email_confirmed_at = statement_timestamp()
where id = '10000000-0000-0000-0000-000000000002';
select is(
  (
    select state::text
    from public.contact_verifications
    where id = current_setting('test.other_contact_id')::uuid
  ),
  'verified',
  'historical email fact can be reactivated'
);
select is(
  (
    select count(*)
    from public.audit_events
    where object_id = current_setting('test.other_contact_id')::uuid
      and action = 'contact_verification.reactivated'
      and from_state = 'revoked'
      and to_state = 'verified'
  ),
  1::bigint,
  'historical email reactivation is audited exactly once'
);
select is(
  (
    select count(*)
    from public.contact_verifications
    where profile_id = current_setting('test.other_profile_id')::uuid
      and channel = 'email'
      and state in ('pending', 'verified')
  ),
  1::bigint,
  'Auth lifecycle preserves one active email fact'
);
select is(
  (select active from public.admin_permissions where risk = 'high'),
  false,
  'high-risk permission remains disabled'
);
insert into auth.users(
  instance_id, id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) values (
  '00000000-0000-0000-0000-000000000000',
  '10000000-0000-0000-0000-000000000003',
  'authenticated', 'authenticated', 'x@example.test',
  crypt('local-password', gen_salt('bf')), null,
  '{"provider":"email","providers":["email"]}', '{}', now(), now()
);
select is(
  (select display_name from public.profiles where auth_user_id =
    '10000000-0000-0000-0000-000000000003'),
  'Akun Jasama',
  'Auth profile creation uses a valid fallback display name'
);
delete from public.contact_verifications
where profile_id = (
  select id from public.profiles
  where auth_user_id = '10000000-0000-0000-0000-000000000003'
);
delete from public.profiles
where auth_user_id = '10000000-0000-0000-0000-000000000003';
select set_config(
  'request.jwt.claim.sub',
  '10000000-0000-0000-0000-000000000003',
  true
);
set local role authenticated;
select is(
  public.has_admin_permission('profile.support', 'global', null),
  false,
  'an Auth identity without a profile cannot authorize'
);
select is(
  public.grant_admin_permission(
    current_setting('test.other_profile_id')::uuid,
    'profile.support',
    'global',
    null,
    'Missing profile attempt'
  ),
  null,
  'an Auth identity without a profile cannot grant'
);
reset role;
select is(
  (
    select count(*)
    from public.audit_events
    where action = 'admin_permission.grant_denied'
      and actor_kind = 'system'
  ),
  0::bigint,
  'an unresolved runtime actor is never recorded as system'
);

select set_config(
  'request.jwt.claim.sub',
  '10000000-0000-0000-0000-000000000001',
  true
);
select set_config(
  'test.profile_updated_at',
  (
    select updated_at::text
    from public.profiles
    where id = current_setting('test.owner_profile_id')::uuid
  ),
  true
);
select set_config(
  'test.profile_lock_version',
  (
    select lock_version::text
    from public.profiles
    where id = current_setting('test.owner_profile_id')::uuid
  ),
  true
);
set local role authenticated;

select is(
  (select count(display_name) from public.profiles),
  1::bigint,
  'owner reads only their own profile through RLS'
);
select throws_ok(
  $$select auth_user_id from public.profiles$$,
  '42501',
  null,
  'authenticated owner cannot read internal Auth identity'
);
select throws_ok(
  $$select is_demo from public.profiles$$,
  '42501',
  null,
  'authenticated owner cannot read the internal demo marker'
);
select throws_ok(
  $$update public.profiles set display_name = 'DML langsung'$$,
  '42501',
  'permission denied for table profiles',
  'owner cannot update the profile table directly'
);
select set_config(
  'test.profile_command_result',
  to_jsonb(
    public.update_current_profile(
      'Nama Diperbarui',
      'id-ID',
      'Asia/Jakarta',
      current_setting('test.profile_lock_version')::bigint
    )
  )::text,
  true
);
select is(
  (current_setting('test.profile_command_result')::jsonb ->> 'success')::boolean,
  true,
  'owner profile command succeeds'
);
select is(
  current_setting('test.profile_command_result')::jsonb ->> 'code',
  'ok',
  'owner profile command returns a stable success code'
);
select is(
  (select display_name from public.profiles),
  'Nama Diperbarui',
  'owner profile command updates an approved field'
);
reset role;
select ok(
  (
    select updated_at >
      current_setting('test.profile_updated_at')::timestamptz
    from public.profiles
    where id = current_setting('test.owner_profile_id')::uuid
  ),
  'profile command advances updated_at'
);
select set_config(
  'test.profile_updated_after_change',
  (
    select updated_at::text
    from public.profiles
    where id = current_setting('test.owner_profile_id')::uuid
  ),
  true
);
set local role authenticated;
select ok(
  (
    public.update_current_profile(
      'Nama Diperbarui',
      'id-ID',
      'Asia/Jakarta',
      current_setting('test.profile_lock_version')::bigint + 1
    )
  ).success,
  'normalized no-op profile command succeeds'
);
select is(
  (select lock_version from public.profiles),
  current_setting('test.profile_lock_version')::bigint + 1,
  'normalized no-op does not increment lock_version'
);
reset role;
select is(
  (
    select updated_at
    from public.profiles
    where id = current_setting('test.owner_profile_id')::uuid
  ),
  current_setting('test.profile_updated_after_change')::timestamptz,
  'normalized no-op leaves updated_at unchanged'
);
select is(
  (
    select count(*)
    from public.audit_events
    where action = 'profile.updated'
      and object_id = current_setting('test.owner_profile_id')::uuid
  ),
  1::bigint,
  'normalized no-op appends no profile audit'
);
set local role authenticated;
select is(
  (select lock_version from public.profiles),
  current_setting('test.profile_lock_version')::bigint + 1,
  'profile command increments lock_version exactly once'
);
select is(
  (
    current_setting('test.profile_command_result')::jsonb
      ->> 'lock_version'
  )::bigint,
  current_setting('test.profile_lock_version')::bigint + 1,
  'profile command returns the resulting lock version'
);
select set_config(
  'test.profile_lock_after_command',
  (select lock_version::text from public.profiles),
  true
);
select set_config(
  'test.profile_stale_result',
  to_jsonb(
    public.update_current_profile(
      'Nama Stale',
      'id-ID',
      'Asia/Jakarta',
      current_setting('test.profile_lock_version')::bigint
    )
  )::text,
  true
);
select is(
  current_setting('test.profile_stale_result')::jsonb ->> 'code',
  'stale_version',
  'stale profile command returns a stable conflict code'
);
select is(
  (select display_name from public.profiles),
  'Nama Diperbarui',
  'stale profile command does not change profile values'
);
select is(
  (select lock_version from public.profiles),
  current_setting('test.profile_lock_after_command')::bigint,
  'stale profile command does not change lock_version'
);
select set_config(
  'test.profile_validation_result',
  to_jsonb(
    public.update_current_profile(
      'X',
      'id-ID',
      'Asia/Jakarta',
      current_setting('test.profile_lock_after_command')::bigint
    )
  )::text,
  true
);
select is(
  current_setting('test.profile_validation_result')::jsonb ->> 'code',
  'validation_failed',
  'invalid profile command returns a stable validation code'
);
select throws_ok(
  $$update public.profiles set account_state = 'suspended'$$,
  '42501',
  'permission denied for table profiles',
  'owner cannot update a protected profile field'
);
select throws_ok(
  $$update public.profiles set updated_at = now()$$,
  '42501',
  'permission denied for table profiles',
  'owner cannot set profile updated_at directly'
);
select throws_ok(
  $$update public.profiles set lock_version = lock_version + 10$$,
  '42501',
  'permission denied for table profiles',
  'owner cannot set profile lock_version directly'
);
select throws_ok(
  $$insert into public.profiles(auth_user_id, display_name)
    values ('10000000-0000-0000-0000-000000000003', 'Identitas Palsu')$$,
  '42501',
  'permission denied for table profiles',
  'owner cannot insert an arbitrary profile identity'
);
reset role;
select is(
  (
    select display_name
    from public.profiles
    where id = current_setting('test.other_profile_id')::uuid
  ),
  'Pengguna Lain',
  'profile command cannot target another user'
);
select is(
  (
    select count(*)
    from public.audit_events
    where action = 'profile.updated'
      and object_id = current_setting('test.owner_profile_id')::uuid
  ),
  1::bigint,
  'successful profile command appends one audit event'
);
select is(
  (
    select safe_metadata
    from public.audit_events
    where action = 'profile.updated'
      and object_id = current_setting('test.owner_profile_id')::uuid
  ),
  '{"changed_fields":["display_name"]}'::jsonb,
  'profile audit stores changed field names only'
);
select is(
  (
    select count(*)
    from public.outbox_events
    where event_name = 'profile.updated.v1'
  ),
  0::bigint,
  'profile command does not invent an unauthorized outbox event'
);
set local role anon;
select throws_ok(
  $$select * from public.profiles$$,
  '42501',
  'permission denied for table profiles',
  'anonymous profile-table access is denied'
);
select throws_ok(
  $$select * from public.admin_permissions$$,
  '42501',
  null,
  'anonymous permission-catalog access is denied'
);
select throws_ok(
  $$select * from public.admin_permission_assignments$$,
  '42501',
  'permission denied for table admin_permission_assignments',
  'anonymous assignment-table access is denied'
);
set local role authenticated;
select is(
  (select count(state) from public.contact_verifications),
  1::bigint,
  'active email query excludes historical email facts'
);
select is(
  (
    select state::text
    from public.contact_verifications
    where channel = 'email'
      and state in ('pending', 'verified')
  ),
  'verified',
  'historical email facts cannot replace the active verified result'
);
select throws_ok(
  $$select destination_hash from public.contact_verifications$$,
  '42501',
  null,
  'authenticated owner cannot read contact destination hashes'
);
select throws_ok(
  $$select profile_id from public.contact_verifications$$,
  '42501',
  null,
  'authenticated owner cannot read contact profile identities'
);
select throws_ok(
  $$select * from public.admin_permissions$$,
  '42501',
  null,
  'authenticated users cannot read the permission catalog'
);
select is(
  (select count(state) from public.contact_verifications),
  1::bigint,
  'owner reads only their contact verification'
);
select throws_ok(
  $$update public.contact_verifications set state = 'verified'$$,
  '42501',
  'permission denied for table contact_verifications',
  'owner cannot self-verify a contact'
);
select throws_ok(
  $$insert into public.admin_permission_assignments default values$$,
  '42501',
  'permission denied for table admin_permission_assignments',
  'browser role cannot create permission assignments directly'
);
select throws_ok(
  $$select * from public.audit_events$$,
  '42501',
  'permission denied for table audit_events',
  'browser role cannot read privileged audit records'
);
select throws_ok(
  $$insert into public.idempotency_records default values$$,
  '42501',
  'permission denied for table idempotency_records',
  'browser role cannot mutate idempotency internals'
);
select throws_ok(
  $$insert into public.outbox_events default values$$,
  '42501',
  'permission denied for table outbox_events',
  'browser role cannot mutate outbox internals'
);
reset role;

select ok(
  provisioning.bootstrap_admin(
    '10000000-0000-0000-0000-000000000001',
    array[
      row('admin.permissions.manage', 'global', null)
        ::public.admin_permission_scope_request,
      row('profile.support', 'global', null)
        ::public.admin_permission_scope_request,
      row(
        'profile.support',
        'locality',
        '40000000-0000-0000-0000-000000000001'
      )::public.admin_permission_scope_request
    ],
    'local-review-001',
    'Local exact bootstrap test'
  ),
  'exact local provisioning succeeds'
);
select is(
  (
    select count(*)
    from public.admin_permission_assignments
    where provisioning_change_ref = 'local-review-001'
  ),
  3::bigint,
  'provisioning creates the exact permission set'
);
select is(
  (
    select count(*)
    from public.admin_permission_assignments
    where provisioning_change_ref = 'local-review-001'
      and scope_type = 'global'
      and scope_id is null
  ),
  2::bigint,
  'provisioning preserves global null-scope entries'
);
select is(
  (
    select count(*)
    from public.admin_permission_assignments
    where provisioning_change_ref = 'local-review-001'
      and scope_type = 'locality'
      and scope_id = '40000000-0000-0000-0000-000000000001'
  ),
  1::bigint,
  'provisioning preserves a locality-scoped entry'
);
select ok(
  provisioning.bootstrap_admin(
    '10000000-0000-0000-0000-000000000001',
    array[
      row(
        'profile.support',
        'locality',
        '40000000-0000-0000-0000-000000000001'
      )::public.admin_permission_scope_request,
      row('profile.support', 'global', null)
        ::public.admin_permission_scope_request,
      row('admin.permissions.manage', 'global', null)
        ::public.admin_permission_scope_request
    ],
    'local-review-001',
    'Local exact bootstrap test'
  ),
  'exact provisioning replay succeeds'
);
select is(
  (
    select count(*)
    from public.admin_permission_assignments
    where provisioning_change_ref = 'local-review-001'
  ),
  3::bigint,
  'provisioning replay does not duplicate assignments'
);
select isnt(
  provisioning.bootstrap_admin(
    '10000000-0000-0000-0000-000000000001',
    array[
      row('admin.permissions.manage', 'global', null)
        ::public.admin_permission_scope_request,
      row('profile.support', 'global', null)
        ::public.admin_permission_scope_request
    ],
    'local-review-001',
    'Attempted set reduction'
  ),
  true,
  'a change reference cannot be reused with a reduced set'
);
select isnt(
  provisioning.bootstrap_admin(
    '10000000-0000-0000-0000-000000000001',
    array[
      row('admin.permissions.manage', 'global', null)
        ::public.admin_permission_scope_request,
      row('profile.support', 'global', null)
        ::public.admin_permission_scope_request,
      row(
        'profile.support',
        'locality',
        '40000000-0000-0000-0000-000000000001'
      )::public.admin_permission_scope_request,
      row('account.moderate', 'global', null)
        ::public.admin_permission_scope_request
    ],
    'local-review-001',
    'Attempted set addition'
  ),
  true,
  'a change reference cannot be reused with an expanded set'
);
select isnt(
  provisioning.bootstrap_admin(
    '10000000-0000-0000-0000-000000000002',
    array[
      row('admin.permissions.manage', 'global', null)
        ::public.admin_permission_scope_request,
      row('profile.support', 'global', null)
        ::public.admin_permission_scope_request,
      row(
        'profile.support',
        'locality',
        '40000000-0000-0000-0000-000000000001'
      )::public.admin_permission_scope_request
    ],
    'local-review-001',
    'Attempted retarget'
  ),
  true,
  'a change reference cannot be reused for another target'
);
select isnt(
  provisioning.bootstrap_admin(
    '10000000-0000-0000-0000-000000000001',
    array[
      row('admin.permissions.manage', 'global', null)
        ::public.admin_permission_scope_request,
      row('account.moderate', 'global', null)
        ::public.admin_permission_scope_request,
      row(
        'profile.support',
        'locality',
        '40000000-0000-0000-0000-000000000001'
      )::public.admin_permission_scope_request
    ],
    'local-review-001',
    'Attempted permission substitution'
  ),
  true,
  'a change reference cannot substitute a permission'
);
select isnt(
  provisioning.bootstrap_admin(
    '10000000-0000-0000-0000-000000000001',
    array[
      row(
        'admin.permissions.manage',
        'locality',
        '40000000-0000-0000-0000-000000000001'
      )::public.admin_permission_scope_request,
      row('profile.support', 'global', null)
        ::public.admin_permission_scope_request,
      row(
        'profile.support',
        'locality',
        '40000000-0000-0000-0000-000000000001'
      )::public.admin_permission_scope_request
    ],
    'local-review-001',
    'Attempted scope-type substitution'
  ),
  true,
  'a change reference cannot change scope type'
);
select isnt(
  provisioning.bootstrap_admin(
    '10000000-0000-0000-0000-000000000001',
    array[
      row('admin.permissions.manage', 'global', null)
        ::public.admin_permission_scope_request,
      row('profile.support', 'global', null)
        ::public.admin_permission_scope_request,
      row(
        'profile.support',
        'locality',
        '40000000-0000-0000-0000-000000000002'
      )::public.admin_permission_scope_request
    ],
    'local-review-001',
    'Attempted scope-id substitution'
  ),
  true,
  'a change reference cannot change scope ID'
);
select isnt(
  provisioning.bootstrap_admin(
    '10000000-0000-0000-0000-000000000002',
    array[
      row('profile.support', 'global', null)
        ::public.admin_permission_scope_request,
      row('profile.support', 'global', null)
        ::public.admin_permission_scope_request
    ],
    'local-review-duplicate',
    'Duplicate typed entries'
  ),
  true,
  'duplicate typed provisioning entries are rejected'
);
select isnt(
  provisioning.bootstrap_admin(
    '10000000-0000-0000-0000-000000000002',
    array[
      row(
        'profile.support',
        'global',
        '40000000-0000-0000-0000-000000000001'
      )::public.admin_permission_scope_request
    ],
    'local-review-global-scope',
    'Invalid global scope'
  ),
  true,
  'global provisioning scope rejects a scope ID'
);
select isnt(
  provisioning.bootstrap_admin(
    '10000000-0000-0000-0000-000000000002',
    array[
      row('profile.support', 'locality', null)
        ::public.admin_permission_scope_request
    ],
    'local-review-locality-scope',
    'Invalid locality scope'
  ),
  true,
  'locality provisioning scope requires a scope ID'
);
select isnt(
  provisioning.bootstrap_admin(
    '10000000-0000-0000-0000-000000000002',
    array[
      row('admin.permissions.high_risk', 'global', null)
        ::public.admin_permission_scope_request
    ],
    'local-review-high-risk',
    'High-risk permission attempt'
  ),
  true,
  'inactive high-risk provisioning permission is rejected'
);
select is(
  (select count(*) from public.admin_permission_assignments),
  3::bigint,
  'rejected provisioning calls leave the exact assignment set unchanged'
);
select ok(
  (
    select count(*) >= 2
    from public.audit_events
    where actor_kind = 'system_provisioning'
      and safe_metadata ->> 'change_reference' = 'local-review-001'
  ),
  'system provisioning and replay are audited'
);
select is(
  (
    select jsonb_array_length(safe_metadata -> 'permission_scope_set')
    from public.audit_events
    where action = 'admin_provisioning.completed'
      and safe_metadata ->> 'change_reference' = 'local-review-001'
  ),
  3,
  'provisioning audit records the exact permission and scope set'
);
select is(
  (
    select safe_metadata -> 'permission_scope_set'
    from public.audit_events
    where action = 'admin_provisioning.completed'
      and safe_metadata ->> 'change_reference' = 'local-review-001'
  ),
  jsonb_build_array(
    jsonb_build_object(
      'permission_code', 'admin.permissions.manage',
      'scope_type', 'global',
      'scope_id', null
    ),
    jsonb_build_object(
      'permission_code', 'profile.support',
      'scope_type', 'global',
      'scope_id', null
    ),
    jsonb_build_object(
      'permission_code', 'profile.support',
      'scope_type', 'locality',
      'scope_id', '40000000-0000-0000-0000-000000000001'::uuid
    )
  ),
  'provisioning audit metadata matches the reviewed typed set'
);

insert into auth.users(
  instance_id, id, aud, role, email, encrypted_password,
  email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at
) values (
  '00000000-0000-0000-0000-000000000000',
  '10000000-0000-0000-0000-000000000004',
  'authenticated', 'authenticated', 'recovery@example.test',
  crypt('local-password', gen_salt('bf')), now(),
  '{"provider":"email","providers":["email"]}',
  '{"display_name":"Pemulihan Hibah"}', now(), now()
);
select ok(
  provisioning.bootstrap_admin(
    '10000000-0000-0000-0000-000000000004',
    array[
      row('profile.support', 'global', null)
        ::public.admin_permission_scope_request
    ],
    'local-expiry-seed',
    'Seed expiring provisioning grant'
  ),
  'provisioning creates the grant that will expire'
);
update public.admin_permission_assignments
set starts_at = statement_timestamp() - interval '2 days',
    expires_at = statement_timestamp() - interval '1 day'
where provisioning_change_ref = 'local-expiry-seed';
select ok(
  provisioning.bootstrap_admin(
    '10000000-0000-0000-0000-000000000004',
    array[
      row('profile.support', 'global', null)
        ::public.admin_permission_scope_request
    ],
    'local-expiry-recovery',
    'Reviewed replacement after expiry'
  ),
  'reviewed provisioning recovery replaces an expired assignment'
);
select is(
  (
    select count(*)
    from public.admin_permission_assignments assignment
    join public.profiles profile on profile.id = assignment.profile_id
    where profile.auth_user_id =
      '10000000-0000-0000-0000-000000000004'
  ),
  2::bigint,
  'provisioning recovery preserves expired assignment history'
);
select ok(
  (
    select revoked_at is not null
    from public.admin_permission_assignments
    where provisioning_change_ref = 'local-expiry-seed'
  ),
  'provisioning recovery closes the expired unrevoked assignment'
);
select is(
  (
    select count(*)
    from public.audit_events
    where action = 'admin_permission.expired'
      and actor_kind = 'system_provisioning'
      and reason_code = 'closed_before_regrant'
  ),
  1::bigint,
  'provisioning expiry closure is audited'
);
select is(
  (
    select count(*)
    from public.admin_permission_assignments
    where provisioning_change_ref = 'local-expiry-recovery'
      and revoked_at is null
  ),
  1::bigint,
  'provisioning recovery creates one non-overlapping active grant'
);

select set_config(
  'request.jwt.claim.sub',
  '10000000-0000-0000-0000-000000000001',
  true
);
set local role authenticated;
select throws_ok(
  $$select * from public.admin_permission_assignments$$,
  '42501',
  'permission denied for table admin_permission_assignments',
  'authenticated base assignment-table reads are denied'
);
select is(
  (select count(*) from public.current_effective_admin_permissions()),
  3::bigint,
  'active non-demo subject reads only their three effective grants'
);
select ok(
  not exists (
    select 1
    from public.current_effective_admin_permissions() effective_grant
    where to_jsonb(effective_grant) ?| array[
      'provisioning_change_ref',
      'reason',
      'granted_by_profile_id',
      'revoked_at'
    ]
  ),
  'effective grant projection excludes internal assignment fields'
);
select is(
  public.has_admin_permission('admin.permissions.manage', 'global', null),
  true,
  'active non-demo administrator authorizes'
);
reset role;

update public.profiles set account_state = 'limited'
where id = current_setting('test.owner_profile_id')::uuid;
set local role authenticated;
select is(
  public.has_admin_permission('admin.permissions.manage', 'global', null),
  false,
  'limited administrator cannot authorize'
);
select is(
  (
    public.update_current_profile(
      'Nama Ditolak',
      'id-ID',
      'Asia/Jakarta',
      0
    )
  ).code::text,
  'forbidden',
  'inactive profile cannot use the profile update command'
);
select is(
  public.grant_admin_permission(
    current_setting('test.other_profile_id')::uuid,
    'profile.support',
    'global',
    null,
    'Inactive administrator attempt'
  ),
  null,
  'limited administrator cannot grant'
);
reset role;
update public.profiles set account_state = 'suspended'
where id = current_setting('test.owner_profile_id')::uuid;
set local role authenticated;
select is(
  public.has_admin_permission('admin.permissions.manage', 'global', null),
  false,
  'suspended administrator cannot authorize'
);
reset role;
update public.profiles set account_state = 'banned'
where id = current_setting('test.owner_profile_id')::uuid;
set local role authenticated;
select is(
  public.has_admin_permission('admin.permissions.manage', 'global', null),
  false,
  'banned administrator cannot authorize'
);
reset role;
update public.profiles set account_state = 'appeal_pending'
where id = current_setting('test.owner_profile_id')::uuid;
set local role authenticated;
select is(
  public.has_admin_permission('admin.permissions.manage', 'global', null),
  false,
  'appeal-pending administrator cannot authorize'
);
reset role;
update public.profiles
set account_state = 'deactivated', deactivated_at = now()
where id = current_setting('test.owner_profile_id')::uuid;
set local role authenticated;
select is(
  public.has_admin_permission('admin.permissions.manage', 'global', null),
  false,
  'deactivated administrator cannot authorize'
);
reset role;
update public.profiles
set account_state = 'active', deactivated_at = null, is_demo = true
where id = current_setting('test.owner_profile_id')::uuid;
set local role authenticated;
select is(
  public.has_admin_permission('admin.permissions.manage', 'global', null),
  false,
  'demo administrator cannot authorize'
);
select is(
  (select count(*) from public.current_effective_admin_permissions()),
  0::bigint,
  'demo account receives no effective grants'
);
select is(
  (
    public.update_current_profile(
      'Nama Demo Ditolak',
      'id-ID',
      'Asia/Jakarta',
      0
    )
  ).code::text,
  'forbidden',
  'demo profile cannot use the profile update command'
);
reset role;
update public.profiles set is_demo = false
where id = current_setting('test.owner_profile_id')::uuid;
set local role authenticated;
select is(
  public.has_admin_permission('admin.permissions.manage', 'global', null),
  true,
  'restoring active non-demo state restores otherwise valid permission'
);
reset role;

update public.admin_permission_assignments assignment
set starts_at = now() - interval '2 days',
    expires_at = now() - interval '1 day'
from public.admin_permissions permission
where permission.id = assignment.permission_id
  and assignment.profile_id = current_setting('test.owner_profile_id')::uuid
  and permission.code = 'profile.support'
  and assignment.scope_type = 'locality';
set local role authenticated;
select is(
  public.has_admin_permission(
    'profile.support',
    'locality',
    '40000000-0000-0000-0000-000000000001'
  ),
  false,
  'expired assignment cannot authorize'
);
select is(
  (select count(*) from public.current_effective_admin_permissions()),
  2::bigint,
  'expired assignment is absent from effective grants'
);
reset role;
update public.admin_permission_assignments assignment
set expires_at = null, revoked_at = now()
from public.admin_permissions permission
where permission.id = assignment.permission_id
  and assignment.profile_id = current_setting('test.owner_profile_id')::uuid
  and permission.code = 'profile.support'
  and assignment.scope_type = 'locality';
set local role authenticated;
select is(
  public.has_admin_permission(
    'profile.support',
    'locality',
    '40000000-0000-0000-0000-000000000001'
  ),
  false,
  'revoked assignment cannot authorize'
);
select is(
  (select count(*) from public.current_effective_admin_permissions()),
  2::bigint,
  'revoked assignment is absent from effective grants'
);
reset role;
update public.profiles set account_state = 'limited'
where id = current_setting('test.owner_profile_id')::uuid;
set local role authenticated;
select is(
  (select count(*) from public.current_effective_admin_permissions()),
  0::bigint,
  'inactive account receives no effective grants'
);
reset role;
update public.profiles set account_state = 'active', is_demo = false
where id = current_setting('test.owner_profile_id')::uuid;
set local role authenticated;
select is(
  (select count(*) from public.current_effective_admin_permissions()),
  2::bigint,
  'restoring the profile restores only otherwise valid effective grants'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '10000000-0000-0000-0000-000000000002',
  true
);
set local role authenticated;
select is(
  (select count(*) from public.current_effective_admin_permissions()),
  0::bigint,
  'effective grant query cannot read another profile assignments'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '10000000-0000-0000-0000-000000000001',
  true
);
set local role authenticated;
select throws_ok(
  $$select provisioning.bootstrap_admin(
    '10000000-0000-0000-0000-000000000002',
    array[
      row('profile.support', 'global', null)
        ::public.admin_permission_scope_request
    ],
    'runtime-forbidden',
    'Must not run'
  )$$,
  '42501',
  null,
  'runtime roles cannot invoke provisioning'
);
select is(
  public.grant_admin_permission(
    public.current_profile_id(),
    'profile.support',
    'global',
    null,
    'Self grant must fail'
  ),
  null,
  'permission manager cannot self-grant'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '10000000-0000-0000-0000-000000000002',
  true
);
set local role authenticated;
select is(
  public.grant_admin_permission(
    current_setting('test.owner_profile_id')::uuid,
    'profile.support',
    'global',
    null,
    'Insufficient manager must fail'
  ),
  null,
  'an insufficient manager cannot grant'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '10000000-0000-0000-0000-000000000001',
  true
);
set local role authenticated;
select is(
  public.grant_admin_permission(
    current_setting('test.other_profile_id')::uuid,
    'account.moderate',
    'global',
    null,
    'Set expansion must fail'
  ),
  null,
  'permission-set expansion is denied'
);
select isnt(
  public.grant_admin_permission(
    current_setting('test.other_profile_id')::uuid,
    'profile.support',
    'global',
    null,
    'Approved ordinary local grant'
  ),
  null,
  'an authorized manager grants an already-held permission'
);
reset role;

select set_config(
  'test.expired_admin_assignment_id',
  (
    select assignment.id::text
    from public.admin_permission_assignments assignment
    join public.admin_permissions permission
      on permission.id = assignment.permission_id
    where assignment.profile_id =
      current_setting('test.other_profile_id')::uuid
      and permission.code = 'profile.support'
      and assignment.grant_source = 'admin'
    order by assignment.created_at
    limit 1
  ),
  true
);
update public.admin_permission_assignments
set starts_at = statement_timestamp() - interval '2 days',
    expires_at = statement_timestamp() - interval '1 day'
where id = current_setting('test.expired_admin_assignment_id')::uuid;
select set_config(
  'request.jwt.claim.sub',
  '10000000-0000-0000-0000-000000000001',
  true
);
set local role authenticated;
select set_config(
  'test.replacement_assignment_id',
  public.grant_admin_permission(
    current_setting('test.other_profile_id')::uuid,
    'profile.support',
    'global',
    null,
    'Reviewed replacement after expiry'
  )::text,
  true
);
select is(
  public.grant_admin_permission(
    current_setting('test.other_profile_id')::uuid,
    'profile.support',
    'global',
    null,
    'Active duplicate must be a no-op'
  ),
  null,
  'active duplicate grant is rejected as a semantic no-op'
);
reset role;
select ok(
  current_setting('test.replacement_assignment_id', true) is not null,
  'reviewed re-grant after expiry succeeds'
);
select is(
  (
    select count(*)
    from public.admin_permission_assignments assignment
    join public.admin_permissions permission
      on permission.id = assignment.permission_id
    where assignment.profile_id =
      current_setting('test.other_profile_id')::uuid
      and permission.code = 'profile.support'
      and assignment.scope_type = 'global'
      and assignment.grant_source = 'admin'
  ),
  2::bigint,
  'ordinary re-grant preserves assignment history'
);
select ok(
  (
    select revoked_at is not null
    from public.admin_permission_assignments
    where id = current_setting('test.expired_admin_assignment_id')::uuid
  ),
  'ordinary re-grant closes the expired assignment'
);
select is(
  (
    select count(*)
    from public.audit_events
    where object_id =
      current_setting('test.expired_admin_assignment_id')::uuid
      and action = 'admin_permission.expired'
  ),
  1::bigint,
  'ordinary expiry closure is audited exactly once'
);
select is(
  (
    select count(*)
    from public.audit_events
    where object_id =
      current_setting('test.replacement_assignment_id')::uuid
      and action = 'admin_permission.granted'
  ),
  1::bigint,
  'replacement grant is audited exactly once'
);
select is(
  (
    select count(*)
    from public.admin_permission_assignments assignment
    join public.admin_permissions permission
      on permission.id = assignment.permission_id
    where assignment.profile_id =
      current_setting('test.other_profile_id')::uuid
      and permission.code = 'profile.support'
      and assignment.scope_type = 'global'
      and assignment.revoked_at is null
  ),
  1::bigint,
  'database uniqueness preserves one active ordinary grant'
);
select set_config(
  'test.granted_assignment_id',
  current_setting('test.replacement_assignment_id'),
  true
);
select set_config(
  'request.jwt.claim.sub',
  '10000000-0000-0000-0000-000000000002',
  true
);
set local role authenticated;
select is(
  (select count(*) from public.current_effective_admin_permissions()),
  1::bigint,
  'a subject reads only their own effective assignment'
);
reset role;

update public.profiles set account_state = 'suspended'
where id = current_setting('test.owner_profile_id')::uuid;
select set_config(
  'request.jwt.claim.sub',
  '10000000-0000-0000-0000-000000000001',
  true
);
set local role authenticated;
select is(
  public.revoke_admin_permission(
    current_setting('test.granted_assignment_id')::uuid,
    'Inactive administrator revoke'
  ),
  false,
  'suspended administrator cannot revoke'
);
reset role;
update public.profiles set account_state = 'active'
where id = current_setting('test.owner_profile_id')::uuid;
set local role authenticated;
select is(
  public.revoke_admin_permission(
    current_setting('test.granted_assignment_id')::uuid,
    'Reviewed revoke reason'
  ),
  true,
  'an authorized manager revokes an ordinary assignment once'
);
reset role;
select is(
  (
    select reason
    from public.admin_permission_assignments
    where id = current_setting('test.granted_assignment_id')::uuid
  ),
  'Reviewed replacement after expiry',
  'revocation preserves the original grant reason'
);
select ok(
  (
    select revoked_at is not null
    from public.admin_permission_assignments
    where id = current_setting('test.granted_assignment_id')::uuid
  ),
  'first revocation sets revoked_at'
);
select set_config(
  'test.revoked_at',
  (
    select revoked_at::text
    from public.admin_permission_assignments
    where id = current_setting('test.granted_assignment_id')::uuid
  ),
  true
);
select set_config(
  'request.jwt.claim.sub',
  '10000000-0000-0000-0000-000000000001',
  true
);
set local role authenticated;
select is(
  public.revoke_admin_permission(
    current_setting('test.granted_assignment_id')::uuid,
    'Reviewed revoke reason'
  ),
  true,
  'an exact revocation replay returns the same success'
);
select is(
  public.revoke_admin_permission(
    current_setting('test.granted_assignment_id')::uuid,
    'Different revoke reason'
  ),
  false,
  'a revocation replay with different input is rejected'
);
reset role;
select is(
  (
    select revoked_at
    from public.admin_permission_assignments
    where id = current_setting('test.granted_assignment_id')::uuid
  ),
  current_setting('test.revoked_at')::timestamptz,
  'revocation replay leaves revoked_at unchanged'
);
select is(
  (
    select count(*)
    from public.audit_events
    where object_id = current_setting('test.granted_assignment_id')::uuid
      and action = 'admin_permission.revoked'
  ),
  1::bigint,
  'revocation has exactly one first-lifecycle audit effect'
);
select is(
  (
    select count(*)
    from public.audit_events
    where object_id = current_setting('test.granted_assignment_id')::uuid
      and action = 'admin_permission.revoke_replayed'
  ),
  1::bigint,
  'exact revocation replay is audited separately'
);
select set_config(
  'test.owner_assignment_id',
  (
    select id::text
    from public.admin_permission_assignments
    where profile_id = current_setting('test.owner_profile_id')::uuid
    limit 1
  ),
  true
);
select set_config(
  'request.jwt.claim.sub',
  '10000000-0000-0000-0000-000000000002',
  true
);
set local role authenticated;
select is(
  public.revoke_admin_permission(
    current_setting('test.granted_assignment_id')::uuid,
    'Self revoke attempt'
  ),
  false,
  'a subject cannot manipulate their own permission revocation'
);
select is(
  public.revoke_admin_permission(
    current_setting('test.owner_assignment_id')::uuid,
    'Insufficient revoke attempt'
  ),
  false,
  'an insufficient manager cannot revoke another assignment'
);
select is(
  public.has_admin_permission('profile.support', 'global', null),
  false,
  'a revoked assignment no longer authorizes'
);
select is(
  (select count(*) from public.current_effective_admin_permissions()),
  0::bigint,
  'a revoked assignment no longer appears in effective grants'
);
reset role;

select throws_ok(
  $$insert into public.audit_events(
    actor_kind, action, object_type, object_id, correlation_id, request_id
  ) values (
    'user', 'invalid.user.actor', 'profile',
    '00000000-0000-0000-0000-000000000010',
    gen_random_uuid(), gen_random_uuid()
  )$$,
  '23514',
  null,
  'user audit actor requires a profile identity'
);
select throws_ok(
  $$insert into public.audit_events(
    actor_profile_id, actor_kind, action, object_type, object_id,
    correlation_id, request_id
  ) values (
    current_setting('test.owner_profile_id')::uuid,
    'system', 'invalid.system.actor', 'profile',
    '00000000-0000-0000-0000-000000000010',
    gen_random_uuid(), gen_random_uuid()
  )$$,
  '23514',
  null,
  'system audit actor forbids a profile identity'
);
select throws_ok(
  $$update public.audit_events set action = 'tampered'$$,
  '42501',
  'audit_events is append-only',
  'audit update is rejected'
);
select throws_ok(
  $$delete from public.audit_events$$,
  '42501',
  'audit_events is append-only',
  'audit delete is rejected'
);

insert into public.idempotency_records(
  scope, command_name, idempotency_key, input_hash, state, result_code,
  result_object_type, result_object_id, correlation_id, completed_at, expires_at
) values (
  'profile:local', 'updateProfile', 'local-key-0001',
  repeat('a', 64), 'completed', 'OK', 'profile',
  '20000000-0000-0000-0000-000000000001',
  '30000000-0000-0000-0000-000000000001',
  now(), now() + interval '1 day'
);
select is(
  (select state::text from public.idempotency_records
   where idempotency_key = 'local-key-0001'),
  'completed',
  'completed idempotency result is stored'
);
select is(
  (select result_object_id from public.idempotency_records
   where idempotency_key = 'local-key-0001'),
  '20000000-0000-0000-0000-000000000001'::uuid,
  'same-key replay can return the original semantic result'
);
select throws_ok(
  $$insert into public.idempotency_records(
    scope, command_name, idempotency_key, input_hash, correlation_id, expires_at
  ) values (
    'profile:local', 'updateProfile', 'local-key-0001', repeat('b', 64),
    '30000000-0000-0000-0000-000000000002', now() + interval '1 day'
  )$$,
  '23505',
  null,
  'same idempotency key with incompatible input is rejected'
);

insert into public.outbox_events(
  event_name, aggregate_type, aggregate_id, aggregate_version,
  correlation_id, payload_version, payload
) values (
  'profile.updated.v1', 'profile',
  '20000000-0000-0000-0000-000000000001', 1,
  '30000000-0000-0000-0000-000000000001', 1,
  '{"profile_id":"20000000-0000-0000-0000-000000000001"}'
);
insert into public.outbox_event_deliveries(event_id, consumer_name)
select id, consumer
from public.outbox_events
cross join unnest(array['audit_projection.v1', 'notification_projection.v1'])
  as consumer;
select is(
  (select count(*) from public.outbox_event_deliveries),
  2::bigint,
  'outbox creates one delivery per required consumer'
);
select throws_ok(
  $$insert into public.outbox_event_deliveries(event_id, consumer_name)
    select id, 'audit_projection.v1' from public.outbox_events$$,
  '23505',
  null,
  'outbox delivery identity is unique per consumer'
);
update public.outbox_event_deliveries
set state = 'claimed', claimed_at = now(), attempt_count = 1
where consumer_name = 'audit_projection.v1';
select is(
  (
    select state::text
    from public.outbox_event_deliveries
    where consumer_name = 'notification_projection.v1'
  ),
  'pending',
  'one consumer claim does not suppress another consumer retry state'
);

select is(
  (
    select count(*)
    from public.audit_events
    where action = 'app_environment.seeded'
      and actor_kind = 'system_provisioning'
      and actor_profile_id is null
      and safe_metadata ->> 'provisioning_change_ref' =
        'local-phase-1-foundation'
  ),
  1::bigint,
  'initial local environment seed has one truthful audit event'
);
select set_config(
  'test.environment_before_provisioning',
  (select provisioned_at::text from public.app_environment where singleton),
  true
);
select ok(
  provisioning.configure_environment(
    'staging',
    true,
    true,
    'local-environment-review-001'
  ),
  'reviewed deployment-only environment change succeeds'
);
select is(
  (select environment::text from public.app_environment where singleton),
  'staging',
  'environment provisioning applies the exact reviewed environment'
);
select ok(
  (
    select provisioned_at >
      current_setting('test.environment_before_provisioning')::timestamptz
    from public.app_environment
    where singleton
  ),
  'environment provisioning uses database time'
);
select set_config(
  'test.environment_after_change',
  (select provisioned_at::text from public.app_environment where singleton),
  true
);
select ok(
  provisioning.configure_environment(
    'staging',
    true,
    true,
    'local-environment-review-001'
  ),
  'exact environment provisioning replay succeeds'
);
select is(
  (select provisioned_at from public.app_environment where singleton),
  current_setting('test.environment_after_change')::timestamptz,
  'exact replay is a semantic no-op'
);
select is(
  (
    select count(*)
    from public.audit_events
    where action = 'app_environment.changed'
      and safe_metadata ->> 'provisioning_change_ref' =
        'local-environment-review-001'
  ),
  1::bigint,
  'exact replay appends no false environment change event'
);
select is(
  (
    select count(*)
    from public.audit_events
    where action = 'app_environment.provision_replayed'
      and safe_metadata ->> 'provisioning_change_ref' =
        'local-environment-review-001'
  ),
  1::bigint,
  'exact replay is audited truthfully'
);
select isnt(
  provisioning.configure_environment(
    'test',
    true,
    true,
    'local-environment-review-001'
  ),
  true,
  'change reference reuse with another configuration is denied'
);
select is(
  (
    select count(*)
    from public.audit_events
    where action = 'app_environment.provision_denied'
      and reason_code = 'change_reference_mismatch'
      and safe_metadata ->> 'provisioning_change_ref' =
        'local-environment-review-001'
  ),
  1::bigint,
  'environment reference mismatch is audited without rollback'
);
select ok(
  provisioning.configure_environment(
    'staging',
    true,
    true,
    'local-environment-noop-001'
  ),
  'new reviewed reference with unchanged configuration succeeds'
);
select is(
  (select provisioned_at from public.app_environment where singleton),
  current_setting('test.environment_after_change')::timestamptz,
  'reviewed no-op leaves provisioned_at unchanged'
);
select is(
  (
    select count(*)
    from public.audit_events
    where action = 'app_environment.provision_noop'
      and safe_metadata ->> 'provisioning_change_ref' =
        'local-environment-noop-001'
  ),
  1::bigint,
  'reviewed no-op is audited without a false change event'
);
select isnt(
  provisioning.configure_environment(
    'production',
    true,
    false,
    'blocked-production-flags'
  ),
  true,
  'deployment operation rejects unsafe production flags'
);
select isnt(
  provisioning.configure_environment(
    'production',
    false,
    false,
    'blocked-production-reauthentication'
  ),
  true,
  'callable production enablement remains unavailable'
);
select is(
  (
    select count(*)
    from public.audit_events
    where action = 'app_environment.provision_denied'
      and reason_code in (
        'production_flags_denied',
        'production_reauthentication_unavailable'
      )
  ),
  2::bigint,
  'production provisioning denials are committed to audit'
);
select ok(
  provisioning.configure_environment(
    'development',
    true,
    true,
    'local-environment-return-development'
  ),
  'reviewed non-production provisioning can restore development'
);

set local role authenticated;
select throws_ok(
  $$update public.app_environment set demo_allowed = false$$,
  '42501',
  'permission denied for table app_environment',
  'runtime role cannot mutate environment configuration'
);
select throws_ok(
  $$select provisioning.configure_environment(
    'staging', false, false, 'runtime-environment-forbidden'
  )$$,
  '42501',
  null,
  'runtime role cannot invoke environment provisioning'
);
reset role;

update public.app_environment
set demo_allowed = false,
    provisioned_at = now(),
    provisioning_change_ref = 'local-demo-kill-switch';
select throws_ok(
  $$update public.profiles set is_demo = true
    where id = current_setting('test.other_profile_id')::uuid$$,
  '23514',
  'demo profiles are disabled in this environment',
  'non-production demo kill switch denies demo profile writes'
);
update public.app_environment
set demo_allowed = true,
    provisioned_at = now(),
    provisioning_change_ref = 'local-demo-fixture-review';
update public.profiles set is_demo = true
where id = current_setting('test.other_profile_id')::uuid;
select isnt(
  provisioning.configure_environment(
    'production',
    false,
    false,
    'blocked-production-with-demo-operation'
  ),
  true,
  'deployment operation rejects production while demo profiles exist'
);
select is(
  (
    select count(*)
    from public.audit_events
    where action = 'app_environment.provision_denied'
      and reason_code = 'demo_records_present'
      and safe_metadata ->> 'provisioning_change_ref' =
        'blocked-production-with-demo-operation'
  ),
  1::bigint,
  'demo-record production denial is committed to audit'
);
select throws_ok(
  $$update public.app_environment
    set environment = 'production',
        demo_allowed = false,
        mock_payment_allowed = false,
        provisioned_at = now(),
        provisioning_change_ref = 'blocked-production-with-demo'$$,
  '23514',
  'production environment cannot contain demo profiles',
  'switching to production rejects existing demo profiles'
);
select is(
  (select environment::text from public.app_environment),
  'development',
  'failed production switch leaves environment unchanged'
);
update public.profiles set is_demo = false
where id = current_setting('test.other_profile_id')::uuid;
update public.app_environment
set environment = 'production',
    demo_allowed = false,
    mock_payment_allowed = false,
    provisioned_at = now(),
    provisioning_change_ref = 'local-production-guard-test';
select is(
  (select environment::text from public.app_environment),
  'production',
  'production environment can be provisioned only with safe flags'
);
select throws_ok(
  $$update public.app_environment set mock_payment_allowed = true$$,
  '23514',
  null,
  'mock payment is rejected in production'
);
select throws_ok(
  $$update public.profiles set is_demo = true where auth_user_id =
    '10000000-0000-0000-0000-000000000002'$$,
  '23514',
  'demo profiles are disabled in this environment',
  'demo data is rejected in production'
);
select throws_ok(
  $$update public.app_environment
    set environment = 'development',
        provisioning_change_ref = 'blocked-production-downgrade'$$,
  '23514',
  'production environment cannot be downgraded',
  'production environment cannot be downgraded'
);
select isnt(
  provisioning.configure_environment(
    'development',
    false,
    false,
    'blocked-production-downgrade-operation'
  ),
  true,
  'deployment operation denies a production downgrade without raising'
);
select is(
  (
    select count(*)
    from public.audit_events
    where action = 'app_environment.provision_denied'
      and reason_code = 'production_downgrade_denied'
  ),
  1::bigint,
  'production downgrade denial is committed to audit'
);
select is(
  (
    select count(*)
    from public.audit_events
    where action = 'app_environment.changed'
      and actor_kind = 'system_provisioning'
      and safe_metadata ->> 'provisioning_change_ref' in (
        'local-demo-kill-switch',
        'local-demo-fixture-review',
        'local-production-guard-test'
      )
  ),
  3::bigint,
  'reviewed environment changes have truthful provisioning audit provenance'
);
select is(
  (
    select count(*)
    from public.audit_events
    where action = 'app_environment.changed'
      and safe_metadata ->> 'provisioning_change_ref' =
        'local-production-guard-test'
  ),
  1::bigint,
  'environment audit records the reviewed change reference'
);
select throws_ok(
  $$insert into public.admin_permission_assignments(
    profile_id, permission_id, scope_type, grant_source,
    provisioning_change_ref, reason
  ) select id, (select id from public.admin_permissions limit 1),
    'global', 'provisioning', '', 'Invalid reference'
    from public.profiles limit 1$$,
  '23514',
  null,
  'provisioning requires a nonblank change reference'
);
select is(
  has_table_privilege('authenticated', 'public.profiles', 'UPDATE'),
  false,
  'authenticated role has no direct profile update grant'
);
select is(
  has_table_privilege('authenticated', 'public.profiles', 'SELECT'),
  false,
  'authenticated role has no broad profile SELECT'
);
select ok(
  has_column_privilege(
    'authenticated',
    'public.profiles',
    'display_name',
    'SELECT'
  )
  and has_column_privilege(
    'authenticated',
    'public.profiles',
    'lock_version',
    'SELECT'
  )
  and not has_column_privilege(
    'authenticated',
    'public.profiles',
    'auth_user_id',
    'SELECT'
  )
  and not has_column_privilege(
    'authenticated',
    'public.profiles',
    'is_demo',
    'SELECT'
  ),
  'profile reads expose only approved owner-facing columns'
);
select is(
  has_table_privilege(
    'authenticated',
    'public.contact_verifications',
    'SELECT'
  ),
  false,
  'authenticated role has no broad contact SELECT'
);
select ok(
  has_column_privilege(
    'authenticated',
    'public.contact_verifications',
    'state',
    'SELECT'
  )
  and has_column_privilege(
    'authenticated',
    'public.contact_verifications',
    'channel',
    'SELECT'
  )
  and not has_column_privilege(
    'authenticated',
    'public.contact_verifications',
    'destination_hash',
    'SELECT'
  )
  and not has_column_privilege(
    'authenticated',
    'public.contact_verifications',
    'profile_id',
    'SELECT'
  ),
  'contact reads expose status fields without hashes or profile identity'
);
select is(
  has_table_privilege(
    'authenticated',
    'public.admin_permissions',
    'SELECT'
  ),
  false,
  'authenticated role has no permission-catalog SELECT'
);
select is(
  has_table_privilege(
    'authenticated',
    'public.admin_permission_assignments',
    'SELECT'
  ),
  false,
  'authenticated role has no base assignment select grant'
);
select is(
  has_function_privilege(
    'authenticated',
    'public.update_current_profile(text,text,text,bigint)',
    'EXECUTE'
  ),
  true,
  'authenticated role can execute only the profile update command'
);
select is(
  has_function_privilege(
    'authenticated',
    'public.current_effective_admin_permissions()',
    'EXECUTE'
  ),
  true,
  'authenticated role can execute the safe effective-grant query'
);
select isnt(
  has_function_privilege(
    'authenticated',
    'provisioning.bootstrap_admin(uuid,public.admin_permission_scope_request[],text,text)',
    'EXECUTE'
  ),
  true,
  'authenticated role has no provisioning execute grant'
);
select ok(
  not exists (
    select 1
    from unnest(array['anon', 'authenticated', 'service_role']) role_name
    where has_schema_privilege(role_name, 'provisioning', 'USAGE')
      or has_function_privilege(
        role_name,
        'provisioning.bootstrap_admin(uuid,public.admin_permission_scope_request[],text,text)',
        'EXECUTE'
      )
      or has_function_privilege(
        role_name,
        'provisioning.configure_environment(public.deployment_environment,boolean,boolean,text)',
        'EXECUTE'
      )
  ),
  'no runtime role can use or execute provisioning'
);
select ok(
  not exists (
    select 1
    from unnest(array['public', 'anon', 'authenticated', 'service_role'])
      role_name
    where has_schema_privilege(role_name, 'public', 'CREATE')
  ),
  'PUBLIC and runtime roles cannot create objects in the public schema'
);
select ok(
  not exists (
    select 1
    from unnest(array[
      'profiles',
      'contact_verifications',
      'admin_permissions',
      'admin_permission_assignments',
      'audit_events',
      'idempotency_records',
      'outbox_events',
      'outbox_event_deliveries',
      'app_environment'
    ]) table_name
    where has_table_privilege(
      'service_role',
      format('public.%I', table_name),
      'INSERT,UPDATE,DELETE'
    )
  ),
  'service_role has no direct Phase 1 base-table mutation privilege'
);
set local role service_role;
select throws_ok(
  $$update public.app_environment set demo_allowed = false$$,
  '42501',
  null,
  'service_role cannot mutate app_environment'
);
select throws_ok(
  $$insert into public.admin_permission_assignments default values$$,
  '42501',
  null,
  'service_role cannot insert provisioning-source assignments'
);
reset role;
select is(
  (
    select count(*)
    from information_schema.tables
    where table_schema = 'public'
      and table_type = 'BASE TABLE'
      and table_name not in (
        'profiles', 'contact_verifications', 'admin_permissions',
        'admin_permission_assignments', 'audit_events',
        'idempotency_records', 'outbox_events',
        'outbox_event_deliveries', 'app_environment'
      )
  ),
  0::bigint,
  'no later-phase public tables exist'
);

select * from finish();
rollback;
