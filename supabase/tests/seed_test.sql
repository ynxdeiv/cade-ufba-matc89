-- BE-005: testes pgTAP para o seed manual de events
--
-- Garante que `supabase db reset` produz um banco com >= 30 eventos
-- cobrindo as 5 categorias e múltiplas unidades exigidas pela issue.
-- Rodamos sem truncate — depende apenas do estado deixado por
-- `supabase db reset` (que aplica supabase/seed.sql).

begin;

create extension if not exists pgtap with schema extensions;
set search_path = public, extensions;

select plan(7);

-- ------------------------------------------------------------------
-- Volume e cobertura categórica do seed
-- ------------------------------------------------------------------

select cmp_ok(
  (select count(*)::int from public.events),
  '>=',
  30,
  'seed precisa ter >= 30 eventos em events'
);

select ok(
  exists(select 1 from public.events where categoria = 'palestra'),
  'seed precisa conter pelo menos um evento da categoria palestra'
);

select ok(
  exists(select 1 from public.events where categoria = 'minicurso'),
  'seed precisa conter pelo menos um evento da categoria minicurso'
);

select ok(
  exists(select 1 from public.events where categoria = 'congresso'),
  'seed precisa conter pelo menos um evento da categoria congresso'
);

select ok(
  exists(select 1 from public.events where categoria = 'defesa'),
  'seed precisa conter pelo menos um evento da categoria defesa'
);

select ok(
  exists(select 1 from public.events where categoria = 'cultural'),
  'seed precisa conter pelo menos um evento da categoria cultural'
);

select cmp_ok(
  (select count(distinct unidade)::int from public.events),
  '>=',
  4,
  'seed precisa cobrir pelo menos 4 unidades distintas da UFBA'
);

select * from finish();
rollback;
