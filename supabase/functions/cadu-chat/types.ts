// Tipos compartilhados entre o handler real (Anthropic) e o handler
// mock. Mantemos enxuto para casar com a tool buscar_eventos e a
// resposta ao Flutter.

export type ChatRole = "user" | "assistant";

export interface ChatTurn {
  role: ChatRole;
  conteudo: string;
}

export interface RequestBody {
  mensagem: string;
  historico?: ChatTurn[];
}

export interface ResponseBody {
  resposta: string;
  eventos_referenciados: string[];
}

export interface BuscarEventosParams {
  p_inicio: string; // ISO timestamp
  p_fim: string;    // ISO timestamp
  p_categoria?: string;
  p_unidade?: string;
  p_busca?: string;
  p_tem_certificado?: boolean;
  p_limit?: number;
  p_offset?: number;
}

export interface Evento {
  id: string;
  titulo: string;
  descricao: string | null;
  inicio: string;
  fim: string | null;
  local: string | null;
  responsavel: string | null;
  carga_horaria: string | null;
  tem_certificado: boolean;
  categoria: string | null;
  unidade: string | null;
  capacidade: number | null;
  link_externo: string | null;
}

// O handler abstrato — implementado pelo real (Anthropic) ou mock.
export interface ChatHandler {
  responder(args: {
    mensagem: string;
    historico: ChatTurn[];
    buscarEventos: (p: BuscarEventosParams) => Promise<Evento[]>;
    agora: Date;
  }): Promise<ResponseBody>;
}
