-- BE-003: RPC listar_eventos
-- Busca textual com pg_trgm (índice GIN sobre titulo || ' ' || descricao)
-- e filtros opcionais por categoria, unidade, certificado e paginação.

create extension if not exists pg_trgm with schema extensions;

-- Índice GIN para busca por similaridade. Expressão é a mesma usada pela
-- função abaixo, requisito para o planner reaproveitar o índice.
create index if not exists events_busca_trgm_idx
  on public.events
  using gin ((titulo || ' ' || coalesce(descricao, '')) extensions.gin_trgm_ops);

-- search_path vazio + nomes totalmente qualificados (best practice
-- Supabase: evita o advisor function_search_path_mutable).
create or replace function public.listar_eventos(
  p_inicio timestamptz,
  p_fim timestamptz,
  p_categoria text default null,
  p_unidade text default null,
  p_busca text default null,
  p_tem_certificado boolean default null,
  p_limit integer default 20,
  p_offset integer default 0
)
returns setof public.events
language sql
stable
set search_path = ''
as $$
  select e.*
  from public.events e
  where e.inicio >= p_inicio
    and e.inicio <= p_fim
    and (p_categoria is null or e.categoria = p_categoria)
    and (p_unidade is null or e.unidade = p_unidade)
    and (p_tem_certificado is null or e.tem_certificado = p_tem_certificado)
    and (
      p_busca is null
      or (e.titulo || ' ' || coalesce(e.descricao, ''))
           operator(extensions.%) p_busca
    )
  order by e.inicio asc, e.id asc
  limit p_limit
  offset p_offset
$$;

grant execute on function public.listar_eventos(
  timestamptz, timestamptz, text, text, text, boolean, integer, integer
) to authenticated, anon;
