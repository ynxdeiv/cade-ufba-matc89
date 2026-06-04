-- BE-007: rate limiting do chatbot Cadu
--
-- chat_rate_limit guarda a contagem de chamadas por usuário/minuto.
-- A função verificar_rate_limit é chamada pela Edge Function (com
-- service_role) antes de processar cada mensagem; retorna false
-- quando a contagem do minuto corrente excede p_limite.

create table public.chat_rate_limit (
  user_id  uuid        not null references public.profiles(id) on delete cascade,
  minuto   timestamptz not null,
  contagem integer     not null default 0,
  primary key (user_id, minuto)
);

alter table public.chat_rate_limit enable row level security;
-- Sem policies para authenticated/anon. A Edge Function lê e escreve
-- com service_role, que bypassa RLS. Nenhum cliente público precisa
-- enxergar essa tabela.

create or replace function public.verificar_rate_limit(
  p_user uuid,
  p_limite integer
)
returns boolean
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_contagem integer;
begin
  insert into public.chat_rate_limit (user_id, minuto, contagem)
  values (p_user, date_trunc('minute', now()), 1)
  on conflict (user_id, minuto)
    do update set contagem = public.chat_rate_limit.contagem + 1
  returning contagem into v_contagem;

  return v_contagem <= p_limite;
end
$$;

-- Edge Function chama com service_role; revogamos execute de
-- authenticated/anon para impedir uso indevido pelo cliente.
revoke execute on function public.verificar_rate_limit(uuid, integer)
  from public, anon, authenticated;
