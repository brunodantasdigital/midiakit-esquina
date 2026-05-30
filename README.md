# Esquina Digital — Gerador de Mídia Kit

Ferramenta web estática para geração personalizada de especificações de formatos digitais por plataforma, com exportação em PDF e planilha de briefing de produção.

---

## O que é

Um único arquivo HTML autocontido que substitui o envio manual do PPTX de mídia kit. O usuário entra, informa o nome do cliente, seleciona as plataformas e formatos desejados, e exporta um PDF personalizado + uma planilha XLSX de controle de produção de criativos.

---

## Arquitetura

```
midiakit-esquina.html          ← arquivo único, sem dependências locais
│
├── Intro animada              ← loader 0→100%, iris-close, campo de cliente
├── Seletor em 2 camadas
│   ├── Chips de plataforma    ← 10 plataformas, ativam sub-painel
│   └── Sub-painel de formatos ← pills por plataforma, pré-selecionados
├── Specs dinâmicas            ← filtradas por seleção, 26 blocos
├── Exportar PDF               ← window.print() com print CSS dedicado
└── Exportar Planilha          ← XLSX (SheetJS CDN) ou CSV fallback
```

**Plataformas cobertas:** Google Ads (Search · Display Gráfico · Display Responsivo · Demand Gen · PMAX) · YouTube (4 formatos) · Meta Ads (Card · Carrossel · Vídeo) · TikTok · LinkedIn (3 formatos) · Spotify (Áudio · Vídeo) · X/Twitter · Kwai · Programática (GloboPlay · Netflix · Disney+ · TV Conectada · Banner · Vídeo · Áudio · Native Ads) · Push Notification

---

## Features

### Seleção inteligente
- Chips no topo: clicar ativa a plataforma e pré-seleciona todos os seus formatos
- Sub-painel deslizante: permite refinar quais formatos incluir
- Plataformas sem sub-formatos (TikTok, X, Kwai, Push) ativam direto

### Exportar PDF
- `window.print()` com CSS de impressão dedicado
- Cabeçalho com logo Esquina, nome do cliente e data
- Grid 2 colunas, cores preservadas, `break-inside: avoid` por bloco
- Nenhum card quebra entre páginas

### Exportar Planilha (Briefing de Produção)
- **Primário:** XLSX via SheetJS com cabeçalho Esquina, células mescladas, larguras de coluna otimizadas
- **Fallback automático:** CSV com BOM UTF-8 (abre corretamente no Excel) se CDN não carregar
- Colunas: Plataforma · Formato · Criativo · Especificação · Valor · Obs. Técnica · Nome do Arquivo · Responsável · Prazo de Entrega · Status · Aprovado
- Status pré-preenchido como "Pendente" e Aprovado como "Não"
- Nome do arquivo: `checklist-midiakit-[cliente]-[data].xlsx`

### Exportar PDF + Planilha
- Botão único que baixa o XLSX/CSV automaticamente e em seguida abre o diálogo de impressão

---

## Tecnologias

| Tecnologia | Uso |
|---|---|
| HTML5 / CSS3 / JavaScript vanilla | Base do projeto |
| Google Fonts (Inter) | Tipografia |
| SheetJS (CDN cdnjs) | Geração de XLSX |
| CSS `backdrop-filter` | Glassmorphism |
| CSS `clip-path` | Animação iris-close da intro |
| CSS `@media print` | Layout do PDF |

Sem frameworks, sem build step, sem servidor. Deploy direto como arquivo estático.

---

## Deploy no Netlify

### Estrutura mínima necessária
```
midiakit-esquina/
├── index.html          ← renomear midiakit-esquina.html para index.html
└── netlify.toml
```

### netlify.toml
```toml
[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-Content-Type-Options = "nosniff"
    Cache-Control = "public, max-age=3600"
```

### Deploy via Netlify CLI
```bash
npm install -g netlify-cli
netlify login
netlify deploy --prod --dir=.
```

---

## Subir no GitHub

```bash
# Na pasta do projeto
git init
git add .
git commit -m "feat: gerador de mídia kit Esquina Digital"
git branch -M main
git remote add origin https://github.com/SEU_USUARIO/midiakit-esquina.git
git push -u origin main
```

Depois conectar o repositório no painel do Netlify (New site from Git → GitHub → selecionar repo) para deploy automático a cada push.

---

## Prompt exato para o Claude Code

Cole o texto abaixo diretamente no Claude Code para ele preparar o repositório e fazer o deploy:

```
Tenho um arquivo HTML chamado `midiakit-esquina.html` na pasta atual.
Quero preparar esse projeto para deploy no Netlify como site estático.

Faça o seguinte:
1. Crie uma pasta chamada `midiakit-esquina/`
2. Copie o arquivo `midiakit-esquina.html` para dentro dela como `index.html`
3. Crie o arquivo `netlify.toml` com headers de segurança e cache de 1 hora
4. Inicialize um repositório Git nessa pasta
5. Faça o primeiro commit com a mensagem "feat: gerador de mídia kit Esquina Digital"
6. Me diga o comando exato para conectar ao GitHub e fazer o push

Não instale nada ainda, só prepare os arquivos e me dê as instruções de deploy.
```

---

## Manutenção

Para atualizar specs de uma plataforma, busque no arquivo pela constante `specsData` e localize a chave correspondente (ex: `'g-pmax'`, `'m-video'`, `'p-globoplay'`). Cada entrada tem `title`, `cards[]`, e dentro de cada card: `groups[]` com arrays `[label, valor]`.

Para adicionar uma nova plataforma: acrescente o chip no HTML, uma entrada em `PLATFORMS[]` no JS, os blocos de spec em `specsData`, e as linhas de checklist em `xlsxData`.
