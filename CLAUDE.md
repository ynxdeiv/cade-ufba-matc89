# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project state

Projeto inicializado por `flutter create` (Flutter 3.41.9 / Dart 3.11). Plataformas: `android/`, `ios/`, `web/`. Supabase local inicializado (`supabase/config.toml`). O `lib/` ainda contém apenas o `main.dart` default + diretórios vazios da Clean Architecture (auth, events, chat, agenda, profile × presentation/domain/data); `app.dart`, `router.dart`, `config/di.dart`, etc. ainda precisam ser implementados.

## Common commands

Requires Flutter 3.41+ / Dart 3.11+ (o `docker/flutter.Dockerfile` pinou em 3.41.9 para casar com o `pubspec.lock`). The canonical dev environment is **dockerized** (see "Ambiente de desenvolvimento" below); the Makefile is the entry point. Raw `flutter` commands also work when running on the host (recommended for mobile/emulador).

```bash
make up                  # supabase start + docker compose up -d flutter
make pub-get             # flutter pub get inside the container
make gen                 # build_runner (freezed/json_serializable)
make test                # flutter test
make web                 # flutter run -d web-server on :8080
make down                # tear everything down

# Single test (run inside the container shell via `make flutter-shell`):
flutter test path/to/foo_test.dart
flutter test --name "substring"
```

## Ambiente de desenvolvimento

Composição:

- **`docker-compose.yml`** — serviço `flutter` ocioso (`tail -f /dev/null`), construído via `docker/flutter.Dockerfile`. Comandos são executados sob demanda com `docker compose exec flutter ...` (exposto pelo `Makefile`). Volumes nomeados `flutter-pub-cache` e `flutter-build` evitam I/O lento do bind-mount no macOS para `.pub-cache` e `build/`.
- **`docker/flutter.Dockerfile`** — base `dart:3.4-sdk` + Flutter SDK 3.22.0 clonado do GitHub, com `flutter precache --web`.
- **Supabase local** — orquestrado pelo **Supabase CLI no host**, não pelo compose (`brew install supabase/tap/supabase`, então `supabase init` e `supabase start`). O `make up` chama `supabase start` antes de subir o container Flutter. Estúdio em `http://localhost:54323`, API em `http://localhost:54321`, Postgres em `localhost:54322`. Migrations vivem em `supabase/migrations/` (criadas por `supabase migration new ...`, aplicadas com `supabase db reset`).
- **Arquivo de ambiente: `.env.desenvolvimento`** (gitignored). Use `.env.desenvolvimento.example` como template e preencha `SUPABASE_ANON_KEY` com a saída de `supabase start`. O `docker-compose.yml` carrega esse arquivo via `env_file`. Convenção: ambientes adicionais devem seguir o mesmo padrão (`.env.homologacao`, `.env.producao`).

Notas de conectividade:

- Container Flutter → Supabase host: use `http://host.docker.internal:54321` (já no `.env.desenvolvimento.example`; `extra_hosts: host-gateway` garante isso no Linux).
- Host Flutter → Supabase host: `http://localhost:54321`.
- Emulador Android → Supabase host: `http://10.0.2.2:54321`.
- iOS simulator / dispositivo físico na mesma Wi-Fi: IP da máquina.

Para mobile/emulador, rode o Flutter no host (não no container) passando as chaves:

```bash
flutter run --dart-define=SUPABASE_URL=http://localhost:54321 \
            --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

## Architecture

The intended structure (per `README.md`) is **Clean Architecture, feature-sliced**. Top-level `lib/`:

- `main.dart` / `app.dart` / `router.dart` — entry point, root `MaterialApp`, and `GoRouter` routes.
- `features/{auth,events,chat,agenda,profile}/` — each feature is split into three layers:
  - `presentation/` — `screens/`, `widgets/`, and Riverpod `providers/`.
  - `domain/` — pure `entities/`, abstract `repositories/` (interfaces), and `usecases/`.
  - `data/` — `models/` (JSON), concrete `repositories/` (implement domain interfaces), and `datasources/` (API/local).
- `core/` — shared base: `errors/` (Failures/Exceptions), `network/` (HTTP client), `usecases/` (base `UseCase`), `constants/`.
- `shared/` — `widgets/`, `theme/`, `extensions/` reusable across features.
- `config/` — `env.dart` (env vars) and `di.dart` (GetIt registration).
- `services/` — external integrations (`ai_service.dart`, `calendar_service.dart`).

Dependency rule: `presentation → domain ← data`. Domain has no Flutter or package imports; repository interfaces live in `domain/repositories/` and are implemented in `data/repositories/`. Use cases in `domain/usecases/` orchestrate repository calls and are invoked from Riverpod providers.

## Stack conventions

| Concern | Package |
|---|---|
| State management | `flutter_riverpod` |
| Navigation | `go_router` (define routes in `lib/router.dart`) |
| HTTP | `dio` |
| Backend (auth + DB) | `supabase_flutter` |
| Local storage | `hive_flutter` |
| DI | `get_it` (register in `lib/config/di.dart`) |
| Functional types | `dartz` (return `Either<Failure, T>` from repositories/use cases) |
| Value equality | `equatable` |
| Codegen / immutability | `freezed` — run `dart run build_runner build --delete-conflicting-outputs` after editing `@freezed` classes |