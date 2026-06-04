-- BE-004: RPCs de agenda do usuário autenticado
--
-- Todas as funções são SECURITY INVOKER, usam auth.uid() e têm
-- search_path = '' com nomes totalmente qualificados (boa prática
-- Supabase: evita advisor function_search_path_mutable).
--
-- Grants: apenas a role authenticated; revogamos PUBLIC para impedir
-- que anon (que herda de PUBLIC) execute essas funções.

-- ------------------------------------------------------------------
-- listar_agenda: eventos do usuário no intervalo, ordenado por inicio
-- ------------------------------------------------------------------

create or replace function public.listar_agenda(
  p_inicio timestamptz,
  p_fim timestamptz
)
returns table (
  event_id uuid,
  titulo text,
  descricao text,
  inicio timestamptz,
  fim timestamptz,
  local text,
  responsavel text,
  carga_horaria interval,
  tem_certificado boolean,
  categoria text,
  unidade text,
  capacidade integer,
  link_externo text,
  status text,
  marcado_em timestamptz
)
language sql
stable
security invoker
set search_path = ''
as $$
  select
    e.id          as event_id,
    e.titulo,
    e.descricao,
    e.inicio,
    e.fim,
    e.local,
    e.responsavel,
    e.carga_horaria,
    e.tem_certificado,
    e.categoria,
    e.unidade,
    e.capacidade,
    e.link_externo,
    ue.status,
    ue.marcado_em
  from public.user_events ue
  join public.events e on e.id = ue.event_id
  where ue.user_id = auth.uid()
    and e.inicio >= p_inicio
    and e.inicio <= p_fim
  order by e.inicio asc, e.id asc
$$;

-- Supabase aplica DEFAULT PRIVILEGES concedendo execute a anon em
-- novas funções do schema public — precisamos revogar explicitamente.
revoke execute on function public.listar_agenda(timestamptz, timestamptz) from public, anon;
grant execute on function public.listar_agenda(timestamptz, timestamptz) to authenticated;

-- ------------------------------------------------------------------
-- adicionar_a_agenda: insert idempotente, valida existência do evento
-- ------------------------------------------------------------------

create or replace function public.adicionar_a_agenda(p_event_id uuid)
returns public.user_events
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_row public.user_events;
begin
  if not exists (select 1 from public.events where id = p_event_id) then
    raise exception 'evento % não encontrado', p_event_id
      using errcode = 'P0002';
  end if;

  insert into public.user_events (user_id, event_id)
  values (auth.uid(), p_event_id)
  on conflict (user_id, event_id) do nothing;

  select * into v_row
  from public.user_events
  where user_id = auth.uid()
    and event_id = p_event_id;

  return v_row;
end
$$;

revoke execute on function public.adicionar_a_agenda(uuid) from public, anon;
grant execute on function public.adicionar_a_agenda(uuid) to authenticated;

-- ------------------------------------------------------------------
-- remover_da_agenda: delete idempotente
-- ------------------------------------------------------------------

create or replace function public.remover_da_agenda(p_event_id uuid)
returns void
language sql
security invoker
set search_path = ''
as $$
  delete from public.user_events
  where user_id = auth.uid()
    and event_id = p_event_id;
$$;

revoke execute on function public.remover_da_agenda(uuid) from public, anon;
grant execute on function public.remover_da_agenda(uuid) to authenticated;

-- ------------------------------------------------------------------
-- dias_com_eventos_do_usuario: agregação por dia para o calendário
-- ------------------------------------------------------------------

create or replace function public.dias_com_eventos_do_usuario(
  p_inicio date,
  p_fim date
)
returns table (
  dia date,
  count integer
)
language sql
stable
security invoker
set search_path = ''
as $$
  select
    (e.inicio at time zone 'UTC')::date as dia,
    count(*)::integer                   as count
  from public.user_events ue
  join public.events e on e.id = ue.event_id
  where ue.user_id = auth.uid()
    and (e.inicio at time zone 'UTC')::date between p_inicio and p_fim
  group by 1
  order by 1
$$;

revoke execute on function public.dias_com_eventos_do_usuario(date, date) from public, anon;
grant execute on function public.dias_com_eventos_do_usuario(date, date) to authenticated;
