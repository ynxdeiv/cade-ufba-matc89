Documento de Requisitos de Software — Cadê UFBA
1. Visão geral
Aplicativo móvel multiplataforma (Android, iOS e Web) que centraliza informações sobre eventos da UFBA — palestras, atividades complementares e eventos diversos — permitindo busca via chatbot, visualização em calendário e gerenciamento de agenda pessoal. Desenvolvido em Flutter/Dart com Supabase como backend principal e Hive como armazenamento local.
Observação importante: o PDF menciona Firebase e SQLite, mas o README adota Supabase e Hive. Vou seguir o README, que é o mais recente. Vale alinhar isso com a equipe e atualizar o PDF.

2. Requisitos do documento original (extraídos do PDF)
Estes são os requisitos explicitamente descritos no documento de origem:
RF-01 — Cadastro de usuários: novos usuários devem poder criar conta informando nome, e-mail e senha.
RF-02 — Login/Autenticação: usuários já cadastrados devem autenticar-se com e-mail e senha.
RF-03 — Chatbot Cadu: usuário autenticado interage com o chatbot para buscar atividades e eventos em determinado período, recebendo data, hora, local, responsável, carga horária e disponibilidade de certificado.
RF-04 — Adicionar evento à agenda via chatbot: a partir da resposta do Cadu, o usuário pode salvar o evento como compromisso na sua agenda.
RF-05 — Calendário de eventos: visualização em calendário dos dias com atividades, com destaque visual (cor diferente) para dias em que o usuário marcou presença.
RF-06 — Público-alvo: docentes, discentes e, quando aplicável, público externo.

3. Requisitos funcionais — Front-end (Flutter)
3.1 Autenticação e perfil
RF-FE-01 — Tela de cadastro: formulário com nome completo, e-mail institucional/pessoal, senha e confirmação de senha, com validação em tempo real (formato de e-mail, força de senha, campos obrigatórios).
RF-FE-02 — Tela de login: entrada de e-mail e senha, com opção "esqueci minha senha" e "manter conectado".
RF-FE-03 — Tela de perfil: exibição e edição dos dados do usuário (nome, e-mail, foto, vínculo com a UFBA — discente/docente/externo, curso/departamento).
RF-FE-04 — Logout: encerramento da sessão com limpeza dos dados sensíveis locais.
RF-FE-05 — Recuperação de senha: fluxo de redefinição via e-mail (sugerido, ausente no PDF).
3.2 Eventos
RF-FE-06 — Listagem de eventos: tela com lista paginada de eventos futuros, ordenados por data, com filtros por categoria, unidade da UFBA, data e disponibilidade de certificado (sugerido).
RF-FE-07 — Busca de eventos: campo de busca textual com filtros (sugerido).
RF-FE-08 — Detalhe do evento: tela exibindo título, descrição, data, hora, local, responsável, carga horária, disponibilidade de certificado, capacidade e link para inscrição quando aplicável.
RF-FE-09 — Compartilhamento de evento: opção de compartilhar o evento via apps nativos (sugerido).
3.3 Chatbot Cadu
RF-FE-10 — Interface de chat: tela de conversa com histórico, indicador de "digitando", suporte a mensagens longas e cards interativos de eventos dentro da conversa.
RF-FE-11 — Histórico de conversas: persistência local das últimas conversas do usuário (sugerido).
RF-FE-12 — Ação rápida "adicionar à agenda": botão dentro do card do evento na conversa para salvar diretamente.
RF-FE-13 — Sugestões de perguntas: chips com perguntas frequentes para iniciar a conversa (sugerido).
3.4 Agenda e calendário
RF-FE-14 — Calendário mensal: widget de calendário com marcação visual nos dias com eventos do usuário e dias com eventos disponíveis na UFBA (cor distinta para cada caso).
RF-FE-15 — Visão diária/semanal: alternância entre visão mensal, semanal e diária (sugerido).
RF-FE-16 — Remover evento da agenda: ação para remover compromissos salvos (sugerido).
RF-FE-17 — Sincronização com calendário nativo: integração opcional com Google Calendar e calendário do iOS (sugerido — alinhado ao calendar_service.dart previsto no README).
RF-FE-18 — Notificações de lembrete: push notification configurável (1 dia, 1 hora, 15 minutos antes do evento) (sugerido).
3.5 Geral e UX
RF-FE-19 — Tema claro e escuro: suporte aos dois modos respeitando configuração do sistema (sugerido).
RF-FE-20 — Onboarding: telas introdutórias na primeira abertura explicando funcionalidades (sugerido).
RF-FE-21 — Modo offline: exibição dos eventos da agenda e calendário pessoal mesmo sem conexão, via Hive (sugerido).
RF-FE-22 — Tratamento de erros: mensagens amigáveis para falhas de rede, autenticação inválida e indisponibilidade do backend.
RF-FE-23 — Acessibilidade: suporte a leitor de tela, escala de fonte e contraste mínimo WCAG AA (sugerido).

4. Requisitos funcionais — Back-end (Supabase + serviço de IA)
4.1 Autenticação e usuários
RF-BE-01 — Serviço de autenticação: registro, login, logout, refresh token e recuperação de senha via Supabase Auth.
RF-BE-02 — Persistência do perfil: tabela profiles ligada a auth.users (Supabase) com nome, vínculo, curso/departamento, foto.
RF-BE-03 — Validação de e-mail: confirmação por link enviado por e-mail no cadastro (sugerido).
RF-BE-04 — Row Level Security (RLS): políticas que garantam que cada usuário só leia/edite seus próprios dados (agenda, perfil, histórico de chat) (sugerido — essencial no Supabase).
4.2 Eventos
RF-BE-05 — CRUD de eventos: entidade events com campos id, título, descrição, data/hora início, data/hora fim, local, responsável, carga horária, tem_certificado, categoria, unidade UFBA, capacidade, link externo.
RF-BE-06 — Fonte de dados de eventos: definição de quem alimenta a base — administrador via painel? scraping de portais da UFBA? API institucional? (lacuna crítica no PDF — precisa ser decidido).
RF-BE-07 — Painel administrativo (opcional): interface web para gestores cadastrarem eventos (sugerido).
RF-BE-08 — Endpoint de listagem com filtros: consulta paginada por intervalo de datas, categoria, unidade, texto (sugerido).
4.3 Agenda do usuário
RF-BE-09 — Tabela user_events: relação N:N entre users e events indicando compromissos salvos, com timestamp de marcação e status (confirmado/cancelado).
RF-BE-10 — Endpoint de agenda do usuário: retorno dos eventos salvos por intervalo de datas.
4.4 Chatbot Cadu
RF-BE-11 — Serviço de IA (ai_service.dart): integração com LLM (Claude, OpenAI ou modelo open-source) recebendo a mensagem do usuário e contexto de eventos disponíveis, retornando resposta em linguagem natural.
RF-BE-12 — RAG sobre base de eventos: o serviço de IA deve consultar a tabela de eventos para fundamentar respostas — abordagem recomendada: function calling/tool use ou recuperação por busca semântica/textual sobre eventos próximos, evitando alucinações (sugerido).
RF-BE-13 — Persistência do histórico de chat: tabela chat_messages com user_id, role (user/assistant), conteúdo, timestamp, eventos referenciados (sugerido).
RF-BE-14 — Rate limiting do chatbot: limite de mensagens por usuário/minuto para controlar custos (sugerido).
RF-BE-15 — Gestão segura da chave da API de IA: chave da LLM não pode ficar no cliente; deve ficar em Edge Function/Function do Supabase (sugerido — segurança crítica).
4.5 Notificações
RF-BE-16 — Serviço de push: integração com Firebase Cloud Messaging ou OneSignal para envio de lembretes (sugerido).
RF-BE-17 — Job agendado: processo que dispara notificações no horário configurado pelo usuário antes do evento (sugerido).

5. Requisitos não funcionais (todos sugeridos — ausentes no PDF)
RNF-01 — Desempenho: tempo de resposta da listagem de eventos abaixo de 2s em 3G; resposta do chatbot abaixo de 5s.
RNF-02 — Disponibilidade: uptime esperado de 99% para o backend (limitado pelo plano do Supabase).
RNF-03 — Segurança: senhas armazenadas com hash (gerenciado pelo Supabase Auth); comunicação exclusivamente HTTPS; RLS ativo em todas as tabelas; chave da LLM nunca exposta ao cliente.
RNF-04 — Privacidade (LGPD): termo de consentimento no cadastro, política de privacidade, opção de exclusão da conta e dos dados.
RNF-05 — Compatibilidade: Android 8+ (API 26+), iOS 13+, navegadores modernos (Chrome, Safari, Edge nas duas últimas versões).
RNF-06 — Internacionalização: suporte inicial a português do Brasil; arquitetura preparada para inglês.
RNF-07 — Manutenibilidade: arquitetura Clean por feature (já adotada no README), cobertura mínima de testes de 60% para camada de domínio.
RNF-08 — Observabilidade: integração com ferramenta de monitoramento de erros (Sentry, Crashlytics) (sugerido).
RNF-09 — Tamanho do app: APK abaixo de 30 MB.