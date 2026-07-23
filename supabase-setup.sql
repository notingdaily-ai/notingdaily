-- Supabase Dashboard > SQL Editor에서 한 번 실행하세요.
create table if not exists public.daylog_data (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.daylog_data enable row level security;

create policy "Users can read own daylog"
on public.daylog_data for select
to authenticated
using (auth.uid() = user_id);

create policy "Users can insert own daylog"
on public.daylog_data for insert
to authenticated
with check (auth.uid() = user_id);

create policy "Users can update own daylog"
on public.daylog_data for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Users can delete own daylog"
on public.daylog_data for delete
to authenticated
using (auth.uid() = user_id);

-- Realtime 동기화를 위해 테이블을 publication에 추가합니다.
do $$
begin
  alter publication supabase_realtime add table public.daylog_data;
exception
  when duplicate_object then null;
end $$;
