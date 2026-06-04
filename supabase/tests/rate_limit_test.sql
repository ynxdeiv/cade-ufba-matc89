-- BE-007: testes pgTAP para verificar_rate_limit + chat_rate_limit

begin;

create extension if not exists pgtap with schema extensions;
set search_path = public, extensions, auth;

select plan(13);

-- ------------------------------------------------------------------
-- Estrutura: tabela e função
-- ------------------------------------------------------------------

select has_table('public', 'chat_rate_limit',
  'tabela chat_rate_limit precisa existir');

select col_is_pk('public', 'chat_rate_limit', array['user_id', 'minuto'],
  '(user_id, minuto) precisa ser PK composta');

select has_column('public', 'chat_rate_limit', 'contagem',
  'chat_rate_limit precisa ter coluna contagem');

select is(
  (select relrowsecurity from pg_class where oid = 'public.chat_rate_limit'::regclass),
  true,
  'RLS habilitado em chat_rate_limit'
);

select has_function('public', 'verificar_rate_limit',
  array['uuid', 'integer'],
  'verificar_rate_limit(uuid, integer) precisa existir');

select function_returns('public', 'verificar_rate_limit',
  array['uuid', 'integer'],
  'boolean',
  'verificar_rate_limit precisa retornar boolean');

-- ------------------------------------------------------------------
-- Fixtures: users reais (trigger BE-002 cria profiles)
-- ------------------------------------------------------------------

insert into auth.users (id, email, raw_user_meta_data, aud, role)
values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'a@test', '{"nome":"A"}'::jsonb,
   'authenticated', 'authenticated'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'b@test', '{"nome":"B"}'::jsonb,
   'authenticated', 'authenticated'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'c@test', '{"nome":"C"}'::jsonb,
   'authenticated', 'authenticated');

-- ------------------------------------------------------------------
-- Comportamento: incrementa e compara com o limite
-- ------------------------------------------------------------------

truncate table public.chat_rate_limit;

select is(
  public.verificar_rate_limit('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 3),
  true,
  '1ª chamada com limite=3 retorna true'
);

select is(
  public.verificar_rate_limit('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 3),
  true,
  '2ª chamada com limite=3 retorna true'
);

select is(
  public.verificar_rate_limit('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 3),
  true,
  '3ª chamada com limite=3 retorna true (no limite)'
);

select is(
  public.verificar_rate_limit('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid, 3),
  false,
  '4ª chamada com limite=3 retorna false (excedeu)'
);

-- ------------------------------------------------------------------
-- Isolamento entre usuários (user B não é afetado por user A)
-- ------------------------------------------------------------------

select is(
  public.verificar_rate_limit('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'::uuid, 3),
  true,
  'user B começa do zero, retorna true mesmo após user A ter excedido'
);

-- ------------------------------------------------------------------
-- Minuto diferente reseta a contagem
-- ------------------------------------------------------------------

-- Inserimos manualmente uma linha em um minuto passado para o user A
-- com contagem alta — ela não deve influenciar a verificação atual.
insert into public.chat_rate_limit (user_id, minuto, contagem)
values ('cccccccc-cccc-cccc-cccc-cccccccccccc'::uuid,
        date_trunc('minute', now() - interval '5 minutes'),
        99)
on conflict (user_id, minuto) do update set contagem = excluded.contagem;

select is(
  public.verificar_rate_limit('cccccccc-cccc-cccc-cccc-cccccccccccc'::uuid, 3),
  true,
  'contagem de minutos anteriores não afeta o minuto corrente'
);

-- ------------------------------------------------------------------
-- Auth: anon não tem privilégio em verificar_rate_limit
-- (a função roda no contexto da Edge Function — service_role)
-- ------------------------------------------------------------------

select function_privs_are('public', 'verificar_rate_limit',
  array['uuid', 'integer'],
  'anon', array[]::text[],
  'anon não deve ter EXECUTE em verificar_rate_limit');

select * from finish();
rollback;
