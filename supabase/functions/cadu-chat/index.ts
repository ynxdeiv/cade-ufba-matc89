// Edge Function: cadu-chat
//
// Fluxo:
//   1. CORS preflight
//   2. Lê Authorization Bearer e valida JWT → 401 se inválido
//   3. Verifica rate limit (10/min) → 429 se excedido
//   4. Carrega histórico (últimas N mensagens) — janela curta
//   5. Roda handler (Anthropic real OU mock se ANTHROPIC_API_KEY
//      ausente ou CADU_MOCK=true)
//   6. Persiste mensagem do usuário e do assistente em chat_messages
//      (com eventos_referenciados quando houver tool use)
//   7. Retorna { resposta, eventos_referenciados }

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.4";

import { corsHeaders, handlePreflight } from "../_shared/cors.ts";
import { AnthropicHandler } from "./anthropic.ts";
import { MockHandler } from "./mock.ts";
import type {
  BuscarEventosParams,
  ChatHandler,
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

  // Cliente "como usuário" — usado para validar o JWT e para os
  // selects/inserts que devem respeitar RLS.
  const supaUser = createClient(SUPABASE_URL, SERVICE_ROLE, {
    global: { headers: { Authorization: `Bearer ${token}` } },
    auth: { persistSession: false },
  });

  // Cliente "admin" — usado apenas para chamar funções privadas
  // (verificar_rate_limit), que revogamos de authenticated/anon.
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
      {
        erro: "Muitas mensagens em pouco tempo. Aguarde 1 minuto.",
      },
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
  if (!mensagem) {
    return json({ erro: "mensagem é obrigatória" }, 400);
  }

  // Carrega o histórico do banco (mais antigo → mais novo)
  let historico: ChatTurn[] = body.historico ?? [];
  if (historico.length === 0) {
    const { data: hist } = await supaUser.rpc("listar_historico_chat", {
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

  // Handler — real se houver ANTHROPIC_API_KEY e CADU_MOCK != true
  const apiKey = Deno.env.get("ANTHROPIC_API_KEY");
  const forcarMock = Deno.env.get("CADU_MOCK") === "true";
  const handler: ChatHandler = !forcarMock && apiKey
    ? new AnthropicHandler(apiKey)
    : new MockHandler();
  console.log(JSON.stringify({
    tag: "cadu.handler",
    modo: handler instanceof AnthropicHandler ? "anthropic" : "mock",
  }));

  // Tool buscar_eventos — chama o RPC listar_eventos com o JWT do
  // usuário (respeita RLS de events).
  const buscarEventos = async (
    p: BuscarEventosParams,
  ): Promise<Evento[]> => {
    const { data, error } = await supaUser.rpc("listar_eventos", p);
    if (error) throw new Error(error.message);
    return (data ?? []) as Evento[];
  };

  let resposta;
  try {
    resposta = await handler.responder({
      mensagem,
      historico,
      buscarEventos,
      agora: new Date(),
    });
  } catch (e) {
    console.error("handler erro", e);
    return json(
      { erro: "Cadu teve um problema ao responder. Tente novamente." },
      500,
    );
  }

  // Persistência — user message + assistant message
  const linhas = [
    {
      user_id: user.id,
      role: "user",
      conteudo: mensagem,
      eventos_referenciados: null,
    },
    {
      user_id: user.id,
      role: "assistant",
      conteudo: resposta.resposta,
      eventos_referenciados:
        resposta.eventos_referenciados.length > 0
          ? resposta.eventos_referenciados
          : null,
    },
  ];
  const { error: insErr } = await supaUser.from("chat_messages").insert(linhas);
  if (insErr) {
    console.error("persist erro", insErr);
    // Não falha a resposta — usuário já recebeu o conteúdo.
  }

  return json(resposta, 200);
});

function json(payload: unknown, status: number): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, "content-type": "application/json" },
  });
}
