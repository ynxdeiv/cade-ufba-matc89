-- BE-007: RPC para o front carregar a conversa do chatbot
--
-- Retorna as últimas p_limit mensagens do usuário autenticado, em
-- ordem decrescente por created_at. Usa o índice DESC abaixo para
-- atender ao requisito de < 200ms para 50 mensagens.

create index if not exists chat_messages_user_created_desc_idx
  on public.chat_messages (user_id, created_at desc);

create or replace function public.listar_historico_chat(
  p_limit integer default 50
)
returns table (
  id                     bigint,
  role                   text,
  conteudo               text,
  eventos_referenciados  uuid[],
  created_at             timestamptz
)
language sql
stable
security invoker
set search_path = ''
as $$
  select
    m.id,
    m.role,
    m.conteudo,
    m.eventos_referenciados,
    m.created_at
  from public.chat_messages m
  where m.user_id = (select auth.uid())
  order by m.created_at desc
  limit p_limit
$$;

revoke execute on function public.listar_historico_chat(integer)
  from public, anon;
grant execute on function public.listar_historico_chat(integer)
  to authenticated;
