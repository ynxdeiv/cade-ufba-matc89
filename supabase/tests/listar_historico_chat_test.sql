-- BE-007: testes pgTAP para listar_historico_chat
-- (RPC consumido pelo front Flutter para carregar a conversa)

begin;

create extension if not exists pgtap with schema extensions;
set search_path = public, extensions, auth;

select plan(7);

-- ------------------------------------------------------------------
-- 1–3. Estrutura
-- ------------------------------------------------------------------

select has_function('public', 'listar_historico_chat',
  array['integer'],
  'listar_historico_chat(integer) precisa existir');

select function_privs_are('public', 'listar_historico_chat',
  array['integer'],
  'authenticated', array['EXECUTE'],
  'authenticated precisa ter EXECUTE em listar_historico_chat');

select function_privs_are('public', 'listar_historico_chat',
  array['integer'],
  'anon', array[]::text[],
  'anon não deve ter EXECUTE em listar_historico_chat');

-- ------------------------------------------------------------------
-- Índice (user_id, created_at DESC) — requisito de performance
-- (50 mensagens em < 200ms — assertiva estrutural, não temporal)
-- ------------------------------------------------------------------

select has_index('public', 'chat_messages', 'chat_messages_user_created_desc_idx',
  'precisa existir índice (user_id, created_at desc) para o histórico');

-- ------------------------------------------------------------------
-- Fixtures: 2 users com mensagens
-- ------------------------------------------------------------------

insert into auth.users (id, email, raw_user_meta_data, aud, role)
values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'a@test', '{"nome":"A"}'::jsonb,
   'authenticated', 'authenticated'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'b@test', '{"nome":"B"}'::jsonb,
   'authenticated', 'authenticated');

truncate table public.chat_messages;

-- 3 turnos do user A (6 mensagens) + 1 do user B
insert into public.chat_messages (user_id, role, conteudo, created_at)
values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'user',
   'pergunta 1', '2026-07-10 14:00+00'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'assistant',
   'resposta 1', '2026-07-10 14:00:05+00'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'user',
   'pergunta 2', '2026-07-10 14:01+00'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'assistant',
   'resposta 2', '2026-07-10 14:01:05+00'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'user',
   'pergunta 3', '2026-07-10 14:02+00'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'assistant',
   'resposta 3', '2026-07-10 14:02:05+00'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'user',
   'pergunta do user B', '2026-07-10 15:00+00');

create function pg_temp.as_user(p_uid uuid) returns void
language sql
as $$
  select set_config(
    'request.jwt.claims',
    json_build_object('sub', p_uid::text, 'role', 'authenticated')::text,
    true
  );
$$;

-- ------------------------------------------------------------------
-- listar_historico_chat retorna só do usuário autenticado, em ordem
-- decrescente por created_at, respeitando o limit.
-- ------------------------------------------------------------------

set local role authenticated;
select pg_temp.as_user('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid);

select is(
  (select count(*)::int from public.listar_historico_chat(50)),
  6,
  'user A vê suas 6 mensagens (3 user + 3 assistant)'
);

select results_eq(
  $$ select conteudo from public.listar_historico_chat(2) $$,
  $$ values ('resposta 3'::text), ('pergunta 3'::text) $$,
  'limit=2 retorna as 2 mensagens mais recentes em ordem DESC'
);

reset role;

set local role authenticated;
select pg_temp.as_user('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'::uuid);

select is(
  (select count(*)::int from public.listar_historico_chat(50)),
  1,
  'user B vê apenas sua própria mensagem'
);

reset role;

select * from finish();
rollback;
