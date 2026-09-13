#!/usr/bin/env bash
# Genera extension/omnifocus-dark.css a partir de omnifocus-dark.user.css y deja
# la version del manifest igual a @version.
#
# El .user.css es el original: Stylus necesita el encabezado UserCSS y el
# @-moz-document. Chromium no entiende @-moz-document (ignora el bloque entero),
# asi que el adaptador es esa misma hoja, desempaquetada, sin JavaScript.
#
#   bash scripts/sincronizar-extension.sh          # escribe
#   bash scripts/sincronizar-extension.sh --check  # no escribe; falla si hay desfase

# Git Bash en Windows: segun la instalacion, el PATH heredado puede no incluir
# /usr/bin, y ahi faltan dirname, mktemp, cp y rm. Se antepone solo si hace falta,
# para no alterar precedencias en Linux ni en macOS, donde ya estan resueltas.
command -v dirname >/dev/null 2>&1 || { PATH="/usr/bin:/mingw64/bin:$PATH"; export PATH; }

set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

src='omnifocus-dark.user.css'
css_destino='extension/omnifocus-dark.css'
manifest='extension/manifest.json'

[ -f "$src" ] || { echo "ERROR: no existe $src"; exit 1; }
[ -f "$manifest" ] || { echo "ERROR: no existe $manifest"; exit 1; }

check=0
[ "${1:-}" = '--check' ] && check=1

version=$(sed -n 's/^@version[[:space:]]*//p' "$src" | head -1 | tr -d '\r')
[ -n "$version" ] || { echo "ERROR: no se pudo leer @version de $src"; exit 1; }

generar_css() {
  cat <<EOF
/*
 * GENERADO — no editar a mano.
 * Fuente: omnifocus-dark.user.css
 * Regenerar: bash scripts/sincronizar-extension.sh
 *
 * Hoja inyectada por la extension Chromium (Manifest V3) como content_script
 * CSS. No hay JavaScript. El original para Stylus es omnifocus-dark.user.css.
 * version ${version}
 */
EOF

  awk '
    /^==\/UserStyle==/ { after_header=1; next }
    after_header && /^@-moz-document / { exit }
    after_header { print }
  ' "$src"

  awk '
    BEGIN { grab=0; n=0 }
    /^@-moz-document / { grab=1; next }
    grab { lines[++n] = $0 }
    END {
      while (n > 0 && lines[n] ~ /^[[:space:]]*$/) n--
      if (n > 0 && lines[n] ~ /^}[[:space:]]*$/) n--
      while (n > 0 && lines[n] ~ /^[[:space:]]*$/) n--
      for (i = 1; i <= n; i++) {
        line = lines[i]
        if (substr(line, 1, 2) == "  ") line = substr(line, 3)
        print line
      }
      if (n > 0) print ""
    }
  ' "$src"
}

generar_manifest() {
  awk -v ver="$version" '
    /"version":/ {
      sub(/"version": "[^"]*"/, "\"version\": \"" ver "\"")
    }
    { print }
  ' "$manifest"
}

tmp_css=$(mktemp)
tmp_manifest=$(mktemp)
trap 'rm -f "$tmp_css" "$tmp_manifest"' EXIT

generar_css > "$tmp_css"
generar_manifest > "$tmp_manifest"

if [ "$check" -eq 1 ]; then
  errores=0
  if [ ! -f "$css_destino" ]; then
    echo "ERROR: falta $css_destino. Ejecuta: bash scripts/sincronizar-extension.sh"
    errores=1
  elif ! cmp -s "$tmp_css" "$css_destino"; then
    echo "ERROR: $css_destino no coincide con $src. Ejecuta: bash scripts/sincronizar-extension.sh"
    errores=1
  fi
  if ! cmp -s "$tmp_manifest" "$manifest"; then
    echo "ERROR: $manifest tiene version distinta de @version ($version). Ejecuta: bash scripts/sincronizar-extension.sh"
    errores=1
  fi
  [ "$errores" -eq 0 ] || exit 1
  echo "  ok     extension sincronizada con $src (@version $version)"
  exit 0
fi

mkdir -p extension
cp "$tmp_css" "$css_destino"
cp "$tmp_manifest" "$manifest"
echo "  escrito  $css_destino"
echo "  version  $manifest -> $version"
