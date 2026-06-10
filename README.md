# Cadê UFBA

App universitário para a UFBA — eventos, agenda e chatbot com IA (Cadu).

## Pré-requisitos

| Ferramenta | Versão mínima |
|---|---|
| Flutter + Dart | 3.41+ / 3.11+ |
| Docker + Docker Compose | qualquer recente |
| Supabase CLI | qualquer recente |
| Deno (Edge Function do chatbot) | 1.40+ |

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

### Instalando o Deno

Necessário para rodar a Edge Function `cadu-chat` localmente.

```bash
# macOS / Linux
curl -fsSL https://deno.land/install.sh | sh
# macOS (Homebrew): brew install deno

# Windows (PowerShell)
irm https://deno.land/install.ps1 | iex
```

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
#    SUPABASE_URL=http://host.docker.internal:54321     (já pré-preenchido)
#    SUPABASE_ANON_KEY=<anon key acima>
#    SUPABASE_SERVICE_ROLE_KEY=<service_role key acima>  ← usada pela Edge Function
#    GEMINI_API_KEY=<sua chave em aistudio.google.com/apikey>  ← chatbot Cadu

# 5. Aplique as migrations e o seed de eventos
supabase db reset
#    Cria todas as tabelas, políticas RLS, funções RPC e insere eventos de teste.
```

Pronto — o banco está populado. Para o chatbot, a Edge Function recebe as variáveis
do `.env.desenvolvimento` quando você a roda via `deno run` (veja "Como rodar").

> ⚠️ **NÃO** rode `supabase secrets set` no desenvolvimento local — esse comando
> configura segredos do projeto **remoto (nuvem)** e exige `supabase login`.
> Veja [Solução de problemas](#solução-de-problemas).

---

## Como rodar (dia a dia)

### Opção A — Web via Docker (recomendado para backend+frontend juntos)

```bash
make up           # supabase start + container Flutter ocioso
make pub-get      # instala dependências dentro do container (só na 1ª vez ou após pubspec.yaml mudar)
make web          # abre o app em http://localhost:8080
make down         # encerra tudo
```

Para o chatbot funcionar, rode a Edge Function `cadu-chat` em **outro terminal**, na
porta `8000` (é o `FUNCTIONS_URL` que o `make web` usa). Requer [Deno](https://deno.com) instalado:

```bash
# macOS / Linux
set -a; source .env.desenvolvimento; set +a
SUPABASE_URL=http://127.0.0.1:54321 \
  deno run --allow-net --allow-env --allow-read supabase/functions/cadu-chat/index.ts
# Edge Function disponível em http://localhost:8000/cadu-chat
```

```powershell
# Windows (PowerShell)
Get-Content .env.desenvolvimento | Where-Object { $_ -match '^\s*[^#].*=' } | ForEach-Object {
  $name, $value = $_ -split '=', 2
  Set-Item "env:$($name.Trim())" $value.Trim()
}
$env:SUPABASE_URL = "http://127.0.0.1:54321"
deno run --allow-net --allow-env --allow-read supabase/functions/cadu-chat/index.ts
```

> Reinicie esse processo sempre que editar a função (`gemini.ts`, `system_prompt.ts`) ou o `.env.desenvolvimento`.
> Evite `supabase functions serve` no macOS/Apple Silicon — o edge-runtime costuma dar *Segmentation fault* (veja [Solução de problemas](#solução-de-problemas)).

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

# Segredos da Edge Function NA NUVEM (deploy remoto) — exige `supabase login` + projeto linkado.
# Para desenvolvimento LOCAL não use: a função recebe o .env ao rodar via `deno run`.
supabase secrets set GEMINI_API_KEY=...   # só para o projeto remoto
supabase secrets list                     # lista os segredos do projeto remoto

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
| `GEMINI_API_KEY` | [aistudio.google.com/apikey](https://aistudio.google.com/apikey) | Sim (chatbot real) |
| `CADU_MOCK` | — | Não (padrão: `false`) |

> O chatbot Cadu usa o modelo **`gemini-2.5-flash-lite`** (free tier do Google AI Studio).
> Se aparecer erro `429 / RESOURCE_EXHAUSTED (limit: 0)`, o modelo está sem quota grátis
> no seu projeto — troque o modelo em `supabase/functions/cadu-chat/gemini.ts` ou habilite billing.

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

## Solução de problemas

### `supabase secrets set` pede access token ou seleção de projeto

Ao rodar `supabase secrets set --env-file .env.desenvolvimento` você pode ver:

```
Access token not provided. Supply an access token by running `supabase login`
or setting the SUPABASE_ACCESS_TOKEN environment variable.
```

e, depois de `supabase login`, o comando para em:

```
Select a project:
> nome-do-projeto (org: ..., region: ...)
```

**Causa:** `supabase secrets set` gerencia segredos do projeto **remoto (na nuvem)** —
por isso exige `supabase login` e um projeto linkado/selecionado.

**Solução:** no desenvolvimento **local você não precisa desse comando**. A Edge Function
recebe as variáveis do `.env.desenvolvimento` quando você a roda via `deno run` (veja
[Como rodar](#como-rodar-dia-a-dia)). Só use `supabase secrets set` para **deploy na nuvem**.

### `supabase functions serve` dá *Segmentation fault* (exit 139)

No macOS/Apple Silicon o container do edge-runtime do `supabase functions serve`
costuma crashar com `Segmentation fault`. **Solução:** rode a função direto com
`deno run` na porta `8000` (veja [Como rodar](#como-rodar-dia-a-dia)) — é o caminho
que o `make web` espera (`FUNCTIONS_URL=http://localhost:8000`).

### Chatbot não responde / mensagem some ao enviar

- Confirme que a Edge Function está rodando (`deno run ... index.ts`, na `:8000`) e que o `FUNCTIONS_URL` do `make web` aponta para ela.
- `API key not valid` → a `GEMINI_API_KEY` no `.env.desenvolvimento` está errada. As chaves do Google AI Studio começam com `AQ.` (as antigas começavam com `AIzaSy`).
- `429 RESOURCE_EXHAUSTED (limit: 0)` → o modelo está sem quota grátis no seu projeto; troque o modelo em `supabase/functions/cadu-chat/gemini.ts` (ex: `gemini-2.5-flash-lite`) ou habilite billing.
- Após editar a função ou o `.env`, **reinicie o processo `deno run`** para recarregar.

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
│   └── cadu-chat/             # Edge Function do chatbot (Deno + Gemini)
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
