-- Threads/conversas do chat com a IA.
-- Cada usuário pode ter N conversas; cada conversa agrupa N mensagens.

create table public.chat_conversations (
  id uuid primary key default extensions.gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  titulo text not null default 'Nova conversa',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index chat_conversations_user_updated_desc_idx
  on public.chat_conversations (user_id, updated_at desc);

alter table public.chat_messages
  add column conversation_id uuid references public.chat_conversations (id) on delete cascade;

create index chat_messages_conversation_created_idx
  on public.chat_messages (conversation_id, created_at);

alter table public.chat_conversations enable row level security;

create policy chat_conversations_select_self
  on public.chat_conversations for select
  to authenticated
  using (auth.uid() = user_id);

create policy chat_conversations_insert_self
  on public.chat_conversations for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy chat_conversations_update_self
  on public.chat_conversations for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy chat_conversations_delete_self
  on public.chat_conversations for delete
  to authenticated
  using (auth.uid() = user_id);

create or replace function public.bump_conversation_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if new.conversation_id is not null then
    update public.chat_conversations
       set updated_at = now()
     where id = new.conversation_id;
  end if;
  return new;
end;
$$;

create trigger chat_messages_bump_conversation
  after insert on public.chat_messages
  for each row execute function public.bump_conversation_updated_at();

create or replace function public.listar_conversas()
returns table (
  id          uuid,
  titulo      text,
  created_at  timestamptz,
  updated_at  timestamptz
)
language sql
stable
security invoker
set search_path = ''
as $$
  select c.id, c.titulo, c.created_at, c.updated_at
    from public.chat_conversations c
   where c.user_id = (select auth.uid())
   order by c.updated_at desc
$$;

revoke execute on function public.listar_conversas() from public, anon;
grant  execute on function public.listar_conversas() to authenticated;

drop function if exists public.listar_historico_chat(integer);

create or replace function public.listar_historico_chat(
  p_conversation_id uuid,
  p_limit integer default 50
)
returns table (
  id                     bigint,
  conversation_id        uuid,
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
    m.conversation_id,
    m.role,
    m.conteudo,
    m.eventos_referenciados,
    m.created_at
  from public.chat_messages m
  where m.user_id = (select auth.uid())
    and m.conversation_id = p_conversation_id
  order by m.created_at asc
  limit p_limit
$$;

revoke execute on function public.listar_historico_chat(uuid, integer) from public, anon;
grant  execute on function public.listar_historico_chat(uuid, integer) to authenticated;
