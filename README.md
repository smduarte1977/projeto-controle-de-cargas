# Projeto de Controle de Cargas — Sayan Polaris

Site do controle de cargas e da ocupação do convés do MPSV Sayan Polaris.

- **Qualquer pessoa com o link** vê a tabela, o convés, o histórico e gera o PDF.
- **Usuários aprovados** (login próprio, sem conta do Claude) editam cargas, movimentações e próximas movimentações.
- **Administradores** fazem tudo isso e aprovam novos usuários (botão **Acessos**).
- A estrutura do site só muda por este repositório.

Arquivos:
- `index.html` — o site inteiro (mesmas funções do Deck Cargo Plan: tabela, filtros, convés em escala, PDF, PT/EN/NO, tema claro/escuro).
- `manifestos.html` — **Cargo Manifestos** (Granenergia → Sayan Polaris): lista, manifesto no layout do formulário real, contentor por TAG, linhas de materiais com PR/PO/item SAP/custo/peso, alertas, fluxo de status, recebimento por departamento, importação do Excel, impressão/PDF e Excel, rastreio por TAG. Lê as cargas do Deck para casar a TAG.
- `schema-manifestos.sql` — cria a tabela `manifestos` no mesmo Supabase (rode uma vez no SQL Editor). Sem ela, `manifestos.html` funciona em modo local (só no navegador).
- `config.js` — endereço e chave pública do banco Supabase.

Banco, backups, automação e instruções completas de configuração: repositório privado
`projeto-controle-de-cargas-dados` (README).

Domínio próprio: **Settings → Pages → Custom domain**.
