// Edge Function: cadu-chat
//
// Fluxo:
//   1. CORS preflight
//   2. Lê Authorization Bearer e valida JWT → 401 se inválido
//   3. Verifica rate limit (10/min) → 429 se excedido
//   4. Carrega histórico (últimas N mensagens)
//   5. Insere mensagem do usuário no banco
//   6. Roda GeminiHandler (real) ou MockHandler (se CADU_MOCK=true)
//   7. Retorna SSE stream:
//        data: {"text":"<chunk>"}   — fragmentos do texto
//        data: {"done":true,"eventos":[...]}  — fim, após salvar assistente

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.4";

import { corsHeaders, handlePreflight } from "../_shared/cors.ts";
import { GeminiHandler } from "./gemini.ts";
import { MockHandler } from "./mock.ts";
import type {
  BuscarEventosParams,
  ChatTurn,
  Evento,
  RequestBody,
} from "./types.ts";

const RATE_LIMIT_POR_MINUTO = 10;
const TAMANHO_HISTORICO = 12; // 6 turnos (user + assistant)

Deno.serve(async (req: Request) => {
  const preflight = handlePreflight(req);
  if (preflight) return preflight;

  if (req.method !== "POST") {
    return json({ erro: "Método não permitido" }, 405);
  }

  const authHeader = req.headers.get("Authorization") ?? "";
  const token = authHeader.replace(/^Bearer\s+/i, "");
  if (!token) {
    return json({ erro: "Autenticação obrigatória" }, 401);
  }

  const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
  const SERVICE_ROLE = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

  const supaUser = createClient(SUPABASE_URL, SERVICE_ROLE, {
    global: { headers: { Authorization: `Bearer ${token}` } },
    auth: { persistSession: false },
  });

  const supaAdmin = createClient(SUPABASE_URL, SERVICE_ROLE, {
    auth: { persistSession: false },
  });

  const { data: userData, error: userErr } = await supaUser.auth.getUser(token);
  if (userErr || !userData?.user) {
    return json({ erro: "Token inválido" }, 401);
  }
  const user = userData.user;

  // Rate limit
  const { data: dentroLimite, error: rlErr } = await supaAdmin.rpc(
    "verificar_rate_limit",
    { p_user: user.id, p_limite: RATE_LIMIT_POR_MINUTO },
  );
  if (rlErr) {
    console.error("rate_limit erro", rlErr);
    return json({ erro: "Falha ao verificar limite" }, 500);
  }
  if (dentroLimite === false) {
    return json(
      { erro: "Muitas mensagens em pouco tempo. Aguarde 1 minuto." },
      429,
    );
  }

  // Body
  let body: RequestBody;
  try {
    body = await req.json();
  } catch {
    return json({ erro: "Body JSON inválido" }, 400);
  }
  const mensagem = (body.mensagem ?? "").toString().trim();
  const conversationId = (body.conversation_id ?? "").toString().trim();
  if (!mensagem) return json({ erro: "mensagem é obrigatória" }, 400);
  if (!conversationId) return json({ erro: "conversation_id é obrigatório" }, 400);

  // Histórico
  let historico: ChatTurn[] = body.historico ?? [];
  if (historico.length === 0) {
    const { data: hist } = await supaUser.rpc("listar_historico_chat", {
      p_conversation_id: conversationId,
      p_limit: TAMANHO_HISTORICO,
    });
    if (Array.isArray(hist)) {
      historico = hist
        .slice()
        .reverse()
        .map((m: { role: string; conteudo: string }) => ({
          role: m.role as ChatTurn["role"],
          conteudo: m.conteudo,
        }));
    }
  }

  // Persiste mensagem do usuário antes de iniciar streaming
  const { error: userMsgErr } = await supaUser.from("chat_messages").insert({
    user_id: user.id,
    conversation_id: conversationId,
    role: "user",
    conteudo: mensagem,
  });
  if (userMsgErr) {
    console.error("persist user msg erro", userMsgErr);
  }

  // Handler — Gemini real ou Mock
  const geminiKey = Deno.env.get("GEMINI_API_KEY");
  const forcarMock = Deno.env.get("CADU_MOCK") === "true";

  const buscarEventos = async (p: BuscarEventosParams): Promise<Evento[]> => {
    const { data, error } = await supaUser.rpc("listar_eventos", p);
    if (error) throw new Error(error.message);
    return (data ?? []) as Evento[];
  };

  // Mock path — retorna JSON simples (sem SSE)
  if (forcarMock || !geminiKey) {
    console.log(JSON.stringify({ tag: "cadu.handler", modo: "mock" }));
    const mock = new MockHandler();
    const resposta = await mock.responder({
      mensagem,
      historico,
      buscarEventos,
      agora: new Date(),
    });
    await supaUser.from("chat_messages").insert({
      user_id: user.id,
      conversation_id: conversationId,
      role: "assistant",
      conteudo: resposta.resposta,
      eventos_referenciados: resposta.eventos_referenciados.length > 0
        ? resposta.eventos_referenciados
        : null,
    });
    return json(resposta, 200);
  }

  console.log(JSON.stringify({ tag: "cadu.handler", modo: "gemini" }));

  const handler = new GeminiHandler(geminiKey);
  let geminiResult;
  try {
    geminiResult = await handler.stream({
      mensagem,
      historico,
      buscarEventos,
      agora: new Date(),
      onComplete: async (fullText: string, eventIds: string[]) => {
        const { error: asstErr } = await supaUser.from("chat_messages").insert({
          user_id: user.id,
          conversation_id: conversationId,
          role: "assistant",
          conteudo: fullText,
          eventos_referenciados: eventIds.length > 0 ? eventIds : null,
        });
        if (asstErr) console.error("persist assistant msg erro", asstErr);
      },
    });
  } catch (e) {
    console.error("gemini handler erro", e);
    return json({ erro: "Cadu teve um problema ao responder. Tente novamente." }, 500);
  }

  return new Response(geminiResult.stream, {
    status: 200,
    headers: {
      ...corsHeaders,
      "Content-Type": "text/event-stream",
      "Cache-Control": "no-cache",
      "X-Accel-Buffering": "no",
    },
  });
});

function json(payload: unknown, status: number): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, "content-type": "application/json" },
  });
}
