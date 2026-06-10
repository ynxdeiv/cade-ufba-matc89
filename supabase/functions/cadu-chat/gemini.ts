// Handler Gemini — gemini-2.0-flash com suporte a function calling e streaming SSE.
//
// Fluxo:
//   1. Loop de tool use com generateContent (não-streaming) até o modelo
//      parar de pedir tools (ou MAX_TURNS excedido).
//   2. Chamada final com streamGenerateContent para obter texto em streaming.
//   3. Retorna { stream: ReadableStream, eventIds: string[] }.
//      O ReadableStream emite eventos SSE no formato:
//        data: {"text":"<chunk>"}\n\n   — fragmento de texto
//        data: {"done":true,"eventos":["id1",...]}\n\n  — fim (após salvar no DB)

import { SYSTEM_PROMPT } from "./system_prompt.ts";
import type { BuscarEventosParams, ChatTurn, Evento } from "./types.ts";

const MODEL = "gemini-2.5-flash-lite";
const BASE_URL =
  "https://generativelanguage.googleapis.com/v1beta/models";
const MAX_TURNS = 6;

const BUSCAR_EVENTOS_DECLARATION = {
  name: "buscar_eventos",
  description:
    "Consulta a base de eventos da UFBA filtrando por intervalo de " +
    "datas (obrigatório), categoria, unidade, busca textual ou " +
    "presença de certificado. Retorna lista de eventos com todos os " +
    "campos relevantes.",
  parameters: {
    type: "object",
    properties: {
      p_inicio: {
        type: "string",
        description: "Data/hora de início do intervalo (ISO 8601 UTC)",
      },
      p_fim: {
        type: "string",
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
      p_limit: { type: "integer" },
    },
    required: ["p_inicio", "p_fim"],
  },
};

type GeminiPart =
  | { text: string }
  | { functionCall: { name: string; args: Record<string, unknown> } }
  | { functionResponse: { name: string; response: Record<string, unknown> } };

type GeminiContent = { role: "user" | "model"; parts: GeminiPart[] };

function buildContents(historico: ChatTurn[], mensagem: string): GeminiContent[] {
  const contents: GeminiContent[] = historico.map((t) => ({
    role: t.role === "user" ? "user" : "model",
    parts: [{ text: t.conteudo }],
  }));
  contents.push({ role: "user", parts: [{ text: mensagem }] });
  return contents;
}

async function callGenerate(
  apiKey: string,
  contents: GeminiContent[],
  systemInstruction: { parts: { text: string }[] },
  streaming: false,
): Promise<{ data: Record<string, unknown> }>;
async function callGenerate(
  apiKey: string,
  contents: GeminiContent[],
  systemInstruction: { parts: { text: string }[] },
  streaming: true,
): Promise<{ response: Response }>;
async function callGenerate(
  apiKey: string,
  contents: GeminiContent[],
  systemInstruction: { parts: { text: string }[] },
  streaming: boolean,
): Promise<{ data?: Record<string, unknown>; response?: Response }> {
  const endpoint = streaming
    ? `${BASE_URL}/${MODEL}:streamGenerateContent?key=${apiKey}&alt=sse`
    : `${BASE_URL}/${MODEL}:generateContent?key=${apiKey}`;

  const body: Record<string, unknown> = {
    system_instruction: systemInstruction,
    contents,
    ...(streaming ? {} : { tools: [{ function_declarations: [BUSCAR_EVENTOS_DECLARATION] }] }),
  };

  const res = await fetch(endpoint, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });

  if (!res.ok) {
    const txt = await res.text();
    throw new Error(`Gemini ${res.status}: ${txt}`);
  }

  if (streaming) return { response: res };

  const data = await res.json() as Record<string, unknown>;
  return { data };
}

export interface GeminiStreamResult {
  stream: ReadableStream<Uint8Array>;
  eventIds: string[];
}

export class GeminiHandler {
  constructor(private readonly apiKey: string) {}

  async stream(args: {
    mensagem: string;
    historico: ChatTurn[];
    buscarEventos: (p: BuscarEventosParams) => Promise<Evento[]>;
    agora: Date;
    onComplete: (fullText: string, eventIds: string[]) => Promise<void>;
  }): Promise<GeminiStreamResult> {
    const { mensagem, historico, buscarEventos, agora, onComplete } = args;

    const systemInstruction = {
      parts: [{
        text: `${SYSTEM_PROMPT}\n\nData/hora atual: ${agora.toISOString()}`,
      }],
    };

    const contents = buildContents(historico, mensagem);
    const eventosUsados = new Map<string, Evento>();

    // Loop de tool use (não-streaming)
    for (let turn = 0; turn < MAX_TURNS; turn++) {
      const { data } = await callGenerate(this.apiKey, contents, systemInstruction, false);

      const candidates = (data?.candidates as Array<Record<string, unknown>>) ?? [];
      const parts = ((candidates[0]?.content as Record<string, unknown>)?.parts as GeminiPart[]) ?? [];

      const functionCalls = parts.filter(
        (p): p is { functionCall: { name: string; args: Record<string, unknown> } } =>
          "functionCall" in p,
      );

      if (functionCalls.length === 0) break;

      // Adiciona resposta do modelo com function calls
      contents.push({ role: "model", parts });

      // Executa cada function call
      const toolResults: GeminiPart[] = [];
      for (const { functionCall: { name, args } } of functionCalls) {
        if (name === "buscar_eventos") {
          try {
            const eventos = await buscarEventos(args as BuscarEventosParams);
            for (const e of eventos) eventosUsados.set(e.id, e);
            toolResults.push({
              functionResponse: { name, response: { result: eventos } },
            });
          } catch (e) {
            toolResults.push({
              functionResponse: { name, response: { error: String(e) } },
            });
          }
        }
      }
      contents.push({ role: "user", parts: toolResults });
    }

    // Streaming da resposta final (sem tools)
    const { response: streamRes } = await callGenerate(
      this.apiKey,
      contents,
      systemInstruction,
      true,
    );

    const eventIds = Array.from(eventosUsados.keys());
    const encoder = new TextEncoder();
    const decoder = new TextDecoder();
    let fullText = "";
    let buffer = "";

    const transformStream = new TransformStream<Uint8Array, Uint8Array>({
      transform(chunk, controller) {
        buffer += decoder.decode(chunk, { stream: true });
        const lines = buffer.split("\n");
        buffer = lines.pop() ?? "";

        for (const line of lines) {
          if (!line.startsWith("data: ")) continue;
          const raw = line.slice(6).trim();
          if (!raw || raw === "[DONE]") continue;
          try {
            const json = JSON.parse(raw) as Record<string, unknown>;
            const candidates = (json.candidates as Array<Record<string, unknown>>) ?? [];
            const parts = ((candidates[0]?.content as Record<string, unknown>)?.parts as Array<Record<string, unknown>>) ?? [];
            for (const part of parts) {
              const text = part.text as string | undefined;
              if (text) {
                fullText += text;
                controller.enqueue(
                  encoder.encode(`data: ${JSON.stringify({ text })}\n\n`),
                );
              }
            }
          } catch {
            // ignora chunks malformados
          }
        }
      },
      async flush(controller) {
        // Salva no banco e emite evento de conclusão
        try {
          await onComplete(fullText, eventIds);
        } catch (e) {
          console.error("gemini.onComplete error", e);
        }
        controller.enqueue(
          encoder.encode(
            `data: ${JSON.stringify({ done: true, eventos: eventIds })}\n\n`,
          ),
        );
      },
    });

    return {
      stream: streamRes.body!.pipeThrough(transformStream),
      eventIds,
    };
  }
}
