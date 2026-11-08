-- Word Quest class leaderboard: run once in Supabase → SQL Editor.
--
-- Security model: the page's public key can't touch the table directly.
-- It can only call the three functions below, which:
--   * accept just a short name, one of the game's avatars, and a number
--   * cap the table at 60 rows, so it can't be used as free storage
--   * only let a device change or remove its own row (by its secret token)

create table if not exists public.leaderboard (
  token      text primary key check (token ~ '^[0-9a-f]{32}$'),
  name       text not null check (name ~ '^[א-תA-Za-z0-9 .''״׳-]{1,14}$'),
  av         text not null check (av in ('🦊', '🐼', '🐯', '🦄', '🐸', '🐙', '🦁', '🐨', '🐰', '🐧', '🐵', '🦉', '🐶', '🐱', '🐢', '🐬')),
  score      int  not null check (score between 0 and 1000000),
  updated_at timestamptz not null default now()
);

-- No direct access: RLS on with no policies, and no table privileges.
alter table public.leaderboard enable row level security;
revoke all on table public.leaderboard from anon, authenticated, public;

-- Add or update this device's player. Score never goes down.
create or replace function public.lb_submit(p_token text, p_name text, p_av text, p_score int)
returns void language plpgsql security definer set search_path = public as $$
begin
  if not exists (select 1 from leaderboard where token = p_token)
     and (select count(*) from leaderboard) >= 60 then
    raise exception 'leaderboard is full';
  end if;
  insert into leaderboard (token, name, av, score)
  values (p_token, btrim(p_name), p_av, p_score)
  on conflict (token) do update
    set name = excluded.name, av = excluded.av,
        score = greatest(leaderboard.score, excluded.score), updated_at = now();
end $$;

-- Read the board. Tokens are never returned.
create or replace function public.lb_top()
returns table (name text, av text, score int)
language sql stable security definer set search_path = public as $$
  select name, av, score from leaderboard order by score desc, updated_at limit 60
$$;

-- Remove this device's player.
create or replace function public.lb_leave(p_token text)
returns void language sql security definer set search_path = public as $$
  delete from leaderboard where token = p_token
$$;

revoke all on function public.lb_submit(text, text, text, int) from public, anon, authenticated;
revoke all on function public.lb_top() from public, anon, authenticated;
revoke all on function public.lb_leave(text) from public, anon, authenticated;
grant execute on function public.lb_submit(text, text, text, int) to anon;
grant execute on function public.lb_top() to anon;
grant execute on function public.lb_leave(text) to anon;
