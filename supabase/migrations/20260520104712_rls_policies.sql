-- BE-001: Row Level Security
-- Cada usuário só lê/edita seus próprios dados.
-- events: leitura pública para autenticados; escrita bloqueada nesta fase
-- (será aberta em BE-005 via tabela event_managers).

alter table public.profiles enable row level security;
alter table public.events enable row level security;
alter table public.user_events enable row level security;
alter table public.chat_messages enable row level security;

create policy profiles_select_self on public.profiles
  for select using (auth.uid() = id);

create policy profiles_update_self on public.profiles
  for update using (auth.uid() = id) with check (auth.uid() = id);

create policy events_select_authenticated on public.events
  for select to authenticated using (true);

create policy user_events_all_self on public.user_events
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy chat_messages_all_self on public.chat_messages
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
