# ADR 0001 — Fonte de dados de eventos no MVP

- **Status:** Aceita
- **Data:** 2026-06-04
- **Responsáveis:** Equipe Cadê UFBA
- **Tarefa relacionada:** BE-005 (ver `TAREFAS.MD`)
- **Requisitos cobertos:** RF-BE-06, RF-BE-07 (parcial).

## Contexto

O PDF de requisitos descreve a tabela `events` mas não diz **quem alimenta** essa base. Para chegar ao MVP precisamos de dados reais o suficiente para validar:

- listagem com filtros (BE-003);
- agenda do usuário (BE-004);
- calendário do front (FE-006);
- chatbot com tool-use sobre eventos (BE-006).

Sem uma fonte de dados confiável, o front fica bloqueado.

## Alternativas consideradas

1. **Painel administrativo web (admin CRUD).** Dá flexibilidade, mas custa ~1 sprint para tela + RLS de admin + UX. Atrasa o MVP.
2. **Scraping de portais da UFBA.** Não há um portal canônico. Cada unidade publica em formato próprio (HTML, PDF, Instagram). Requer infra (jobs agendados, parsers por fonte, deduplicação). Alto custo de manutenção.
3. **API institucional da UFBA.** Idealmente seria a fonte definitiva, mas a UFBA não expõe uma API pública de eventos. Negociar acesso é um esforço que não cabe em sprint do MVP.
4. **Seed manual via SQL + tabela `event_managers`.** Eventos são inseridos via SQL/`supabase db reset` no MVP; uma tabela `event_managers(user_id)` controla quem pode editar via Data API depois (com RLS). Sem UI nova.

## Decisão

Adotamos a alternativa **4** para o MVP:

- `supabase/seed.sql` contém ~30 eventos cobrindo as 5 categorias (palestra, minicurso, congresso, defesa, cultural) e múltiplas unidades da UFBA, em uma janela de `-7` a `+60` dias a partir de `current_date`.
- Tabela `public.event_managers(user_id uuid PK FK→profiles)` identifica quem pode escrever em `public.events`. Promoção é manual (`insert into event_managers (...)` via `postgres`/admin).
- RLS de `events`: `select` para `authenticated`; `insert`/`update`/`delete` apenas se `auth.uid()` estiver em `event_managers`.
- A tabela `event_managers` é lida por todos os autenticados (sem dados sensíveis — só UUIDs), o que permite que as policies de `events` resolvam a subquery sem precisar de função `security definer` em schema exposto.

## Consequências

**Positivas**
- Front e backend podem ser desenvolvidos em paralelo com dados realistas a partir de hoje.
- Sem dependência de portal externo (zero risco de mudança de layout / API).
- Pronto para evoluir: já existe `event_managers` para suportar um futuro painel admin sem migration adicional do modelo de autorização.

**Negativas / dívidas**
- Dados não refletem eventos reais da UFBA — é seed sintético para desenvolvimento.
- Manter o seed atualizado conforme datas avancem requer pequenas edições no SQL (mitigado por usar `current_date + interval`).
- Sem painel admin, criar eventos em produção exige acesso direto ao Postgres (via Supabase Studio ou SQL Editor).

## Próximos passos

1. **Pós-MVP:** painel admin simples (Supabase Studio ou tela própria) que escreve em `events` via Data API — RLS já está pronta.
2. **Quando houver demanda:** investigar fontes parciais (ex.: agenda do PROEX, calendário acadêmico) e considerar um job de ingestão (`pg_cron` + edge function).
3. **Quando houver API institucional:** trocar o seed por um conector dedicado mantendo a interface da tabela `events` inalterada.

## Onde isso vive no código

- Tabela: `supabase/migrations/20260604183847_event_managers.sql`
- Seed: `supabase/seed.sql`
- Policies: as 3 policies novas de `events` na mesma migration acima
- Testes: `supabase/tests/event_managers_test.sql` e `supabase/tests/seed_test.sql`
