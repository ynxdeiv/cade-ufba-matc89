# Tarefas — Cadê UFBA

Plano de execução baseado em `REQUISITOS.MD`. A configuração do projeto (Flutter scaffold, Supabase CLI, Docker, Makefile, `.env.desenvolvimento`) já está pronta — estas tarefas começam a partir da modelagem de dados.

**Regra de priorização:** o backend é o core do produto e mantém 3 tarefas de vantagem sobre o frontend. Tarefas listadas em ordem de execução; cada bloco indica dependências.

**Convenção de IDs:** `BE-XXX` (backend / Supabase) e `FE-XXX` (frontend / Flutter).

---

## #1 — [BE-001] Modelagem do banco e Row Level Security

**Requisitos cobertos:** RF-BE-02, RF-BE-04, RF-BE-05, RF-BE-09, RF-BE-13, RNF-03.

**Descrição:** Criar o esquema relacional base no Supabase (Postgres) e habilitar RLS em todas as tabelas. Estabelece a fundação de dados para auth, eventos, agenda e chat.

**Arquivos a criar:**
- `supabase/migrations/<ts>_init_schema.sql` — `CREATE TABLE`:
  - `profiles (id uuid PK FK→auth.users, nome text, vinculo text check in ('discente','docente','externo'), curso_departamento text, foto_url text, created_at timestamptz default now(), updated_at timestamptz)`
  - `events (id uuid PK default gen_random_uuid(), titulo text not null, descricao text, inicio timestamptz not null, fim timestamptz, local text, responsavel text, carga_horaria interval, tem_certificado bool default false, categoria text, unidade text, capacidade int, link_externo text, created_at timestamptz default now())`
  - `user_events (user_id uuid FK→profiles, event_id uuid FK→events, status text check in ('confirmado','cancelado') default 'confirmado', marcado_em timestamptz default now(), PK (user_id, event_id))`
  - `chat_messages (id bigserial PK, user_id uuid FK→profiles, role text check in ('user','assistant'), conteudo text, eventos_referenciados uuid[], created_at timestamptz default now())`
  - Índices em `events(inicio)`, `events(categoria)`, `events(unidade)`, `user_events(user_id, marcado_em)`, `chat_messages(user_id, created_at)`.
- `supabase/migrations/<ts>_rls_policies.sql` — `ALTER TABLE ... ENABLE ROW LEVEL SECURITY` em todas as tabelas e políticas:
  - `profiles`: select/update onde `auth.uid() = id`.
  - `user_events`: ALL onde `auth.uid() = user_id`.
  - `chat_messages`: ALL onde `auth.uid() = user_id`.
  - `events`: select público para `authenticated`; insert/update/delete restritos a role `admin` (placeholder via custom claim ou tabela `event_managers`).

**Critérios de aceite:**
- [ ] `supabase db reset` aplica as migrations sem erro.
- [ ] `select * from pg_tables where schemaname='public'` retorna as 4 tabelas.
- [ ] Em sessão autenticada como `user_a`, `select * from user_events` não retorna linhas de `user_b`.
- [ ] Tentativa de `insert into events` por usuário comum falha com erro de RLS.
- [ ] Foreign keys testadas: deletar `auth.users` em cascata deleta `profiles` e `user_events`.

---

## #2 — [BE-002] Auth + sincronização de perfil

**Requisitos cobertos:** RF-BE-01, RF-BE-02, RF-BE-03, RF-FE-05 (lado servidor).
**Depende de:** BE-001.

**Descrição:** Configurar Supabase Auth (email/senha + confirmação por email + recuperação) e criar trigger que popula `profiles` automaticamente quando um `auth.users` é criado.

**Arquivos a alterar/criar:**
- `supabase/config.toml` — em `[auth]`: `enable_signup = true`, `enable_confirmations = true`, `site_url = "http://localhost:3000"`, `additional_redirect_urls = ["cadeufba://auth-callback"]`; em `[auth.email]`: `enable_signup = true`, `double_confirm_changes = true`.
- `supabase/migrations/<ts>_profile_trigger.sql`:
  - Função `handle_new_user()` que insere em `profiles (id, nome)` lendo `new.id` e `new.raw_user_meta_data->>'nome'`.
  - Trigger `on_auth_user_created` after insert em `auth.users` chamando `handle_new_user()`.
  - Função `handle_user_delete()` + trigger after delete para limpar `user_events` e `chat_messages` (LGPD — RNF-04).
- `supabase/templates/recovery.html` (se padrão for substituído) — template de email em pt-BR.

**Critérios de aceite:**
- [ ] `supabase.auth.signUp({ email, password, options: { data: { nome } } })` cria entrada em `auth.users` e linha correspondente em `profiles`.
- [ ] Login com senha errada retorna erro 400; com senha correta retorna `access_token` + `refresh_token`.
- [ ] `supabase.auth.resetPasswordForEmail(email)` dispara email visível em Inbucket (`http://localhost:54324`).
- [ ] Confirmação de email é obrigatória — usuário não confirmado não consegue obter sessão.
- [ ] Delete em `auth.users` remove linhas correlatas em `user_events` e `chat_messages`.

---

## #3 — [BE-003] RPC de listagem de eventos com filtros

**Requisitos cobertos:** RF-BE-08, RF-FE-06, RF-FE-07.
**Depende de:** BE-001.

**Descrição:** Expor uma função RPC `listar_eventos` que aceita filtros (intervalo de data, categoria, unidade, busca textual, paginação) e retorna eventos ordenados por `inicio`. Função SQL pura — sem Edge Function — para performance.

**Arquivos a criar:**
- `supabase/migrations/<ts>_rpc_listar_eventos.sql`:
  - Extensão `pg_trgm` para busca textual (`CREATE EXTENSION IF NOT EXISTS pg_trgm`).
  - Índice GIN em `events` usando `gin_trgm_ops` sobre `titulo || ' ' || descricao`.
  - Função `listar_eventos(p_inicio timestamptz, p_fim timestamptz, p_categoria text default null, p_unidade text default null, p_busca text default null, p_tem_certificado bool default null, p_limit int default 20, p_offset int default 0) returns setof events` com filtros aplicados via `where` opcional.
  - `grant execute on function listar_eventos to authenticated, anon`.

**Critérios de aceite:**
- [ ] Chamada via `supabase.rpc('listar_eventos', { p_inicio: ..., p_fim: ... })` retorna eventos no intervalo.
- [ ] Filtros opcionais funcionam isoladamente e combinados.
- [ ] Busca textual com `pg_trgm` retorna eventos com similaridade no título OU descrição.
- [ ] `p_limit` e `p_offset` paginam corretamente; ordenação estável por `(inicio asc, id asc)`.
- [ ] `EXPLAIN ANALYZE` mostra uso dos índices em filtros por data + categoria.

---

## #4 — [BE-004] Endpoints de agenda do usuário

**Requisitos cobertos:** RF-BE-09, RF-BE-10, RF-FE-14, RF-FE-16.
**Depende de:** BE-001.

**Descrição:** Funções RPC para listar, adicionar e remover eventos da agenda do usuário autenticado. Toda escrita passa por validação de existência do evento.

**Arquivos a criar:**
- `supabase/migrations/<ts>_rpc_agenda.sql`:
  - `listar_agenda(p_inicio timestamptz, p_fim timestamptz) returns table(...)` — join `user_events` × `events` filtrado por `auth.uid()` e intervalo.
  - `adicionar_a_agenda(p_event_id uuid) returns user_events` — insert idempotente (`on conflict do nothing`).
  - `remover_da_agenda(p_event_id uuid) returns void` — delete por `(auth.uid(), p_event_id)`.
  - `dias_com_eventos_do_usuario(p_inicio date, p_fim date) returns table(dia date, count int)` — agregação para destacar dias no calendário (RF-FE-14).
  - Permissions: `grant execute to authenticated`.

**Critérios de aceite:**
- [ ] `adicionar_a_agenda` chamada duas vezes com o mesmo evento não duplica linha.
- [ ] `remover_da_agenda` por usuário A não afeta agenda do usuário B.
- [ ] `listar_agenda` retorna apenas eventos do usuário autenticado, ordenados por `inicio`.
- [ ] `dias_com_eventos_do_usuario` retorna agregação correta para um mês com 3 eventos em dias distintos.
- [ ] Chamada das funções sem auth (anon) falha.

---

## #5 — [FE-001] Bootstrap do app: tema, rotas, DI e tratamento de erros

**Requisitos cobertos:** RF-FE-19, RF-FE-22, RNF-07.
**Depende de:** BE-001..BE-004 (não bloqueia tecnicamente, mas é o gating do front).

**Descrição:** Sair do `main.dart` default e montar a infra do app: theme claro/escuro, GoRouter, GetIt, cliente Supabase, classes base de Failure/Exception e widget genérico de erro.

**Arquivos a alterar/criar:**
- `pubspec.yaml` — adicionar deps: `flutter_riverpod`, `go_router`, `dio`, `supabase_flutter`, `hive`, `hive_flutter`, `get_it`, `dartz`, `equatable`, `freezed_annotation`, `json_annotation`; dev: `freezed`, `json_serializable`, `build_runner`, `flutter_lints`.
- `lib/main.dart` — substituir scaffold default: carregar `.env.desenvolvimento` via `--dart-define`, `Supabase.initialize(...)`, registrar DI, `runApp(ProviderScope(child: CadeUfbaApp()))`.
- `lib/app.dart` — `class CadeUfbaApp extends ConsumerWidget` retornando `MaterialApp.router` com `themeMode: ThemeMode.system`, `theme: AppTheme.light`, `darkTheme: AppTheme.dark`.
- `lib/router.dart` — `GoRouter` com rotas placeholder: `/login`, `/cadastro`, `/recuperar`, `/home` (shell com tabs `eventos`, `agenda`, `chat`, `perfil`), redirect baseado em `Supabase.auth.currentSession`.
- `lib/config/env.dart` — classe `Env` lendo `String.fromEnvironment('SUPABASE_URL')` e `SUPABASE_ANON_KEY`.
- `lib/config/di.dart` — registro do `Dio`, `SupabaseClient` (já obtido via singleton do `supabase_flutter`), bases de repositórios.
- `lib/shared/theme/app_theme.dart` — `AppTheme.light`/`dark` com `ColorScheme.fromSeed(seedColor: Color(0xFF005CA9))` (azul UFBA).
- `lib/core/errors/failures.dart` — `sealed class Failure` + subclasses `NetworkFailure`, `AuthFailure`, `ServerFailure`, `CacheFailure`, `ValidationFailure(String campo, String mensagem)`.
- `lib/core/errors/exceptions.dart` — exceptions correspondentes lançadas em datasources.
- `lib/core/usecases/usecase.dart` — `abstract class UseCase<T, P> { Future<Either<Failure, T>> call(P params); }`.
- `lib/shared/widgets/error_view.dart` — widget reutilizável com ícone + mensagem amigável + botão "Tentar novamente".

**Critérios de aceite:**
- [ ] `flutter analyze` sem erros.
- [ ] `flutter run -d chrome` exibe tela de login (placeholder) sem crash.
- [ ] Trocar o tema do SO (light↔dark) reflete na UI sem reiniciar.
- [ ] Tentar acessar `/home` sem sessão redireciona para `/login`.
- [ ] Cliente Supabase autenticado expõe `Supabase.instance.client.auth.currentUser` quando há sessão.
- [ ] `flutter test` passa (smoke test do `widget_test.dart` atualizado para a nova root).

---

## #6 — [BE-005] Seed de eventos e definição da fonte de dados

**Requisitos cobertos:** RF-BE-06, RF-BE-07 (parcial).
**Depende de:** BE-001.

**Descrição:** Resolver a lacuna crítica do PDF (RF-BE-06): definir, ao menos para o MVP, **seed manual via SQL** como fonte de eventos. Documentar a decisão e deixar interface preparada para futura ingestão (CSV/scraping/API institucional). Popular `seed.sql` com ~30 eventos realistas para suportar desenvolvimento do front.

**Arquivos a alterar/criar:**
- `supabase/seed.sql` — `insert into events (...)` com 30+ registros variados (categorias: palestra, minicurso, congresso, defesa, evento cultural; unidades: IME, Instituto de Computação, Reitoria, FACED, etc.; janela de datas: -7 dias a +60 dias a partir de hoje).
- `supabase/migrations/<ts>_event_managers.sql` — tabela `event_managers (user_id uuid PK FK→profiles)` para identificar quem pode gerenciar eventos; ajustar RLS de `events` para `insert/update/delete` exigir `auth.uid() in (select user_id from event_managers)`.
- `docs/decisoes/0001-fonte-de-eventos.md` — ADR curta: contexto, decisão (seed + cadastro manual via SQL no MVP), alternativas consideradas (scraping, API institucional, painel admin), próximos passos.

**Critérios de aceite:**
- [ ] `supabase db reset` aplica seed sem erro.
- [ ] `select count(*) from events` ≥ 30.
- [ ] Usuário promovido a `event_managers` consegue inserir/atualizar eventos; usuário comum recebe erro de RLS.
- [ ] ADR está commitada e linkada no `README.md`.

---

## #7 — [FE-002] Telas de autenticação (login, cadastro, recuperação)

**Requisitos cobertos:** RF-FE-01, RF-FE-02, RF-FE-05, RF-FE-22.
**Depende de:** FE-001, BE-002.

**Descrição:** Implementar a feature `auth` completa nas três camadas (domain/data/presentation) usando Supabase Auth.

**Arquivos a criar:**
- `lib/features/auth/domain/entities/usuario.dart` — `@freezed class Usuario` (id, email, nome, vinculo).
- `lib/features/auth/domain/repositories/auth_repository.dart` — interface: `Future<Either<Failure, Usuario>> login(email, senha)`, `cadastrar(...)`, `Future<Either<Failure, void>> recuperarSenha(email)`, `logout()`, `Stream<Usuario?> sessionStream()`.
- `lib/features/auth/domain/usecases/{login,cadastrar,recuperar_senha,logout}.dart` — UseCases finos delegando ao repo.
- `lib/features/auth/data/datasources/auth_remote_datasource.dart` — wrapper sobre `Supabase.instance.client.auth` (`signInWithPassword`, `signUp`, `resetPasswordForEmail`, `signOut`).
- `lib/features/auth/data/repositories/auth_repository_impl.dart` — mapeia exceções → `Failure`.
- `lib/features/auth/presentation/providers/auth_provider.dart` — `StateNotifierProvider` com estados (`Idle`, `Loading`, `Authenticated`, `Error`).
- `lib/features/auth/presentation/screens/{login,cadastro,recuperar_senha}_screen.dart` — formulários com validação em tempo real (regex email, força de senha ≥ 8 chars com 1 dígito + 1 letra).
- `lib/features/auth/presentation/widgets/{campo_email,campo_senha,botao_primario}.dart` — widgets reutilizáveis com mensagens de erro inline.
- `lib/router.dart` — substituir placeholders pelas telas reais; adicionar rota `/auth-callback` para deep link de confirmação.

**Critérios de aceite:**
- [ ] Cadastro com email válido + senha forte + nome cria conta e mostra tela "verifique seu email".
- [ ] Email inválido ou senha fraca bloqueia o submit e mostra erro inline em pt-BR.
- [ ] Login com credenciais corretas navega para `/home`.
- [ ] Login com credenciais erradas mostra "email ou senha inválidos" (sem revelar qual).
- [ ] "Esqueci minha senha" envia email visível no Inbucket; link de recuperação navega para tela de redefinição no app.
- [ ] Toggle "manter conectado" persiste sessão entre reinícios; quando desligado, sessão é volátil.
- [ ] Testes de unidade nos UseCases com mock do repo (cobertura ≥ 60% — RNF-07).

---

## #8 — [BE-006] Edge Function `cadu-chat` (LLM + tool use sobre eventos)

**Requisitos cobertos:** RF-03, RF-04, RF-BE-11, RF-BE-12, RF-BE-15, RNF-03.
**Depende de:** BE-001, BE-003.

**Descrição:** Edge Function Deno que recebe mensagem do usuário, consulta a tabela `events` via tool use, e responde em linguagem natural. A chave da LLM **nunca** sai do servidor.

**Arquivos a criar:**
- `supabase/functions/cadu-chat/index.ts`:
  - Deno serve: aceita `POST { mensagem: string, historico?: Message[] }`.
  - Valida JWT do usuário via `supabase.auth.getUser(authHeader)`.
  - Chama Anthropic API (`claude-sonnet-4-6` por custo-eficiência; chave em `Deno.env.get('ANTHROPIC_API_KEY')`).
  - Declara tool `buscar_eventos` com schema (intervalo de datas, categoria, unidade, busca) — handler executa `supabase.rpc('listar_eventos', ...)`.
  - **Prompt caching:** marca o system prompt + a definição da tool como `cache_control: { type: 'ephemeral' }` para reduzir custo em conversas multi-turn.
  - Retorna `{ resposta: string, eventos_referenciados: uuid[] }`.
- `supabase/functions/cadu-chat/system_prompt.ts` — prompt do Cadu em pt-BR, com instruções: usar sempre a tool antes de afirmar disponibilidade de evento; nunca inventar; responder com data/hora/local/responsável/carga horária/certificado quando disponível.
- `supabase/functions/_shared/cors.ts` — headers CORS para chamadas do Flutter Web.
- `.env.desenvolvimento.example` — adicionar `ANTHROPIC_API_KEY=` (apenas localmente — em prod fica em secrets do Supabase).

**Critérios de aceite:**
- [ ] Chamada sem JWT retorna 401.
- [ ] Pergunta "tem palestra de IA semana que vem?" dispara tool call com `p_inicio`/`p_fim` corretos e retorna resposta citando eventos reais do seed.
- [ ] Pergunta sobre período sem eventos retorna mensagem informando que nada foi encontrado (sem alucinar).
- [ ] `eventos_referenciados` retornado bate com os IDs efetivamente usados.
- [ ] Resposta inclui campos requeridos pelo RF-03 (data, hora, local, responsável, carga horária, certificado) quando o evento os possui.
- [ ] Logs mostram `cache_read_input_tokens > 0` a partir da segunda chamada.

---

## #9 — [FE-003] Tela de perfil e logout

**Requisitos cobertos:** RF-FE-03, RF-FE-04, RF-BE-02.
**Depende de:** FE-002, BE-002.

**Descrição:** Exibição e edição do perfil do usuário, com upload de foto para Supabase Storage e logout com limpeza local.

**Arquivos a criar/alterar:**
- `lib/features/profile/domain/entities/perfil.dart` — `@freezed class Perfil` (id, nome, email, vinculo, cursoDepartamento, fotoUrl).
- `lib/features/profile/domain/repositories/profile_repository.dart` — `obter()`, `atualizar(Perfil)`, `enviarFoto(File)`.
- `lib/features/profile/data/datasources/profile_remote_datasource.dart` — query/update na tabela `profiles` + upload no bucket `avatars`.
- `lib/features/profile/data/repositories/profile_repository_impl.dart`.
- `lib/features/profile/presentation/providers/profile_provider.dart`.
- `lib/features/profile/presentation/screens/perfil_screen.dart` — modo visualização ↔ edição; dropdown de vínculo.
- `lib/features/profile/presentation/widgets/avatar_picker.dart` — `image_picker` + crop quadrado.
- `supabase/migrations/<ts>_storage_avatars.sql` — `insert into storage.buckets (id, name, public) values ('avatars', 'avatars', true)`; políticas: usuário só faz upload/update no path `<auth.uid()>/*`.
- `pubspec.yaml` — adicionar `image_picker`.

**Critérios de aceite:**
- [ ] Abrir `/perfil` mostra dados atuais sem flicker (cache otimista via Riverpod).
- [ ] Editar nome + curso e salvar persiste no banco e atualiza a tela.
- [ ] Upload de foto: arquivo > 2MB é comprimido antes do upload; URL retornada é exibida.
- [ ] Logout limpa caixa do Hive de dados sensíveis e redireciona para `/login`.
- [ ] Usuário A não consegue fazer upload no path do usuário B (testado via curl direto na API de storage).

---

## #10 — [BE-007] Histórico de chat + rate limiting

**Requisitos cobertos:** RF-BE-13, RF-BE-14.
**Depende de:** BE-006.

**Descrição:** Persistir cada turno da conversa em `chat_messages` e impor limite de mensagens por usuário/minuto na Edge Function.

**Arquivos a alterar/criar:**
- `supabase/functions/cadu-chat/index.ts` — após cada chamada bem sucedida, `insert into chat_messages` para mensagem do usuário e do assistente; antes da chamada, consulta `chat_messages` para construir histórico (últimas N mensagens da janela de contexto).
- `supabase/migrations/<ts>_rate_limit.sql`:
  - Tabela `chat_rate_limit (user_id uuid, minuto timestamptz, contagem int, PK (user_id, minuto))`.
  - Função `verificar_rate_limit(p_user uuid, p_limite int) returns bool` — upsert na linha do minuto corrente; retorna false se contagem > limite.
- `supabase/functions/cadu-chat/index.ts` — chamar `verificar_rate_limit(user.id, 10)`; se false retornar 429.
- `supabase/migrations/<ts>_rpc_listar_historico.sql` — `listar_historico_chat(p_limit int default 50)` para o front carregar conversa.

**Critérios de aceite:**
- [ ] Conversa de 3 turnos cria 6 linhas em `chat_messages` (3 user + 3 assistant).
- [ ] 11ª chamada do mesmo usuário em < 60s retorna HTTP 429 com mensagem amigável.
- [ ] Histórico de 50 mensagens é recuperado em < 200ms (com índice em `(user_id, created_at desc)`).
- [ ] Mensagens incluem `eventos_referenciados` quando a Edge Function usou tool.

---

## #11 — [FE-004] Listagem, busca e filtros de eventos

**Requisitos cobertos:** RF-FE-06, RF-FE-07, RF-FE-22, RNF-01.
**Depende de:** FE-001, BE-003.

**Descrição:** Feature `events` — tela principal de descoberta com lista paginada, busca textual e filtros.

**Arquivos a criar:**
- `lib/features/events/domain/entities/evento.dart` — `@freezed class Evento`.
- `lib/features/events/domain/entities/filtro_evento.dart` — `categoria, unidade, intervalo, busca, temCertificado`.
- `lib/features/events/domain/repositories/event_repository.dart`.
- `lib/features/events/domain/usecases/listar_eventos.dart`.
- `lib/features/events/data/models/evento_model.dart` — `fromJson`/`toJson` + `toEntity`.
- `lib/features/events/data/datasources/event_remote_datasource.dart` — chama RPC `listar_eventos`.
- `lib/features/events/data/repositories/event_repository_impl.dart`.
- `lib/features/events/presentation/providers/event_list_provider.dart` — paginação com `infinite_scroll_pagination` ou implementação manual.
- `lib/features/events/presentation/screens/lista_eventos_screen.dart` — `SliverAppBar` com busca, chips de filtro, lista.
- `lib/features/events/presentation/widgets/{card_evento,filtro_sheet,chip_categoria}.dart`.

**Critérios de aceite:**
- [ ] Lista inicial carrega 20 eventos ordenados por data crescente.
- [ ] Scroll até o fim carrega próxima página com loader; última página mostra "fim da lista".
- [ ] Busca por texto com debounce de 300ms; resultados refletidos sem travar a UI.
- [ ] Filtros combinados (data + categoria + certificado) refletem `EXPLAIN ANALYZE` no banco usando índices.
- [ ] Sem conexão: mostra `ErrorView` com "Tentar novamente" — primeira página é cacheada para offline.
- [ ] Tempo até primeiro paint da lista < 2s em rede simulada 3G (RNF-01).

---

## #12 — [BE-008] Push notifications + job agendado

**Requisitos cobertos:** RF-BE-16, RF-BE-17, RF-FE-18.
**Depende de:** BE-004.

**Descrição:** Disparar lembretes (1d/1h/15min antes do evento) para usuários que marcaram presença. Solução: `pg_cron` chamando Edge Function que envia push via FCM.

**Arquivos a criar:**
- `supabase/migrations/<ts>_push_setup.sql`:
  - Habilitar extensões `pg_cron` e `pg_net`.
  - Tabela `device_tokens (user_id uuid, token text, plataforma text check in ('android','ios','web'), atualizado_em timestamptz, PK (user_id, token))`.
  - Tabela `preferencias_notificacao (user_id uuid PK, antecedencias int[] default array[1440,60,15])` — minutos antes.
  - Job `cron.schedule('check-reminders', '* * * * *', $$ select net.http_post(url := '<edge_fn_url>', headers := '{...}'::jsonb) $$)`.
- `supabase/functions/enviar-lembretes/index.ts`:
  - Query: para cada `(user, event, antecedencia)`, se `event.inicio - antecedencia` cai no minuto corrente e usuário marcou presença, enviar push via FCM HTTP v1.
  - Idempotência: tabela `lembretes_enviados (user_id, event_id, antecedencia, enviado_em, PK (user_id, event_id, antecedencia))`.
- `supabase/functions/_shared/fcm.ts` — cliente FCM com OAuth2 service account.

**Critérios de aceite:**
- [ ] Evento criado para daqui a 16 minutos, com usuário inscrito e antecedência 15min: push chega em até 90s.
- [ ] Re-execução do job no minuto seguinte não envia o mesmo lembrete (idempotência).
- [ ] Usuário sem `device_token` é silenciosamente ignorado.
- [ ] Falha de envio FCM é logada mas não trava o batch.

---

## #13 — [FE-005] Detalhe de evento e compartilhamento

**Requisitos cobertos:** RF-FE-08, RF-FE-09.
**Depende de:** FE-004.

**Arquivos a criar:**
- `lib/features/events/presentation/screens/detalhe_evento_screen.dart` — `Hero` na imagem/header, descrição, metadados, botões "Adicionar à agenda" e "Compartilhar".
- `lib/features/events/presentation/widgets/{linha_metadado,botao_agenda}.dart`.
- `lib/features/events/domain/usecases/{obter_evento,adicionar_agenda}.dart`.
- `pubspec.yaml` — adicionar `share_plus`.
- `lib/router.dart` — rota `/eventos/:id`.

**Critérios de aceite:**
- [ ] Tap em um card da listagem navega ao detalhe com transição Hero.
- [ ] Compartilhar abre sheet nativo com texto: título + data + link interno (deep link).
- [ ] "Adicionar à agenda" chama `adicionar_a_agenda` (BE-004) e mostra `SnackBar` de confirmação.
- [ ] Quando já está na agenda, botão troca para "Remover da agenda".
- [ ] Tela funciona via deep link direto sem ter passado pela listagem.

---

## #14 — [FE-006] Calendário (mensal / semanal / diário)

**Requisitos cobertos:** RF-05, RF-FE-14, RF-FE-15.
**Depende de:** FE-004, BE-004.

**Arquivos a criar:**
- `lib/features/agenda/domain/usecases/{listar_agenda,dias_destacados}.dart`.
- `lib/features/agenda/presentation/providers/calendario_provider.dart`.
- `lib/features/agenda/presentation/screens/calendario_screen.dart` — `table_calendar` com 3 modos (mensal/semanal/diário).
- `lib/features/agenda/presentation/widgets/marcador_dia.dart` — pontos coloridos: azul (eventos UFBA), laranja (presença marcada).
- `pubspec.yaml` — adicionar `table_calendar`.

**Critérios de aceite:**
- [ ] Mês exibe pontos azuis em dias com eventos da UFBA e laranjas em dias da agenda.
- [ ] Tap em um dia mostra lista inferior dos eventos daquele dia (agenda + UFBA).
- [ ] Toggle troca entre mensal/semanal/diário sem perder a data selecionada.
- [ ] Localização pt-BR (dias da semana e meses em português).
- [ ] Performance: render < 100ms ao trocar de mês.

---

## #15 — [FE-007] Agenda do usuário — adicionar e remover

**Requisitos cobertos:** RF-FE-16, RF-FE-12, RF-BE-09.
**Depende de:** FE-006, BE-004.

**Arquivos a criar:**
- `lib/features/agenda/domain/usecases/{adicionar,remover}_da_agenda.dart`.
- `lib/features/agenda/presentation/screens/minha_agenda_screen.dart` — lista filtrável por intervalo.
- `lib/features/agenda/presentation/widgets/item_agenda.dart` — com swipe-to-remove.

**Critérios de aceite:**
- [ ] Adicionar evento já presente na agenda é idempotente (não duplica).
- [ ] Swipe-to-remove confirma via dialog antes de remover.
- [ ] Mudança reflete imediatamente no calendário (FE-006) via invalidação do provider compartilhado.
- [ ] Estado vazio com CTA "Explorar eventos" levando à listagem.

---

## #16 — [FE-008] Chat com o Cadu

**Requisitos cobertos:** RF-03, RF-04, RF-FE-10, RF-FE-12, RF-FE-13.
**Depende de:** FE-001, BE-006, BE-007.

**Arquivos a criar:**
- `lib/features/chat/domain/entities/mensagem.dart` — `@freezed class Mensagem` (id, role, conteudo, eventosReferenciados, createdAt).
- `lib/features/chat/domain/repositories/chat_repository.dart` — `enviar(mensagem)`, `historico()`.
- `lib/features/chat/data/datasources/chat_remote_datasource.dart` — POST para Edge Function `cadu-chat`.
- `lib/features/chat/data/repositories/chat_repository_impl.dart`.
- `lib/features/chat/presentation/providers/chat_provider.dart`.
- `lib/features/chat/presentation/screens/chat_screen.dart` — `ListView.builder` reverse, input no rodapé, indicador "digitando".
- `lib/features/chat/presentation/widgets/{bolha_mensagem,card_evento_inline,chips_sugestoes}.dart` — card de evento renderizado quando a resposta inclui `eventos_referenciados`, com botão "Adicionar à agenda".
- Chips de sugestão iniciais: "Eventos hoje", "Palestras esta semana", "Atividades com certificado".

**Critérios de aceite:**
- [ ] Mensagem enviada aparece imediatamente; resposta do Cadu chega em < 5s (RNF-01).
- [ ] Indicador "digitando" exibido até a resposta chegar.
- [ ] Cards de evento aparecem inline com botão funcional "Adicionar à agenda" (RF-FE-12).
- [ ] Chips de sugestão somem após primeira mensagem; reaparecem se conversa é resetada.
- [ ] Erro 429 (rate limit do BE-007) mostra mensagem "muitas mensagens — aguarde 1 minuto".
- [ ] Erro de rede mostra retry inline na bolha.

---

## #17 — [FE-009] Modo offline + histórico local do chat (Hive)

**Requisitos cobertos:** RF-FE-11, RF-FE-21.
**Depende de:** FE-004, FE-006, FE-008.

**Arquivos a criar:**
- `lib/core/storage/hive_boxes.dart` — `eventos_cache`, `agenda_cache`, `chat_historico_cache`.
- `lib/core/storage/hive_adapters.dart` — adapters gerados via `@HiveType`.
- Em cada repository_impl: estratégia *cache-then-network* — emite cache, busca remoto, atualiza.
- `lib/main.dart` — `Hive.initFlutter()`, registro de adapters, abertura das boxes.
- `lib/features/chat/data/datasources/chat_local_datasource.dart` — leitura/escrita do histórico em Hive.

**Critérios de aceite:**
- [ ] Sem rede, listagem de eventos abre com dados da última sessão.
- [ ] Sem rede, agenda do usuário e calendário pessoal funcionam.
- [ ] Histórico de chat persistido localmente sobrevive ao restart.
- [ ] Reconexão dispara revalidação automática.

---

## #18 — [FE-010] Notificações de lembrete locais

**Requisitos cobertos:** RF-FE-18.
**Depende de:** FE-007, BE-008.

**Arquivos a criar:**
- `lib/services/notification_service.dart` — wrapper `flutter_local_notifications` + handler do FCM (`firebase_messaging`).
- `lib/features/profile/presentation/screens/preferencias_notificacao_screen.dart` — toggles para 1d/1h/15min.
- `android/app/src/main/AndroidManifest.xml` — permissões `POST_NOTIFICATIONS`.
- `ios/Runner/Info.plist` — `UIBackgroundModes: remote-notification`.
- `pubspec.yaml` — `firebase_messaging`, `flutter_local_notifications`.

**Critérios de aceite:**
- [ ] Primeira abertura solicita permissão de notificação.
- [ ] Toggles de preferência persistem em `preferencias_notificacao` (BE-008).
- [ ] App fechado: push do BE chega como notificação do sistema.
- [ ] App em foreground: push exibe banner customizado.
- [ ] Tap na notificação navega para o detalhe do evento.

---

## #19 — [FE-011] Sincronização com calendário nativo

**Requisitos cobertos:** RF-FE-17.
**Depende de:** FE-007.

**Arquivos a criar:**
- `lib/services/calendar_service.dart` — wrapper `add_2_calendar` (ou `device_calendar` para sync bidirecional).
- `lib/features/agenda/presentation/widgets/botao_sync_calendario.dart`.
- `pubspec.yaml` — `add_2_calendar` ou `device_calendar`.
- `ios/Runner/Info.plist` — `NSCalendarsUsageDescription`.
- `android/app/src/main/AndroidManifest.xml` — `READ_CALENDAR`, `WRITE_CALENDAR`.

**Critérios de aceite:**
- [ ] Botão "Sincronizar com calendário" abre intent/picker nativo pré-preenchido.
- [ ] Remoção da agenda do app não afeta calendário nativo (sync unidirecional explícito no MVP).
- [ ] Negação de permissão mostra mensagem clara explicando o que será perdido.

---

## #20 — [FE-012] Onboarding e acessibilidade

**Requisitos cobertos:** RF-FE-20, RF-FE-23, RNF-04 (consentimento).
**Depende de:** FE-001.

**Arquivos a criar:**
- `lib/features/onboarding/presentation/screens/onboarding_screen.dart` — 3-4 slides explicando descoberta, chat, agenda.
- `lib/features/onboarding/presentation/screens/consentimento_screen.dart` — termo LGPD; aceite obrigatório para prosseguir.
- `lib/core/storage/onboarding_storage.dart` — flag em Hive `onboarding_concluido`.
- `lib/router.dart` — redirect para onboarding na primeira abertura.
- Em todas as telas: revisar `Semantics`, `MergeSemantics`, `tooltip`, contraste ≥ 4.5:1.

**Critérios de aceite:**
- [ ] Primeira abertura mostra onboarding; aberturas seguintes vão direto pro login/home.
- [ ] Tela de consentimento exige aceite explícito; recusa fecha o app.
- [ ] `flutter test --plain-name 'semantics'` valida que telas principais expõem semantics corretos.
- [ ] Auditoria com `Accessibility Scanner` (Android) e Accessibility Inspector (iOS) sem violações de contraste.

---

## Resumo das dependências

```
BE-001 ─┬─ BE-002 ─── FE-002 ─── FE-003
        ├─ BE-003 ─┬─ BE-006 ─── BE-007 ─── FE-008 ──┐
        │          └─ FE-004 ─── FE-005              ├─ FE-009
        ├─ BE-004 ─┬─ BE-008 ─── FE-010              │
        │          └─ FE-006 ─── FE-007 ─── FE-011 ──┘
        └─ BE-005

FE-001 (gating do front) precede toda FE-XXX
FE-012 pode entrar a qualquer momento após FE-001
```

## Tracking

Sugestão de fluxo no Jira (ou Linear/GitHub Projects):
1. Importar cada bloco como issue (título = primeira linha de cada `## #N — [...]`).
2. Critérios de aceite viram checklist na descrição.
3. Labels: `area/backend`, `area/frontend`, `tipo/feature`, `tipo/infra`, `prioridade/{p0,p1,p2}` — BE-001..BE-004 e FE-001 são P0.
4. Milestone: `MVP` para tarefas #1–#16; `Pós-MVP` para #17–#20.
