-- BE-005: testes pgTAP para event_managers + RLS de events
--
-- Cobre:
--   - tabela event_managers (estrutura + RLS habilitado)
--   - policies de events: insert/update/delete restritos a managers
--   - usuário em event_managers consegue inserir / atualizar / deletar
--   - usuário comum (authenticated mas fora de event_managers) é
--     bloqueado em todas as escritas

begin;

create extension if not exists pgtap with schema extensions;
set search_path = public, extensions, auth;

select plan(15);

-- ------------------------------------------------------------------
-- 1–5. Estrutura: tabela event_managers + RLS + FK + policies
-- ------------------------------------------------------------------

select has_table('public', 'event_managers',
  'tabela event_managers precisa existir');

select col_is_pk('public', 'event_managers', 'user_id',
  'user_id precisa ser PK em event_managers');

select fk_ok('public', 'event_managers', 'user_id', 'public', 'profiles', 'id',
  'event_managers.user_id precisa ser FK para profiles.id');

select is(
  (select relrowsecurity from pg_class where oid = 'public.event_managers'::regclass),
  true,
  'RLS precisa estar habilitado em event_managers'
);

select policies_are(
  'public', 'events',
  array[
    'events_select_authenticated',
    'events_insert_managers',
    'events_update_managers',
    'events_delete_managers'
  ],
  'events precisa ter policies: select (auth), insert/update/delete (managers)'
);

-- ------------------------------------------------------------------
-- Fixtures: 2 usuários (A = manager, B = comum) + 1 evento
-- ------------------------------------------------------------------

insert into auth.users (id, email, raw_user_meta_data, aud, role)
values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'manager@test',
   '{"nome":"Manager A"}'::jsonb, 'authenticated', 'authenticated'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'comum@test',
   '{"nome":"User B"}'::jsonb, 'authenticated', 'authenticated');

insert into public.event_managers (user_id)
values ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');

-- helper: configurar a transação para atuar como user autenticado
create function pg_temp.as_user(p_uid uuid) returns void
language sql
as $$
  select set_config(
    'request.jwt.claims',
    json_build_object('sub', p_uid::text, 'role', 'authenticated')::text,
    true
  );
$$;

-- evento "alvo" criado como postgres (bypassa RLS) para os testes
-- de update/delete
insert into public.events (id, titulo, inicio)
values
  ('99999999-9999-9999-9999-999999999999', 'Evento alvo', '2026-07-10 14:00+00');

-- ------------------------------------------------------------------
-- 6. Manager consegue INSERT em events
-- ------------------------------------------------------------------

set local role authenticated;
select pg_temp.as_user('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid);

select lives_ok(
  $$ insert into public.events (titulo, inicio)
       values ('Inserido pelo manager', '2026-07-12 10:00+00') $$,
  'manager consegue INSERT em events'
);

-- ------------------------------------------------------------------
-- 7. Manager consegue UPDATE em events
-- ------------------------------------------------------------------

select lives_ok(
  $$ update public.events
       set local = 'Auditório atualizado pelo manager'
     where id = '99999999-9999-9999-9999-999999999999' $$,
  'manager consegue UPDATE em events'
);

select is(
  (select local from public.events where id = '99999999-9999-9999-9999-999999999999'),
  'Auditório atualizado pelo manager',
  'UPDATE do manager foi persistido'
);

-- ------------------------------------------------------------------
-- 8. Manager consegue DELETE em events
-- ------------------------------------------------------------------

select lives_ok(
  $$ delete from public.events
     where titulo = 'Inserido pelo manager' $$,
  'manager consegue DELETE em events'
);

reset role;

-- ------------------------------------------------------------------
-- 9–11. Usuário comum (não manager) é bloqueado em todas as escritas
-- ------------------------------------------------------------------

set local role authenticated;
select pg_temp.as_user('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'::uuid);

-- INSERT é bloqueado pela WITH CHECK da policy events_insert_managers,
-- que dispara 42501 (RLS denied).
select throws_ok(
  $$ insert into public.events (titulo, inicio)
       values ('Tentativa de user comum', '2026-07-12 11:00+00') $$,
  '42501',
  null,
  'usuário comum recebe RLS denied em INSERT'
);

-- UPDATE / DELETE bloqueados pela USING clause da policy: o Postgres
-- não lança exceção — apenas filtra a linha para 0 rows. Asseguramos
-- então que a row alvo permanece intacta após cada tentativa.

select lives_ok(
  $$ update public.events
       set local = 'tentativa de user comum'
     where id = '99999999-9999-9999-9999-999999999999' $$,
  'UPDATE do user comum não lança exceção (RLS USING filtra 0 rows)'
);

select is(
  (select local from public.events
   where id = '99999999-9999-9999-9999-999999999999'),
  'Auditório atualizado pelo manager',
  'UPDATE do user comum não modifica a row (RLS bloqueou)'
);

select lives_ok(
  $$ delete from public.events
     where id = '99999999-9999-9999-9999-999999999999' $$,
  'DELETE do user comum não lança exceção (RLS USING filtra 0 rows)'
);

reset role;

select is(
  (select count(*)::int from public.events
   where id = '99999999-9999-9999-9999-999999999999'),
  1,
  'DELETE do user comum não removeu a row (RLS bloqueou)'
);

-- ------------------------------------------------------------------
-- 12. event_managers tem RLS de select para authenticated
-- (necessário para a subquery das policies de events funcionar
-- — alternativa seria função security definer em schema privado)
-- ------------------------------------------------------------------

select policy_roles_are(
  'public', 'event_managers', 'event_managers_select_authenticated',
  array['authenticated'],
  'event_managers_select_authenticated precisa ser para authenticated'
);

select * from finish();
rollback;
