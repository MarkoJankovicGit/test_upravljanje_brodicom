-- Boat Training Rovinj — početna šema
-- Korisnici (profili), napredak po korisniku, povijest prijava.
-- Pristup: sve tablice imaju RLS. Klijent (preglednik) smije samo čitati vlastite podatke;
-- pisanje korisnika i uloga radi isključivo Edge funkcija sa service_role ključem.

-- ============================== tablice ==============================

create table public.profiles (
  id            uuid primary key references auth.users(id) on delete cascade,
  email         text not null,
  full_name     text not null default '',
  role          text not null default 'user' check (role in ('user', 'admin')),
  active        boolean not null default true,
  created_at    timestamptz not null default now(),
  created_by    uuid references auth.users(id) on delete set null,
  last_login_at timestamptz,
  login_count   integer not null default 0
);
create unique index profiles_email_lower_idx on public.profiles (lower(email));

create table public.login_events (
  id      bigint generated always as identity primary key,
  user_id uuid references auth.users(id) on delete set null,
  email   text not null,
  ok      boolean not null,
  reason  text,
  occurred_at timestamptz not null default now()
);
create index login_events_at_idx on public.login_events (occurred_at desc);
create index login_events_ok_at_idx on public.login_events (ok, occurred_at desc);

create table public.user_progress (
  user_id     uuid not null references auth.users(id) on delete cascade,
  question_id text not null,
  box         smallint not null default 0 check (box between 0 and 5),
  seen        integer not null default 0,
  correct     integer not null default 0,
  wrong       integer not null default 0,
  updated_at  timestamptz not null default now(),
  primary key (user_id, question_id)
);

create table public.user_state (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  prefs      jsonb not null default '{}'::jsonb,
  days       jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now()
);

-- ============================== pomoćne funkcije ==============================

create or replace function public.set_updated_at() returns trigger
language plpgsql set search_path = '' as $$
begin new.updated_at = now(); return new; end $$;

create trigger user_progress_updated before update on public.user_progress
  for each row execute function public.set_updated_at();
create trigger user_state_updated before update on public.user_state
  for each row execute function public.set_updated_at();

-- uloga i aktivnost trenutnog korisnika (security definer: izbjegava rekurziju RLS-a)
create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.profiles p
                 where p.id = auth.uid() and p.role = 'admin' and p.active);
$$;

create or replace function public.is_active_user() returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.profiles p where p.id = auth.uid() and p.active);
$$;

-- novi auth korisnik -> profil. Uloga dolazi iz app_metadata (to može postaviti samo server).
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, email, full_name, role, created_by)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    case when new.raw_app_meta_data ->> 'role' = 'admin' then 'admin' else 'user' end,
    nullif(new.raw_app_meta_data ->> 'created_by', '')::uuid
  );
  insert into public.user_state (user_id) values (new.id) on conflict do nothing;
  return new;
end $$;

create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================== povijest prijava ==============================

-- uspješna prijava: poziva prijavljeni korisnik odmah nakon prijave
create or replace function public.record_login() returns void
language plpgsql security definer set search_path = '' as $$
declare uid uuid := auth.uid(); em text;
begin
  if uid is null then return; end if;
  select email into em from public.profiles where id = uid and active;
  if em is null then return; end if;
  insert into public.login_events (user_id, email, ok) values (uid, em, true);
  update public.profiles set last_login_at = now(), login_count = login_count + 1 where id = uid;
end $$;

-- neuspješna prijava: poziva se i bez prijave (anon), zato je ograničena i razlog nije slobodan tekst
create or replace function public.record_failed_login(p_email text, p_reason text default null) returns void
language plpgsql security definer set search_path = '' as $$
declare e text := left(lower(trim(coalesce(p_email, ''))), 254);
begin
  if e = '' then return; end if;
  if (select count(*) from public.login_events
      where ok = false and occurred_at > now() - interval '1 minute') >= 30 then return; end if;
  insert into public.login_events (user_id, email, ok, reason)
  values ((select id from public.profiles where lower(email) = e),
          e,
          false,
          case when p_reason = 'banned' then 'Račun deaktiviran' else 'Pogrešan e-mail ili lozinka' end);
end $$;

-- ============================== RLS ==============================

alter table public.profiles       enable row level security;
alter table public.login_events   enable row level security;
alter table public.user_progress  enable row level security;
alter table public.user_state     enable row level security;

-- profili: korisnik vidi svoj, admin sve; pisanje samo kroz Edge funkciju (service_role)
create policy profiles_select on public.profiles for select to authenticated
  using (id = (select auth.uid()) or (select public.is_admin()));

-- povijest prijava: samo admin čita; upis samo kroz funkcije iznad
create policy login_events_select on public.login_events for select to authenticated
  using ((select public.is_admin()));

-- napredak i postavke: samo vlasnik (admin NE vidi tuđi napredak)
create policy user_progress_own on public.user_progress for all to authenticated
  using (user_id = (select auth.uid()) and (select public.is_active_user()))
  with check (user_id = (select auth.uid()) and (select public.is_active_user()));

create policy user_state_own on public.user_state for all to authenticated
  using (user_id = (select auth.uid()) and (select public.is_active_user()))
  with check (user_id = (select auth.uid()) and (select public.is_active_user()));

-- ============================== ovlasti ==============================

revoke all on public.profiles, public.login_events, public.user_progress, public.user_state from anon;
revoke all on function public.is_admin(), public.is_active_user(), public.record_login(),
              public.record_failed_login(text, text) from public, anon, authenticated;
grant execute on function public.is_admin(), public.is_active_user(), public.record_login() to authenticated;
grant execute on function public.record_failed_login(text, text) to anon, authenticated;

-- okidačke funkcije se ne smiju pozivati preko API-ja (podrazumijevano je EXECUTE otvoren za PUBLIC)
revoke all on function public.handle_new_user() from public, anon, authenticated;
revoke all on function public.set_updated_at() from public, anon, authenticated;
