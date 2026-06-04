-- BE-005: tabela event_managers + policies de escrita em events
--
-- Quem pode criar/editar/excluir eventos no MVP é controlado por uma
-- tabela enxuta event_managers(user_id). Promoção é manual via SQL
-- pelo administrador — não há cadastro de manager pela API.
-- Ver ADR em docs/decisoes/0001-fonte-de-eventos.md.

create table public.event_managers (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.event_managers enable row level security;

-- Authenticated pode ler a lista de managers — necessário para que as
-- subqueries das policies de events vejam linhas no contexto do role
-- corrente. A lista contém apenas UUIDs e não há policy de escrita,
-- então a tabela só é populada via postgres/admin.
create policy event_managers_select_authenticated on public.event_managers
  for select to authenticated using (true);

-- Policies de escrita em events: apenas managers.
-- (events_select_authenticated foi criada em 20260520104712_rls_policies.)
create policy events_insert_managers on public.events
  for insert to authenticated
  with check (
    (select auth.uid()) in (select user_id from public.event_managers)
  );

create policy events_update_managers on public.events
  for update to authenticated
  using (
    (select auth.uid()) in (select user_id from public.event_managers)
  )
  with check (
    (select auth.uid()) in (select user_id from public.event_managers)
  );

create policy events_delete_managers on public.events
  for delete to authenticated
  using (
    (select auth.uid()) in (select user_id from public.event_managers)
  );
