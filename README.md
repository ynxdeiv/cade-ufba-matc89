# Cade UFBA

App universitario para a UFBA.

## Pre-requisitos

- Flutter 3.41+
- Dart 3.11+

### Instalando o Flutter

**macOS (Homebrew):**
```bash
brew install --cask flutter
```

**Ou manualmente:**
Baixe em https://docs.flutter.dev/get-started/install e adicione ao PATH.

Verifique a instalacao:
```bash
flutter doctor
```

## Como rodar

```bash
# 1. Instale as dependencias
flutter pub get

# 2. Rode o app
flutter run
```

## Ambiente de desenvolvimento (Docker + Supabase)

Pre-requisitos adicionais: Docker, Docker Compose e [Supabase CLI](https://supabase.com/docs/guides/cli) (`brew install supabase/tap/supabase`).

```bash
# 1. Copie o template de variaveis e preencha SUPABASE_ANON_KEY
cp .env.desenvolvimento.example .env.desenvolvimento
# (pegue a anon key da saida de `supabase start`)

# 2. Suba tudo
make up          # supabase start + container Flutter ocioso

# 4. Comandos do dia-a-dia
make pub-get     # instala dependencias dentro do container
make gen         # roda build_runner (freezed/json_serializable)
make test        # roda flutter test
make web         # roda o app em http://localhost:8080
make down        # encerra tudo
```

O arquivo `.env.desenvolvimento` e ignorado pelo git. Para mobile/emulador, prefira rodar o Flutter no host apontando para o Supabase local (veja `CLAUDE.md` para detalhes de conectividade `host.docker.internal` / `10.0.2.2`).

### Migrations Supabase

```bash
supabase migration new create_events_table   # gera arquivo SQL em supabase/migrations/
supabase db reset                             # aplica todas as migrations do zero
```

### Arquivos relevantes

- `docker-compose.yml` — servico `flutter` ocioso, comandos via `docker compose exec`.
- `docker/flutter.Dockerfile` — `dart:3.4-sdk` + Flutter 3.22.0.
- `Makefile` — atalhos para o fluxo acima.
- `.env.desenvolvimento.example` — template do ambiente de desenvolvimento.

## Estrutura do projeto

```
lib/
├── main.dart                  # Ponto de entrada
├── app.dart                   # Widget raiz (MaterialApp)
├── router.dart                # Rotas com GoRouter
│
├── features/                  # Features organizadas por dominio
│   ├── auth/                  # Autenticacao
│   ├── events/                # Eventos universitarios
│   ├── chat/                  # Chat com IA
│   ├── agenda/                # Agenda pessoal
│   └── profile/               # Perfil do usuario
│
├── core/                      # Codigo compartilhado base
│   ├── errors/                # Failures e Exceptions
│   ├── network/               # Cliente HTTP
│   ├── usecases/              # Classe base UseCase
│   └── constants/             # Constantes do app
│
├── shared/                    # Widgets e utilitarios compartilhados
│   ├── widgets/
│   ├── theme/
│   └── extensions/
│
├── config/                    # Configuracoes
│   ├── env.dart               # Variaveis de ambiente
│   └── di.dart                # Injecao de dependencias (GetIt)
│
└── services/                  # Servicos externos
    ├── ai_service.dart
    └── calendar_service.dart
```

### Arquitetura por feature (Clean Architecture)

Cada feature segue tres camadas:

```
feature/
├── presentation/              # UI
│   ├── screens/               # Telas
│   ├── widgets/               # Widgets especificos
│   └── providers/             # Estado (Riverpod)
├── domain/                    # Regras de negocio
│   ├── entities/              # Entidades puras
│   ├── repositories/          # Interfaces (classes abstratas)
│   └── usecases/              # Casos de uso
└── data/                      # Acesso a dados
    ├── models/                # Modelos (JSON serialization)
    ├── repositories/          # Implementacao das interfaces
    └── datasources/           # Fontes de dados (API, local)
```

## Dependencias principais

| Pacote | Uso |
|--------|-----|
| flutter_riverpod | Gerenciamento de estado |
| go_router | Navegacao |
| dio | HTTP client |
| supabase_flutter | Backend (auth, database) |
| hive_flutter | Armazenamento local |
| get_it | Injecao de dependencias |
| dartz | Tipos funcionais (Either) |
| equatable | Comparacao de objetos |
| freezed | Geracao de codigo imutavel |
