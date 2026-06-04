-- BE-003: testes pgTAP para public.listar_eventos
-- Cobre: assinatura, índices, grants, filtros, busca pg_trgm,
-- paginação, ordenação e uso de índice em EXPLAIN.

begin;

create extension if not exists pgtap with schema extensions;
set search_path = public, extensions;

select plan(18);

-- ------------------------------------------------------------------
-- Estrutura: extensão, índice GIN/trigram, função, grants
-- ------------------------------------------------------------------

select has_extension('pg_trgm', 'extensão pg_trgm precisa estar habilitada');

select has_index(
  'public', 'events', 'events_busca_trgm_idx',
  'precisa existir índice GIN trigram em events para busca textual'
);

select has_function(
  'public',
  'listar_eventos',
  array[
    'timestamp with time zone',
    'timestamp with time zone',
    'text',
    'text',
    'text',
    'boolean',
    'integer',
    'integer'
  ],
  'função listar_eventos com assinatura esperada precisa existir'
);

select function_returns(
  'public',
  'listar_eventos',
  array[
    'timestamp with time zone',
    'timestamp with time zone',
    'text',
    'text',
    'text',
    'boolean',
    'integer',
    'integer'
  ],
  'setof events',
  'listar_eventos precisa retornar SETOF events'
);

select function_privs_are(
  'public',
  'listar_eventos',
  array[
    'timestamp with time zone',
    'timestamp with time zone',
    'text',
    'text',
    'text',
    'boolean',
    'integer',
    'integer'
  ],
  'authenticated',
  array['EXECUTE'],
  'role authenticated precisa ter EXECUTE em listar_eventos'
);

select function_privs_are(
  'public',
  'listar_eventos',
  array[
    'timestamp with time zone',
    'timestamp with time zone',
    'text',
    'text',
    'text',
    'boolean',
    'integer',
    'integer'
  ],
  'anon',
  array['EXECUTE'],
  'role anon precisa ter EXECUTE em listar_eventos'
);

-- ------------------------------------------------------------------
-- Fixture: 6 eventos com IDs determinísticos e dados contrastantes
-- ------------------------------------------------------------------

truncate table public.user_events cascade;
truncate table public.events cascade;

insert into public.events (id, titulo, descricao, inicio, fim, categoria, unidade, tem_certificado)
values
  ('11111111-1111-1111-1111-111111111111',
   'Palestra de Inteligência Artificial',
   'Introdução a redes neurais profundas e aplicações.',
   '2026-07-10 14:00+00', '2026-07-10 16:00+00',
   'palestra', 'IME', true),

  ('22222222-2222-2222-2222-222222222222',
   'Minicurso de Banco de Dados',
   'Postgres avançado com índices e planos de execução.',
   '2026-07-12 09:00+00', '2026-07-12 12:00+00',
   'minicurso', 'IC', false),

  ('33333333-3333-3333-3333-333333333333',
   'Congresso de Computação',
   'Encontro anual com palestras e sessões técnicas.',
   '2026-07-15 08:00+00', '2026-07-17 18:00+00',
   'congresso', 'IC', true),

  ('44444444-4444-4444-4444-444444444444',
   'Defesa de Tese — Engenharia',
   'Defesa pública envolvendo aprendizado de máquina aplicado.',
   '2026-07-15 08:00+00', '2026-07-15 11:00+00',
   'defesa', 'Escola Politécnica', false),

  ('55555555-5555-5555-5555-555555555555',
   'Evento Cultural na FACED',
   'Atividade artística aberta à comunidade.',
   '2026-08-01 19:00+00', '2026-08-01 22:00+00',
   'cultural', 'FACED', false),

  ('66666666-6666-6666-6666-666666666666',
   'Workshop Antigo',
   'Atividade no passado — fora da janela padrão dos testes.',
   '2026-01-05 14:00+00', '2026-01-05 17:00+00',
   'palestra', 'IME', true);

-- ------------------------------------------------------------------
-- Filtro: intervalo de datas
-- ------------------------------------------------------------------

select results_eq(
  $$ select id from public.listar_eventos(
       '2026-07-01 00:00+00'::timestamptz,
       '2026-07-31 23:59+00'::timestamptz
     ) order by inicio, id $$,
  $$ values
       ('11111111-1111-1111-1111-111111111111'::uuid),
       ('22222222-2222-2222-2222-222222222222'::uuid),
       ('33333333-3333-3333-3333-333333333333'::uuid),
       ('44444444-4444-4444-4444-444444444444'::uuid) $$,
  'intervalo de datas deve retornar apenas eventos dentro da janela'
);

-- ------------------------------------------------------------------
-- Filtros opcionais isolados
-- ------------------------------------------------------------------

select results_eq(
  $$ select id from public.listar_eventos(
       '2026-07-01 00:00+00'::timestamptz,
       '2026-07-31 23:59+00'::timestamptz,
       p_categoria => 'congresso'
     ) order by inicio, id $$,
  $$ values ('33333333-3333-3333-3333-333333333333'::uuid) $$,
  'filtro por categoria isolado deve restringir resultado'
);

select results_eq(
  $$ select id from public.listar_eventos(
       '2026-07-01 00:00+00'::timestamptz,
       '2026-08-31 23:59+00'::timestamptz,
       p_unidade => 'IC'
     ) order by inicio, id $$,
  $$ values
       ('22222222-2222-2222-2222-222222222222'::uuid),
       ('33333333-3333-3333-3333-333333333333'::uuid) $$,
  'filtro por unidade isolado deve restringir resultado'
);

select results_eq(
  $$ select id from public.listar_eventos(
       '2026-07-01 00:00+00'::timestamptz,
       '2026-08-31 23:59+00'::timestamptz,
       p_tem_certificado => true
     ) order by inicio, id $$,
  $$ values
       ('11111111-1111-1111-1111-111111111111'::uuid),
       ('33333333-3333-3333-3333-333333333333'::uuid) $$,
  'filtro por tem_certificado=true isolado deve restringir resultado'
);

-- ------------------------------------------------------------------
-- Filtros combinados
-- ------------------------------------------------------------------

select results_eq(
  $$ select id from public.listar_eventos(
       '2026-07-01 00:00+00'::timestamptz,
       '2026-08-31 23:59+00'::timestamptz,
       p_unidade => 'IC',
       p_tem_certificado => true
     ) order by inicio, id $$,
  $$ values ('33333333-3333-3333-3333-333333333333'::uuid) $$,
  'filtros combinados (unidade + certificado) devem se intersectar'
);

-- ------------------------------------------------------------------
-- Busca textual via pg_trgm (título e descrição)
-- ------------------------------------------------------------------

set local pg_trgm.similarity_threshold = 0.15;

select results_eq(
  $$ select id from public.listar_eventos(
       '2026-07-01 00:00+00'::timestamptz,
       '2026-08-31 23:59+00'::timestamptz,
       p_busca => 'Inteligência Artificial'
     ) $$,
  $$ values ('11111111-1111-1111-1111-111111111111'::uuid) $$,
  'busca textual deve casar por similaridade no título'
);

select results_eq(
  $$ select id from public.listar_eventos(
       '2026-07-01 00:00+00'::timestamptz,
       '2026-08-31 23:59+00'::timestamptz,
       p_busca => 'redes neurais profundas'
     ) $$,
  $$ values ('11111111-1111-1111-1111-111111111111'::uuid) $$,
  'busca textual deve casar por similaridade na descrição'
);

-- ------------------------------------------------------------------
-- Paginação
-- ------------------------------------------------------------------

select results_eq(
  $$ select id from public.listar_eventos(
       '2026-07-01 00:00+00'::timestamptz,
       '2026-08-31 23:59+00'::timestamptz,
       p_limit => 2,
       p_offset => 0
     ) $$,
  $$ values
       ('11111111-1111-1111-1111-111111111111'::uuid),
       ('22222222-2222-2222-2222-222222222222'::uuid) $$,
  'limit=2 / offset=0 deve retornar a primeira página ordenada'
);

select results_eq(
  $$ select id from public.listar_eventos(
       '2026-07-01 00:00+00'::timestamptz,
       '2026-08-31 23:59+00'::timestamptz,
       p_limit => 2,
       p_offset => 2
     ) $$,
  $$ values
       ('33333333-3333-3333-3333-333333333333'::uuid),
       ('44444444-4444-4444-4444-444444444444'::uuid) $$,
  'limit=2 / offset=2 deve retornar a segunda página ordenada'
);

-- ------------------------------------------------------------------
-- Ordenação estável: empate de inicio resolvido por id asc
-- (eventos 33 e 44 começam no mesmo instante)
-- ------------------------------------------------------------------

select results_eq(
  $$ select id from public.listar_eventos(
       '2026-07-15 00:00+00'::timestamptz,
       '2026-07-15 23:59+00'::timestamptz
     ) $$,
  $$ values
       ('33333333-3333-3333-3333-333333333333'::uuid),
       ('44444444-4444-4444-4444-444444444444'::uuid) $$,
  'em empate de inicio, deve ordenar por id asc (estável)'
);

-- ------------------------------------------------------------------
-- EXPLAIN: data + categoria precisa usar índice em events
-- (fixture pequeno → force seqscan off para validar o caminho indexado)
-- ------------------------------------------------------------------

set local enable_seqscan = off;
set local enable_bitmapscan = on;

create function pg_temp.plano(p_sql text) returns text language plpgsql as $f$
declare
  linha text;
  saida text := '';
begin
  for linha in execute 'explain (format text) ' || p_sql loop
    saida := saida || linha || E'\n';
  end loop;
  return saida;
end
$f$;

-- A função usa SET search_path = '' por segurança, portanto não é
-- inlineável e aparece como Function Scan no plano externo. Validamos
-- então a query equivalente — provando que o planner usa os índices de
-- events ao combinar filtros por data + categoria.
select ok(
  pg_temp.plano($$
    select e.*
    from public.events e
    where e.inicio >= '2026-07-01 00:00+00'::timestamptz
      and e.inicio <= '2026-07-31 23:59+00'::timestamptz
      and e.categoria = 'palestra'
  $$) ~* '(Index Scan|Bitmap Index Scan|Bitmap Heap Scan).*events',
  'EXPLAIN deve mostrar Index/Bitmap Scan sobre events ao filtrar por data + categoria'
);

-- Para validar o índice GIN trigram, inspecionamos o plano de uma busca
-- textual pura (sem filtro de data, que aqui seria mais seletivo e
-- venceria o índice GIN no fixture pequeno).
select ok(
  pg_temp.plano($$
    select * from public.events
    where (titulo || ' ' || coalesce(descricao, ''))
            operator(extensions.%) 'Inteligência'
  $$) like '%events_busca_trgm_idx%',
  'EXPLAIN da busca textual deve usar o índice GIN trigram events_busca_trgm_idx'
);

select * from finish();
rollback;
