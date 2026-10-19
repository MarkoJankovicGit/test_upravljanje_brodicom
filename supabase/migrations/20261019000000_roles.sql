-- Uloge: korisnik može biti samo učenik, samo administrator ili oboje.
--   učenik              role='user',  can_learn=true
--   administrator       role='admin', can_learn=false
--   administrator+učenik role='admin', can_learn=true

alter table public.profiles add column can_learn boolean not null default true;

-- dosadašnji administratori nisu učili: zadržavamo isto ponašanje (učenje im se može dodati iz admin panela)
update public.profiles set can_learn = false where role = 'admin';

-- učenik uvijek uči
alter table public.profiles add constraint profiles_user_can_learn check (role <> 'user' or can_learn);

-- novi korisnik: uloga i can_learn dolaze iz app_metadata (to može postaviti samo server)
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = '' as $$
declare r text := case when new.raw_app_meta_data ->> 'role' = 'admin' then 'admin' else 'user' end;
begin
  insert into public.profiles (id, email, full_name, role, can_learn, created_by)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    r,
    case when r = 'user' then true else coalesce((new.raw_app_meta_data ->> 'can_learn')::boolean, false) end,
    nullif(new.raw_app_meta_data ->> 'created_by', '')::uuid
  );
  insert into public.user_state (user_id) values (new.id) on conflict do nothing;
  return new;
end $$;
