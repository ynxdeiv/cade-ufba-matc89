# Cadê UFBA

App universitário para a UFBA — eventos, agenda e chatbot com IA (Cadu).

## Pré-requisitos

| Ferramenta | Versão mínima |
|---|---|
| Flutter + Dart | 3.41+ / 3.11+ |
| Docker + Docker Compose | qualquer recente |
| Supabase CLI | qualquer recente |

### Instalando o Flutter

**macOS**
```bash
brew install --cask flutter
```

**Windows**
Baixe o instalador em [docs.flutter.dev/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows) e siga as instruções. Recomendado: adicionar `C:\src\flutter\bin` ao PATH pelo instalador.

**Linux**
```bash
sudo snap install flutter --classic
# ou, sem snap:
git clone https://github.com/flutter/flutter.git -b stable ~/flutter
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc && source ~/.bashrc
```

Verifique a instalação em qualquer SO:
```bash
flutter doctor
```

### Instalando a Supabase CLI

**macOS**
```bash
brew install supabase/tap/supabase
```

**Windows**
```powershell
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase
```
Ou baixe o executável direto em [github.com/supabase/cli/releases](https://github.com/supabase/cli/releases).

**Linux**
```bash
brew install supabase/tap/supabase   # se tiver Homebrew
# ou via script direto:
curl -fsSL https://raw.githubusercontent.com/supabase/cli/main/scripts/install.sh | sh
```

### Docker

Em todos os sistemas: [docs.docker.com/get-docker](https://docs.docker.com/get-docker/)

---

## Primeira vez na máquina (setup completo)

Execute **em ordem**:

```bash
# 1. Clone e instale dependências Flutter
git clone <url-do-repo> && cd cade-ufba-matc89
flutter pub get

# 2. Copie o template de variáveis de ambiente
cp .env.desenvolvimento.example .env.desenvolvimento

# 3. Inicie o Supabase local (Postgres + Auth + Studio)
supabase start
#    Anote o valor de "anon key" e "service_role key" que aparecem no terminal.
#    Exemplo de saída:
#      API URL: http://localhost:54321
#      anon key: eyJhb...
#      service_role key: eyJhb...

# 4. Preencha o .env.desenvolvimento com as chaves acima
#    SUPABASE_URL=http://localhost:54321     (já pré-preenchido)
#    SUPABASE_ANON_KEY=<anon key acima>
#    ANTHROPIC_API_KEY=<sua chave em console.anthropic.com>
#    SUPABASE_SERVICE_ROLE_KEY=<service_role key acima>  ← usada pela Edge Function

# 5. Aplique as migrations e o seed de eventos
supabase db reset
#    Cria todas as tabelas, políticas RLS, funções RPC e insere eventos de teste.

# 6. Configure os segredos da Edge Function (local)
supabase secrets set --env-file .env.desenvolvimento
```

Pronto — o banco está populado e os segredos estão disponíveis para a Edge Function.

---

## Como rodar (dia a dia)

### Opção A — Web via Docker (recomendado para backend+frontend juntos)

```bash
make up           # supabase start + container Flutter ocioso
make pub-get      # instala dependências dentro do container (só na 1ª vez ou após pubspec.yaml mudar)
make web          # abre o app em http://localhost:8080
make down         # encerra tudo
```

Para rodar a Edge Function `cadu-chat` localmente em paralelo:
```bash
supabase functions serve cadu-chat --env-file .env.desenvolvimento
# Edge Function disponível em http://localhost:54321/functions/v1/cadu-chat
```

### Opção B — Mobile/Emulador no host (Android/iOS)

Rode o Flutter diretamente no host (sem Docker), passando as variáveis:
```bash
# Android Emulator (usa 10.0.2.2 para acessar o host)
flutter run --dart-define=SUPABASE_URL=http://10.0.2.2:54321 \
            --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

# iOS Simulator / dispositivo físico (mesma rede Wi-Fi → IP da máquina)
flutter run --dart-define=SUPABASE_URL=http://192.168.x.x:54321 \
            --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

---

## Outros comandos úteis

```bash
make gen          # build_runner: regenera código freezed/json_serializable
make test         # flutter test (dentro do container)
make flutter-shell  # abre bash no container Flutter

# Migrations novas
supabase migration new nome_da_migration   # cria arquivo SQL em supabase/migrations/
supabase db reset                          # aplica todas as migrations do zero (destrói dados locais)

# Variáveis de ambiente da Edge Function
supabase secrets set ANTHROPIC_API_KEY=sk-ant-...
supabase secrets list    # confirma os segredos configurados

# Modo mock (sem gastar API key) — ative no .env.desenvolvimento
CADU_MOCK=true
```

---

## Variáveis de ambiente

Copie `.env.desenvolvimento.example` → `.env.desenvolvimento` e preencha:

| Variável | Onde encontrar | Obrigatória |
|---|---|---|
| `SUPABASE_URL` | `supabase start` → "API URL" | Sim |
| `SUPABASE_ANON_KEY` | `supabase start` → "anon key" | Sim |
| `SUPABASE_SERVICE_ROLE_KEY` | `supabase start` → "service_role key" | Sim (Edge Function) |
| `ANTHROPIC_API_KEY` | [console.anthropic.com](https://console.anthropic.com) | Sim (chatbot real) |
| `CADU_MOCK` | — | Não (padrão: `false`) |

> O arquivo `.env.desenvolvimento` é ignorado pelo git. Nunca comite chaves de API.

---

## Conectividade container ↔ Supabase

| Contexto | URL do Supabase |
|---|---|
| Container Flutter (Docker) | `http://host.docker.internal:54321` |
| Host (Flutter no host) | `http://localhost:54321` |
| Android Emulator | `http://10.0.2.2:54321` |
| iOS Simulator / dispositivo Wi-Fi | IP da máquina (ex: `http://192.168.x.x:54321`) |

---

## Estrutura do projeto

```
lib/
├── main.dart                  # Ponto de entrada
├── app.dart                   # Widget raiz (MaterialApp)
├── router.dart                # Rotas com GoRouter
│
├── features/                  # Features organizadas por domínio
│   ├── auth/                  # Autenticação
│   ├── events/                # Eventos universitários
│   ├── chat/                  # Chat com IA (Cadu)
│   ├── agenda/                # Agenda pessoal
│   └── profile/               # Perfil do usuário
│
├── core/                      # Código compartilhado base
│   ├── errors/                # Failures e Exceptions
│   ├── network/               # Cliente HTTP
│   ├── usecases/              # Classe base UseCase
│   └── constants/             # Constantes do app
│
├── shared/                    # Widgets e utilitários compartilhados
│   ├── widgets/
│   ├── theme/
│   └── extensions/
│
├── config/                    # Configurações
│   ├── env.dart               # Variáveis de ambiente
│   └── di.dart                # Injeção de dependências (GetIt)
│
└── services/                  # Serviços externos
    ├── ai_service.dart
    └── calendar_service.dart

supabase/
├── migrations/                # Schema, RLS, RPCs (aplicar com supabase db reset)
├── functions/
│   └── cadu-chat/             # Edge Function do chatbot (Deno + Anthropic)
├── seed.sql                   # Eventos de teste para desenvolvimento
└── config.toml                # Configuração do Supabase local
```

### Arquitetura por feature (Clean Architecture)

```
feature/
├── presentation/              # UI
│   ├── screens/
│   ├── widgets/
│   └── providers/             # Estado (Riverpod)
├── domain/                    # Regras de negócio (sem Flutter imports)
│   ├── entities/
│   ├── repositories/          # Interfaces abstratas
│   └── usecases/
└── data/                      # Acesso a dados
    ├── models/
    ├── repositories/          # Implementações das interfaces
    └── datasources/           # Supabase, Hive, etc.
```

Regra de dependência: `presentation → domain ← data`. Domain não importa Flutter nem pacotes externos.

---

## Dependências principais

| Pacote | Uso |
|---|---|
| `flutter_riverpod` | Gerenciamento de estado |
| `go_router` | Navegação |
| `dio` | HTTP client |
| `supabase_flutter` | Backend (auth, database, Edge Functions) |
| `hive_flutter` | Armazenamento local |
| `get_it` | Injeção de dependências |
| `dartz` | Tipos funcionais (`Either`) |
| `equatable` | Comparação de objetos |
| `freezed` | Geração de código imutável |

---

## Decisões de arquitetura (ADRs)

- [0001 — Fonte de dados de eventos no MVP](docs/decisoes/0001-fonte-de-eventos.md): por que o MVP usa seed manual via SQL + tabela `event_managers` em vez de scraping ou painel admin.
