#!/usr/bin/env bash
# Genera los adaptadores que otras herramientas cargan automaticamente.
#
# NO son copias de AGENTS.md: cada herramienta tiene su propia forma de importar un
# archivo externo, y usarla deja a AGENTS.md como unico original. Una copia se
# desincroniza; un import no puede.
#
#   bash scripts/sincronizar-adaptadores.sh claude cursor gemini
#
# Antes de crear el de Copilot: verifica si tu entorno ya lee AGENTS.md de forma
# nativa (los recientes lo hacen). Si lo lee, el adaptador solo duplica contexto.

# Git Bash en Windows: segun la instalacion, el PATH heredado puede no incluir
# /usr/bin, y ahi faltan dirname, mktemp, cp y rm. Se antepone solo si hace falta,
# para no alterar precedencias en Linux ni en macOS, donde ya estan resueltas.
command -v dirname >/dev/null 2>&1 || { PATH="/usr/bin:/mingw64/bin:$PATH"; export PATH; }

set -uo pipefail

cd "$(dirname "$0")/.." || exit 1
[ -f AGENTS.md ] || { echo 'ERROR: no existe AGENTS.md'; exit 1; }

crear() {
  destino="$1"
  mkdir -p "$(dirname "$destino")"
  cat > "$destino"
  echo "  creado  $destino"
}

[ $# -gt 0 ] || { echo 'Uso: bash scripts/sincronizar-adaptadores.sh [claude|gemini|cursor|copilot]...'; exit 1; }

for herramienta in "$@"; do
  case "$herramienta" in
    claude)
      crear CLAUDE.md <<'EOF'
@AGENTS.md
EOF
      ;;
    gemini)
      crear GEMINI.md <<'EOF'
@./AGENTS.md
EOF
      ;;
    cursor)
      # alwaysApply: true es obligatorio; sin el, la regla queda como manual y solo
      # se carga si alguien la invoca a mano.
      crear .cursor/rules/agents.mdc <<'EOF'
---
description: Instrucciones del proyecto
globs:
alwaysApply: true
---

@../../AGENTS.md
EOF
      ;;
    copilot)
      crear .github/copilot-instructions.md <<'EOF'
Segui integramente las instrucciones de AGENTS.md en la raiz del repositorio.
AGENTS.md es la fuente canonica: ante cualquier contradiccion, prevalece.
EOF
      ;;
    *)
      echo "ERROR: herramienta desconocida: $herramienta (claude|gemini|cursor|copilot)"
      exit 1
      ;;
  esac
done
