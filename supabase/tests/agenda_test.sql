-- BE-004: testes pgTAP para RPCs de agenda
--
-- Funções cobertas:
--   - public.listar_agenda(p_inicio, p_fim)
--   - public.adicionar_a_agenda(p_event_id)
--   - public.remover_da_agenda(p_event_id)
--   - public.dias_com_eventos_do_usuario(p_inicio, p_fim)
--
-- Cada função é SECURITY INVOKER e depende de auth.uid(). Os testes
-- alternam role/JWT entre dois usuários autenticados (A e B) e o
-- pseudo-role anon para validar o gating de auth.

begin;

create extension if not exists pgtap with schema extensions;
set search_path = public, extensions, auth;

select plan(22);

-- ------------------------------------------------------------------
-- Fixtures
-- ------------------------------------------------------------------

-- 2 usuários reais (trigger BE-002 cria o profile automaticamente)
insert into auth.users (id, email, raw_user_meta_data, aud, role)
values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'a@test', '{"nome":"User A"}'::jsonb, 'authenticated', 'authenticated'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'b@test', '{"nome":"User B"}'::jsonb, 'authenticated', 'authenticated');

truncate table public.user_events cascade;
truncate table public.events cascade;

insert into public.events (id, titulo, inicio)
values
  ('11111111-1111-1111-1111-111111111111', 'Evento 1', '2026-07-10 14:00+00'),
  ('22222222-2222-2222-2222-222222222222', 'Evento 2', '2026-07-15 09:00+00'),
  ('33333333-3333-3333-3333-333333333333', 'Evento 3', '2026-07-20 10:00+00'),
  ('44444444-4444-4444-4444-444444444444', 'Evento 4 (fora da janela)', '2026-09-01 10:00+00');

-- helper: faz o restante da transação atuar como o user autenticado <uuid>
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
-- 1–4. Estrutura: as 4 funções existem com a assinatura esperada
-- ------------------------------------------------------------------

select has_function('public', 'listar_agenda',
  array['timestamp with time zone', 'timestamp with time zone'],
  'listar_agenda(timestamptz, timestamptz) precisa existir');

select has_function('public', 'adicionar_a_agenda',
  array['uuid'],
  'adicionar_a_agenda(uuid) precisa existir');

select has_function('public', 'remover_da_agenda',
  array['uuid'],
  'remover_da_agenda(uuid) precisa existir');

select has_function('public', 'dias_com_eventos_do_usuario',
  array['date', 'date'],
  'dias_com_eventos_do_usuario(date, date) precisa existir');

-- ------------------------------------------------------------------
-- 5–8. Grants: EXECUTE para authenticated, sem grant para anon
-- ------------------------------------------------------------------

select function_privs_are('public', 'listar_agenda',
  array['timestamp with time zone', 'timestamp with time zone'],
  'authenticated', array['EXECUTE'],
  'authenticated precisa ter EXECUTE em listar_agenda');

select function_privs_are('public', 'adicionar_a_agenda',
  array['uuid'],
  'authenticated', array['EXECUTE'],
  'authenticated precisa ter EXECUTE em adicionar_a_agenda');

select function_privs_are('public', 'remover_da_agenda',
  array['uuid'],
  'authenticated', array['EXECUTE'],
  'authenticated precisa ter EXECUTE em remover_da_agenda');

select function_privs_are('public', 'dias_com_eventos_do_usuario',
  array['date', 'date'],
  'authenticated', array['EXECUTE'],
  'authenticated precisa ter EXECUTE em dias_com_eventos_do_usuario');

-- ------------------------------------------------------------------
-- 9. adicionar_a_agenda é idempotente
-- ------------------------------------------------------------------

set local role authenticated;
select pg_temp.as_user('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid);

select public.adicionar_a_agenda('11111111-1111-1111-1111-111111111111'::uuid);
select public.adicionar_a_agenda('11111111-1111-1111-1111-111111111111'::uuid);

reset role;

select is(
  (select count(*)::int from public.user_events
   where user_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
     and event_id = '11111111-1111-1111-1111-111111111111'),
  1,
  'adicionar_a_agenda chamada duas vezes não duplica linha'
);

-- ------------------------------------------------------------------
-- 10. adicionar_a_agenda rejeita event_id inexistente
-- ------------------------------------------------------------------

set local role authenticated;
select pg_temp.as_user('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid);

select throws_ok(
  $$ select public.adicionar_a_agenda('00000000-0000-0000-0000-000000000000'::uuid) $$,
  null,
  null,
  'adicionar_a_agenda com event_id inexistente deve falhar'
);

reset role;

-- ------------------------------------------------------------------
-- 11. remover_da_agenda do user A não afeta o user B
-- ------------------------------------------------------------------

-- Setup: A e B marcam o mesmo evento
set local role authenticated;
select pg_temp.as_user('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid);
select public.adicionar_a_agenda('22222222-2222-2222-2222-222222222222'::uuid);
reset role;

set local role authenticated;
select pg_temp.as_user('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'::uuid);
select public.adicionar_a_agenda('22222222-2222-2222-2222-222222222222'::uuid);
reset role;

-- Ação: A remove
set local role authenticated;
select pg_temp.as_user('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid);
select public.remover_da_agenda('22222222-2222-2222-2222-222222222222'::uuid);
reset role;

select is(
  (select count(*)::int from public.user_events
   where user_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
     and event_id = '22222222-2222-2222-2222-222222222222'),
  0,
  'remover_da_agenda apaga linha do próprio usuário'
);

select is(
  (select count(*)::int from public.user_events
   where user_id = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'
     and event_id = '22222222-2222-2222-2222-222222222222'),
  1,
  'remover_da_agenda do user A não afeta linha do user B'
);

-- ------------------------------------------------------------------
-- 13–14. listar_agenda retorna só do usuário autenticado e ordenado
-- ------------------------------------------------------------------

-- Preparar agenda do A com 3 eventos (ids 1,2,3) e do B com só o 3
truncate table public.user_events;

set local role authenticated;
select pg_temp.as_user('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid);
select public.adicionar_a_agenda('33333333-3333-3333-3333-333333333333'::uuid);
select public.adicionar_a_agenda('11111111-1111-1111-1111-111111111111'::uuid);
select public.adicionar_a_agenda('22222222-2222-2222-2222-222222222222'::uuid);
reset role;

set local role authenticated;
select pg_temp.as_user('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'::uuid);
select public.adicionar_a_agenda('33333333-3333-3333-3333-333333333333'::uuid);
reset role;

-- listar como A
set local role authenticated;
select pg_temp.as_user('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid);

select results_eq(
  $$ select event_id from public.listar_agenda(
       '2026-01-01 00:00+00'::timestamptz,
       '2026-12-31 23:59+00'::timestamptz
     ) $$,
  $$ values
       ('11111111-1111-1111-1111-111111111111'::uuid),
       ('22222222-2222-2222-2222-222222222222'::uuid),
       ('33333333-3333-3333-3333-333333333333'::uuid) $$,
  'listar_agenda do A retorna seus 3 eventos ordenados por inicio'
);

reset role;

-- listar como B
set local role authenticated;
select pg_temp.as_user('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'::uuid);

select results_eq(
  $$ select event_id from public.listar_agenda(
       '2026-01-01 00:00+00'::timestamptz,
       '2026-12-31 23:59+00'::timestamptz
     ) $$,
  $$ values ('33333333-3333-3333-3333-333333333333'::uuid) $$,
  'listar_agenda do B só retorna o evento dele'
);

reset role;

-- ------------------------------------------------------------------
-- 15. listar_agenda respeita o intervalo de datas
-- ------------------------------------------------------------------

set local role authenticated;
select pg_temp.as_user('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid);
select public.adicionar_a_agenda('44444444-4444-4444-4444-444444444444'::uuid);

select results_eq(
  $$ select event_id from public.listar_agenda(
       '2026-07-01 00:00+00'::timestamptz,
       '2026-07-31 23:59+00'::timestamptz
     ) $$,
  $$ values
       ('11111111-1111-1111-1111-111111111111'::uuid),
       ('22222222-2222-2222-2222-222222222222'::uuid),
       ('33333333-3333-3333-3333-333333333333'::uuid) $$,
  'listar_agenda filtra eventos fora da janela'
);

reset role;

-- ------------------------------------------------------------------
-- 16. dias_com_eventos_do_usuario agrega corretamente
-- ------------------------------------------------------------------

set local role authenticated;
select pg_temp.as_user('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid);

select results_eq(
  $$ select dia, count from public.dias_com_eventos_do_usuario(
       '2026-07-01'::date, '2026-07-31'::date
     ) order by dia $$,
  $$ values
       ('2026-07-10'::date, 1),
       ('2026-07-15'::date, 1),
       ('2026-07-20'::date, 1) $$,
  'dias_com_eventos_do_usuario retorna 3 dias distintos com count=1'
);

reset role;

-- ------------------------------------------------------------------
-- 17–20. anon não tem privilégio de execução em nenhuma das 4 funções
-- (chamada efetiva como anon resultaria em SQLSTATE 42501 — aqui
-- inspecionamos o catálogo, que é equivalente e mais robusto que
-- alternar role dentro do teste).
-- ------------------------------------------------------------------

select function_privs_are('public', 'listar_agenda',
  array['timestamp with time zone', 'timestamp with time zone'],
  'anon', array[]::text[],
  'anon não deve ter privilégios em listar_agenda');

select function_privs_are('public', 'adicionar_a_agenda',
  array['uuid'],
  'anon', array[]::text[],
  'anon não deve ter privilégios em adicionar_a_agenda');

select function_privs_are('public', 'remover_da_agenda',
  array['uuid'],
  'anon', array[]::text[],
  'anon não deve ter privilégios em remover_da_agenda');

select function_privs_are('public', 'dias_com_eventos_do_usuario',
  array['date', 'date'],
  'anon', array[]::text[],
  'anon não deve ter privilégios em dias_com_eventos_do_usuario');

-- ------------------------------------------------------------------
-- 21. remover_da_agenda é idempotente (não falha quando nada existe)
-- ------------------------------------------------------------------

set local role authenticated;
select pg_temp.as_user('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'::uuid);

select lives_ok(
  $$ select public.remover_da_agenda('11111111-1111-1111-1111-111111111111'::uuid) $$,
  'remover_da_agenda não falha quando a linha não existe'
);

reset role;

-- ------------------------------------------------------------------
-- 22. adicionar_a_agenda retorna a linha de user_events
-- ------------------------------------------------------------------

truncate table public.user_events;

set local role authenticated;
select pg_temp.as_user('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid);

select is(
  (select (public.adicionar_a_agenda('11111111-1111-1111-1111-111111111111'::uuid)).event_id),
  '11111111-1111-1111-1111-111111111111'::uuid,
  'adicionar_a_agenda retorna a linha (user_events) com event_id'
);

reset role;

select * from finish();
rollback;
