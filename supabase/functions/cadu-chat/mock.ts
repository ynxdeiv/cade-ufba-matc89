// Handler mock — usado enquanto o LLM real não está configurado
// (ANTHROPIC_API_KEY ausente ou CADU_MOCK=true).
//
// Faz parsing simples da mensagem em pt-BR (palavras-chave de
// período + categoria + tem_certificado), chama `listar_eventos` no
// banco real e formata a resposta como o Cadu faria — mantendo o
// contrato (`resposta`, `eventos_referenciados`) idêntico ao real.

import type {
  BuscarEventosParams,
  ChatHandler,
  ChatTurn,
  Evento,
  ResponseBody,
} from "./types.ts";

interface Janela {
  inicio: Date;
  fim: Date;
  rotulo: string;
}

export class MockHandler implements ChatHandler {
  async responder(args: {
    mensagem: string;
    historico: ChatTurn[];
    buscarEventos: (p: BuscarEventosParams) => Promise<Evento[]>;
    agora: Date;
  }): Promise<ResponseBody> {
    const { mensagem, buscarEventos, agora } = args;
    const msg = mensagem.toLowerCase();

    const janela = extrairJanela(msg, agora);
    const categoria = extrairCategoria(msg);
    const unidade = extrairUnidade(msg);
    const certificado = msg.includes("certificado") || msg.includes("certifica");
    const busca = extrairBusca(msg);

    const params: BuscarEventosParams = {
      p_inicio: janela.inicio.toISOString(),
      p_fim: janela.fim.toISOString(),
      ...(categoria ? { p_categoria: categoria } : {}),
      ...(unidade ? { p_unidade: unidade } : {}),
      ...(certificado ? { p_tem_certificado: true } : {}),
      ...(busca ? { p_busca: busca } : {}),
      p_limit: 5,
    };

    console.log(
      JSON.stringify({ tag: "cadu.mock.tool_call", params }),
    );

    let eventos = await buscarEventos(params);

    // Fallback: se a busca textual filtrou demais, tenta sem ela
    // (o LLM real raciocinaria sobre o resultado e re-perguntaria).
    if (eventos.length === 0 && params.p_busca) {
      const { p_busca: _ignored, ...semBusca } = params;
      console.log(
        JSON.stringify({ tag: "cadu.mock.retry_sem_busca", params: semBusca }),
      );
      eventos = await buscarEventos(semBusca);
    }

    // Simula o log de cache hit do real para que os critérios de
    // observabilidade funcionem no smoke test.
    console.log(
      JSON.stringify({
        tag: "cadu.mock.usage",
        cache_read_input_tokens: 0,
        cache_creation_input_tokens: 0,
      }),
    );

    return {
      resposta: formatarResposta(eventos, janela, categoria),
      eventos_referenciados: eventos.map((e) => e.id),
    };
  }
}

// ------------------------------------------------------------------
// Heurística de período em pt-BR
// ------------------------------------------------------------------

function extrairJanela(msg: string, agora: Date): Janela {
  const hoje = startOfDay(agora);

  // \b não funciona bem com caracteres não-ASCII (ã, ê). Usamos
  // matches simples sem boundary — em pt-BR os termos aqui são
  // suficientemente distintivos.
  if (/hoje/.test(msg)) {
    return { inicio: hoje, fim: addDays(hoje, 1), rotulo: "hoje" };
  }
  if (/amanh[ãa]/.test(msg)) {
    const i = addDays(hoje, 1);
    return { inicio: i, fim: addDays(i, 1), rotulo: "amanhã" };
  }
  if (/semana que vem|pr[óo]xima semana/.test(msg)) {
    const i = addDays(hoje, 7);
    return { inicio: i, fim: addDays(i, 7), rotulo: "semana que vem" };
  }
  if (/esta semana|nesta semana/.test(msg)) {
    return { inicio: hoje, fim: addDays(hoje, 7), rotulo: "esta semana" };
  }
  if (/pr[óo]ximo m[êe]s/.test(msg)) {
    const i = addDays(hoje, 30);
    return { inicio: i, fim: addDays(i, 30), rotulo: "próximo mês" };
  }
  if (/este m[êe]s|neste m[êe]s/.test(msg)) {
    return { inicio: hoje, fim: addDays(hoje, 30), rotulo: "este mês" };
  }
  // Default: próximos 14 dias
  return { inicio: hoje, fim: addDays(hoje, 14), rotulo: "próximos 14 dias" };
}

function startOfDay(d: Date): Date {
  return new Date(Date.UTC(
    d.getUTCFullYear(),
    d.getUTCMonth(),
    d.getUTCDate(),
    0, 0, 0, 0,
  ));
}

function addDays(d: Date, n: number): Date {
  const out = new Date(d);
  out.setUTCDate(out.getUTCDate() + n);
  return out;
}

// ------------------------------------------------------------------
// Heurística de categoria, unidade e busca textual
// ------------------------------------------------------------------

function extrairCategoria(msg: string): string | null {
  if (/\bpalestra\b|palestras/.test(msg)) return "palestra";
  if (/\bminicurso\b|minicursos|curso/.test(msg)) return "minicurso";
  if (/congresso|semin[áa]rio|encontro/.test(msg)) return "congresso";
  if (/\bdefesa\b|defesas/.test(msg)) return "defesa";
  if (/cultural|cinema|m[úu]sica|sarau|expos/.test(msg)) return "cultural";
  return null;
}

function extrairUnidade(msg: string): string | null {
  const mapa: Array<[RegExp, string]> = [
    [/\bime\b|matem[áa]tica e estat/, "IME"],
    [/\bic\b|instituto de computa[çc]/, "IC"],
    [/\bfaced\b|educa[çc][ãa]o/, "FACED"],
    [/\bihac\b|humanidades, artes/, "IHAC"],
    [/\bics\b|ci[êe]ncias da sa[úu]de/, "ICS"],
    [/\bigeo\b|geoci[êe]ncias/, "IGEO"],
    [/\bfaufba\b|arquitetura/, "FAUFBA"],
    [/escola polit[ée]cnica|engenharia/, "Escola Politécnica"],
    [/reitoria/, "Reitoria"],
  ];
  for (const [re, nome] of mapa) {
    if (re.test(msg)) return nome;
  }
  return null;
}

function extrairBusca(msg: string): string | null {
  // Regex conservador — só ativa quando o termo completo aparece, para
  // evitar acionar busca textual por acrônimos curtos (que com o
  // threshold default do pg_trgm derrubariam todos os resultados).
  const termos: Array<[RegExp, string]> = [
    [/intelig[êe]ncia artificial/, "Inteligência Artificial"],
    [/banco de dados|postgres/, "Banco de Dados"],
    [/flutter/, "Flutter"],
    [/blockchain/, "blockchain"],
    [/lgpd|privacidade/, "LGPD"],
  ];
  for (const [re, termo] of termos) {
    if (re.test(msg)) return termo;
  }
  return null;
}

// ------------------------------------------------------------------
// Formatação da resposta em pt-BR
// ------------------------------------------------------------------

function formatarResposta(
  eventos: Evento[],
  janela: Janela,
  categoria: string | null,
): string {
  if (eventos.length === 0) {
    const tipo = categoria ? `${categoria}s` : "eventos";
    return (
      `Não encontrei ${tipo} para ${janela.rotulo}. ` +
      "Quer tentar um período maior ou outra categoria?"
    );
  }

  const partes: string[] = [
    `Encontrei ${eventos.length} ${
      eventos.length === 1 ? "evento" : "eventos"
    } para ${janela.rotulo}:`,
    "",
  ];

  for (const e of eventos) {
    partes.push(`• **${e.titulo}**`);
    partes.push(`  📅 ${formatarData(e.inicio)}`);
    if (e.local) partes.push(`  📍 ${e.local}`);
    if (e.responsavel) partes.push(`  👤 ${e.responsavel}`);
    if (e.carga_horaria) {
      partes.push(`  ⏱ Carga horária: ${formatarCarga(e.carga_horaria)}`);
    }
    if (e.tem_certificado) partes.push("  🏅 Emite certificado");
    partes.push("");
  }

  partes.push(
    "Quer adicionar algum à sua agenda? Use o botão no card do evento.",
  );
  return partes.join("\n").trim();
}

function formatarData(iso: string): string {
  const d = new Date(iso);
  const dia = String(d.getUTCDate()).padStart(2, "0");
  const meses = [
    "jan", "fev", "mar", "abr", "mai", "jun",
    "jul", "ago", "set", "out", "nov", "dez",
  ];
  const mes = meses[d.getUTCMonth()];
  const hora = String(d.getUTCHours()).padStart(2, "0");
  const min = String(d.getUTCMinutes()).padStart(2, "0");
  return `${dia}/${mes} às ${hora}:${min}`;
}

function formatarCarga(intervalo: string): string {
  // Postgres serializa interval como "HH:MM:SS" ou "X hours".
  return intervalo.replace(/:00$/, "").trim();
}
