// Cliente Anthropic — Claude Sonnet 4.6 com prompt caching.
//
// O system prompt + a definição da tool são marcados com
// `cache_control: { type: 'ephemeral' }` para que conversas multi-turn
// reaproveitem o cache da Anthropic (5 min TTL) — reduzindo custo.
//
// Loop simples de tool use: enquanto o modelo pedir tool_use,
// executamos a tool e devolvemos o resultado em uma nova turn.

import { SYSTEM_PROMPT } from "./system_prompt.ts";
import type {
  BuscarEventosParams,
  ChatHandler,
  ChatTurn,
  Evento,
  ResponseBody,
} from "./types.ts";

const MODEL = "claude-sonnet-4-6";
const API_URL = "https://api.anthropic.com/v1/messages";
const MAX_TURNS = 6;

const TOOL_DEFINITION = {
  name: "buscar_eventos",
  description:
    "Consulta a base de eventos da UFBA filtrando por intervalo de " +
    "datas (obrigatório), categoria, unidade, busca textual ou " +
    "presença de certificado. Retorna lista de eventos com todos os " +
    "campos relevantes (título, data, local, responsável, carga " +
    "horária, certificado, unidade).",
  input_schema: {
    type: "object",
    properties: {
      p_inicio: {
        type: "string",
        format: "date-time",
        description: "Data/hora de início do intervalo (ISO 8601 UTC)",
      },
      p_fim: {
        type: "string",
        format: "date-time",
        description: "Data/hora de fim do intervalo (ISO 8601 UTC)",
      },
      p_categoria: {
        type: "string",
        enum: ["palestra", "minicurso", "congresso", "defesa", "cultural"],
      },
      p_unidade: {
        type: "string",
        description: "Nome da unidade da UFBA",
      },
      p_busca: {
        type: "string",
        description: "Termo livre para busca por similaridade textual",
      },
      p_tem_certificado: { type: "boolean" },
      p_limit: { type: "integer", default: 20 },
    },
    required: ["p_inicio", "p_fim"],
    cache_control: { type: "ephemeral" },
  },
  cache_control: { type: "ephemeral" },
};

export class AnthropicHandler implements ChatHandler {
  constructor(private readonly apiKey: string) {}

  async responder(args: {
    mensagem: string;
    historico: ChatTurn[];
    buscarEventos: (p: BuscarEventosParams) => Promise<Evento[]>;
    agora: Date;
  }): Promise<ResponseBody> {
    const { mensagem, historico, buscarEventos, agora } = args;

    const messages: Array<Record<string, unknown>> = [
      ...historico.map((t) => ({ role: t.role, content: t.conteudo })),
      { role: "user", content: mensagem },
    ];

    const eventosUsados = new Map<string, Evento>();

    for (let turn = 0; turn < MAX_TURNS; turn++) {
      const res = await fetch(API_URL, {
        method: "POST",
        headers: {
          "x-api-key": this.apiKey,
          "anthropic-version": "2023-06-01",
          "content-type": "application/json",
        },
        body: JSON.stringify({
          model: MODEL,
          max_tokens: 1024,
          system: [
            {
              type: "text",
              text: `${SYSTEM_PROMPT}\n\nData/hora atual: ${agora.toISOString()}`,
              cache_control: { type: "ephemeral" },
            },
          ],
          tools: [TOOL_DEFINITION],
          messages,
        }),
      });

      if (!res.ok) {
        const body = await res.text();
        throw new Error(`Anthropic ${res.status}: ${body}`);
      }

      const data = await res.json();
      logCacheMetrics(data?.usage);

      const blocks: Array<{ type: string; [k: string]: unknown }> =
        data?.content ?? [];

      // Se há tool_use, processa cada um e re-pergunta.
      const toolUses = blocks.filter((b) => b.type === "tool_use");
      if (toolUses.length === 0) {
        const texto = blocks
          .filter((b) => b.type === "text")
          .map((b) => b.text as string)
          .join("\n")
          .trim();
        return {
          resposta: texto,
          eventos_referenciados: Array.from(eventosUsados.keys()),
        };
      }

      messages.push({ role: "assistant", content: blocks });
      const toolResults: Array<Record<string, unknown>> = [];
      for (const tu of toolUses) {
        const id = tu.id as string;
        const params = tu.input as BuscarEventosParams;
        try {
          const eventos = await buscarEventos(params);
          for (const e of eventos) eventosUsados.set(e.id, e);
          toolResults.push({
            type: "tool_result",
            tool_use_id: id,
            content: JSON.stringify(eventos),
          });
        } catch (e) {
          toolResults.push({
            type: "tool_result",
            tool_use_id: id,
            is_error: true,
            content: String(e),
          });
        }
      }
      messages.push({ role: "user", content: toolResults });
    }

    throw new Error("Loop de tool use excedeu MAX_TURNS");
  }
}

function logCacheMetrics(usage: Record<string, number> | undefined) {
  if (!usage) return;
  console.log(
    JSON.stringify({
      tag: "cadu.anthropic.usage",
      input_tokens: usage.input_tokens ?? 0,
      output_tokens: usage.output_tokens ?? 0,
      cache_creation_input_tokens: usage.cache_creation_input_tokens ?? 0,
      cache_read_input_tokens: usage.cache_read_input_tokens ?? 0,
    }),
  );
}
