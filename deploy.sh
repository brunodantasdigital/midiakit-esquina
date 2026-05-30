#!/usr/bin/env bash
# deploy.sh — copia o arquivo fonte, injeta CSS mobile e publica
# Uso: ./deploy.sh "mensagem do commit"

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE="$REPO_DIR/../midiakit-esquina.html"
DEST="$REPO_DIR/index.html"
MSG="${1:-chore: atualiza index.html}"

# 1. Copiar arquivo fonte
cp "$SOURCE" "$DEST"
echo "✔ index.html copiado"

# 2. Injetar CSS mobile (antes do @media print)
MOBILE_CSS='/* MOBILE */
@media(max-width:600px){
  .site-header{padding:10px 16px}
  .hero{padding:40px 16px 24px}
  .hero h1{font-size:clamp(26px,7vw,38px)}
  .selector-section{padding:0 12px 32px}
  .chips-grid{grid-template-columns:repeat(3,1fr);gap:8px}
  .chip{padding:10px 6px 9px;gap:5px}
  .chip-name{font-size:10px}
  .actions-bar{flex-direction:column;align-items:stretch;gap:8px;padding:14px 14px}
  .actions-bar .count-label{text-align:center;font-size:13px}
  .actions-bar .btn{justify-content:center;padding:12px 10px;font-size:13px}
  .sub-panel-inner{padding:14px 14px}
  .intro-card{padding:32px 20px 28px;max-width:92vw}
  .intro-logo{width:180px}
}

/* PRINT */'

# Substituir "/* PRINT */" pelo bloco mobile + print
python3 - "$DEST" <<'PYEOF'
import sys
path = sys.argv[1]
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

MOBILE = """/* MOBILE */
@media(max-width:600px){
  .site-header{padding:10px 16px}
  .hero{padding:40px 16px 24px}
  .hero h1{font-size:clamp(26px,7vw,38px)}
  .selector-section{padding:0 12px 32px}
  .chips-grid{grid-template-columns:repeat(3,1fr);gap:8px}
  .chip{padding:10px 6px 9px;gap:5px}
  .chip-name{font-size:10px}
  .actions-bar{flex-direction:column;align-items:stretch;gap:8px;padding:14px 14px}
  .actions-bar .count-label{text-align:center;font-size:13px}
  .actions-bar .btn{justify-content:center;padding:12px 10px;font-size:13px}
  .sub-panel-inner{padding:14px 14px}
  .intro-card{padding:32px 20px 28px;max-width:92vw}
  .intro-logo{width:180px}
}

/* PRINT */"""

if '/* MOBILE */' in content:
    print('  CSS mobile já presente, nada a fazer.')
elif '/* PRINT */' in content:
    content = content.replace('/* PRINT */', MOBILE, 1)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print('  CSS mobile injetado.')
else:
    print('  AVISO: marcador /* PRINT */ não encontrado — verifique o arquivo.')
    sys.exit(1)
PYEOF

echo "✔ CSS mobile ok"

# 3. Commit e push
cd "$REPO_DIR"
git add index.html
git commit -m "$MSG"
git push
echo "✔ Git push feito"

# 4. Deploy Netlify
netlify deploy --dir=. --prod 2>&1 | grep -E '✔|🚀|Production URL|Error'
echo "✔ Deploy concluído"
