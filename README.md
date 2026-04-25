# Cade UFBA

App universitario para a UFBA.

## Pre-requisitos

- Flutter 3.22+
- Dart 3.4+

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
# 1. Inicialize o projeto Flutter (primeira vez)
flutter create . --project-name cade_ufba --org com.ufba --platforms android,ios,web

# 2. Instale as dependencias
flutter pub get

# 3. Rode o app
flutter run
```

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
