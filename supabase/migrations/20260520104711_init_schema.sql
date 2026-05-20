-- BE-001: schema base do Cadê UFBA
-- Tabelas: profiles, events, user_events, chat_messages

create extension if not exists "pgcrypto";

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  nome text,
  vinculo text check (vinculo in ('discente', 'docente', 'externo')),
  curso_departamento text,
  foto_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

create table public.events (
  id uuid primary key default gen_random_uuid(),
  titulo text not null,
  descricao text,
  inicio timestamptz not null,
  fim timestamptz,
  local text,
  responsavel text,
  carga_horaria interval,
  tem_certificado boolean not null default false,
  categoria text,
  unidade text,
  capacidade int,
  link_externo text,
  created_at timestamptz not null default now()
);

create index events_inicio_idx on public.events (inicio);
create index events_categoria_idx on public.events (categoria);
create index events_unidade_idx on public.events (unidade);

create table public.user_events (
  user_id uuid not null references public.profiles (id) on delete cascade,
  event_id uuid not null references public.events (id) on delete cascade,
  status text not null default 'confirmado' check (status in ('confirmado', 'cancelado')),
  marcado_em timestamptz not null default now(),
  primary key (user_id, event_id)
);

create index user_events_user_marcado_idx on public.user_events (user_id, marcado_em);

create table public.chat_messages (
  id bigserial primary key,
  user_id uuid not null references public.profiles (id) on delete cascade,
  role text not null check (role in ('user', 'assistant')),
  conteudo text not null,
  eventos_referenciados uuid[],
  created_at timestamptz not null default now()
);

create index chat_messages_user_created_idx on public.chat_messages (user_id, created_at);
