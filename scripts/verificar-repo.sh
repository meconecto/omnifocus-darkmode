#!/usr/bin/env bash
# Verificaciones del kit de contexto. Primer paso del comando `verify` del proyecto.
#
# En Windows NO se invoca con `bash scripts/verificar-repo.sh`: ahi `bash` resuelve a
# WSL. Usar `scripts\verificar-repo.cmd`, que localiza el bash de Git.

# Git Bash en Windows: segun la instalacion, el PATH heredado puede no incluir
# /usr/bin, y ahi faltan dirname, mktemp, cp y rm. Se antepone solo si hace falta,
# para no alterar precedencias en Linux ni en macOS, donde ya estan resueltas.
command -v dirname >/dev/null 2>&1 || { PATH="/usr/bin:/mingw64/bin:$PATH"; export PATH; }

set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

errores=0
avisos=0

err() { printf '  ERROR  %s\n' "$1"; errores=$((errores + 1)); }
adv() { printf '  aviso  %s\n' "$1"; avisos=$((avisos + 1)); }
sec() { printf '\n%s\n' "$1"; }

# Todos los archivos versionables, excluyendo dependencias y artefactos.
archivos_del_repo() {
  find . -type f \
    -not -path './.git/*' -not -path './node_modules/*' -not -path './.venv/*' \
    -not -path './venv/*' -not -path './dist/*' -not -path './build/*' \
    -not -path './target/*' -not -path './docs/_referencia/*' 2>/dev/null
}

archivos_markdown() {
  archivos_del_repo | grep '\.md$'
}

# --- 1. La inicialización terminó -------------------------------------------
sec 'Inicializacion'
pendiente=0
for f in INICIALIZAR.md ADOPTAR.md .inicializacion; do
  [ -e "$f" ] && { err "$f sigue presente: la inicializacion no se completo."; pendiente=1; }
done
[ "$pendiente" -eq 0 ] && echo '  ok     completada'

# --- 2. Archivos obligatorios -----------------------------------------------
sec 'Archivos obligatorios'
for f in AGENTS.md README.md docs/decisiones; do
  if [ -e "$f" ]; then echo "  ok     $f"; else err "falta $f"; fi
done

# --- 3. Placeholders sin completar ------------------------------------------
# Se revisa TODO el repo, no solo la documentación: un workflow de CI o un script
# copiado a medio completar rompe igual que un AGENTS.md sin llenar.
#
# La marca lleva un prefijo propio a proposito. Un patron generico de dobles llaves
# choca con sintaxis legitima que sobrevive a la inicializacion: las expresiones de
# GitHub Actions, y las plantillas Jinja / Handlebars / Go de cualquier proyecto.
# Ojo: este archivo no puede contener la marca entera o se autodetecta; por eso se
# arma por partes.
sec 'Placeholders'
marca="@@PLANTILLA""(:[^@]+)?@@"
pendientes=$(archivos_del_repo | xargs grep -lE "$marca" 2>/dev/null \
  | grep -v '^\./docs/decisiones/0000-plantilla\.md$' \
  | grep -v '/PLANTILLA-TAREA\.md$')
if [ -n "$pendientes" ]; then
  while IFS= read -r f; do err "$f tiene placeholders sin completar"; done <<< "$pendientes"
else
  echo '  ok     ninguno'
fi

# --- 4. Presupuesto de contexto de AGENTS.md --------------------------------
sec 'Presupuesto de AGENTS.md'
while IFS= read -r archivo; do
  n=$(grep -cve '^\s*$' "$archivo")
  if   [ "$n" -gt 100 ]; then err "$archivo: $n lineas (maximo 100). Extrae a docs/."
  elif [ "$n" -gt 60 ];  then adv "$archivo: $n lineas (objetivo 60)."
  else echo "  ok     $archivo: $n lineas"; fi
done < <(archivos_del_repo | grep '/AGENTS\.md$\|^\./AGENTS\.md$')

# --- 5. El comando de verificación está declarado y resuelve --------------
# Alcance real: se comprueba que el comando este declarado, que su ejecutable exista
# y que el destino este definido (script/target/receta). NO se ejecuta: `verify`
# invoca a este script, asi que ejecutarlo aca seria recursivo. La prueba definitiva
# de que `verify` funciona es correrlo.
sec 'Comando de verificacion'
if [ -f AGENTS.md ]; then
  cmd=$(sed -n 's/.*<!--[[:space:]]*verify:[[:space:]]*\(.*\)-->.*/\1/p' AGENTS.md | head -1 | sed 's/[[:space:]]*$//')
  if [ -z "$cmd" ]; then
    err 'AGENTS.md no declara el comando: falta la linea <!-- verify: ... -->'
  else
    bin=$(printf '%s' "$cmd" | awk '{print $1}')
    arg1=$(printf '%s' "$cmd" | awk '{print $2}')
    arg2=$(printf '%s' "$cmd" | awk '{print $3}')
    if ! command -v "$bin" >/dev/null 2>&1 && [ ! -e "$bin" ]; then
      err "el ejecutable declarado no existe: '$bin' no esta en el PATH"
    else
      destino_ok=''
      case "$bin $arg1" in
        'npm run'|'pnpm run'|'yarn run'|'bun run')
          if [ ! -f package.json ]; then
            err "el comando declarado es '$cmd' pero no existe package.json"
          elif grep -q "\"$arg2\"[[:space:]]*:" package.json; then
            destino_ok="script '$arg2' definido en package.json"
          else
            err "package.json no define el script '$arg2'"
          fi ;;
        'make '*)
          if [ ! -f Makefile ] && [ ! -f makefile ]; then
            err "el comando declarado es '$cmd' pero no existe Makefile"
          elif grep -qs "^$arg1:" Makefile makefile; then
            destino_ok="target '$arg1' definido en Makefile"
          else
            err "el Makefile no define el target '$arg1'"
          fi ;;
        'just '*)
          if [ ! -f justfile ] && [ ! -f Justfile ]; then
            err "el comando declarado es '$cmd' pero no existe justfile"
          elif grep -qs "^$arg1:" justfile Justfile; then
            destino_ok="receta '$arg1' definida en justfile"
          else
            err "el justfile no define la receta '$arg1'"
          fi ;;
        *)
          if [ -n "$arg1" ] && [ -e "$arg1" ]; then destino_ok="ejecuta $arg1"
          elif [ -n "$arg1" ] && printf '%s' "$arg1" | grep -q '[/\\.]'; then
            err "el comando apunta a '$arg1', que no existe"
          else destino_ok='ejecutable presente'
          fi ;;
      esac
      [ -n "$destino_ok" ] && echo "  ok     $cmd  ($destino_ok)"
    fi
  fi
fi

# --- 6. Enlaces relativos rotos ---------------------------------------------
sec 'Enlaces'
rotos=0
while IFS= read -r archivo; do
  base=$(dirname "$archivo")
  while IFS= read -r destino; do
    [ -z "$destino" ] && continue
    case "$destino" in http*|mailto:*|\#*|@*) continue ;; esac
    ruta="${destino%%#*}"
    [ -z "$ruta" ] && continue
    [ -e "$base/$ruta" ] || { err "$archivo -> $ruta (no existe)"; rotos=$((rotos + 1)); }
  done < <(grep -o ']([^)]*)' "$archivo" 2>/dev/null | sed 's/^](//; s/)$//')
done < <(archivos_markdown)
[ "$rotos" -eq 0 ] && echo '  ok     sin enlaces rotos'

# --- 7. Numeración y formato de los ADR -------------------------------------
sec 'ADRs'
adrs=0
if [ -d docs/decisiones ]; then
  for adr in docs/decisiones/*.md; do
    [ -e "$adr" ] || continue
    nombre=$(basename "$adr")
    [ "$nombre" = '0000-plantilla.md' ] && continue
    adrs=$((adrs + 1))
    case "$nombre" in
      [0-9][0-9][0-9][0-9]-*.md) ;;
      *) err "$nombre: el nombre debe ser NNNN-titulo.md" ;;
    esac
    grep -qi '^- Estado:' "$adr" || err "$nombre: falta el campo 'Estado'"
    grep -qE '^- Fecha: [0-9]{4}-[0-9]{2}-[0-9]{2}' "$adr" || err "$nombre: falta 'Fecha' en formato YYYY-MM-DD"
    grep -qi '^## Ya descartado' "$adr" || adv "$nombre: sin seccion 'Ya descartado' (es la que mas regresiones evita)"
  done
fi
echo "  ok     $adrs ADR"

# --- 8. Marca de version de la estructura -----------------------------------
# Lo lee un procedimiento futuro para saber si aca ya hay estructura y de cual. Si el
# archivo esta mal formado, ese procedimiento no va a poder distinguir "sin estructura"
# de "estructura vieja", que es justo la diferencia que importa.
#
# leer_version() esta duplicada, identica, en scripts/detectar-estructura.sh de la
# fabrica. No se puede compartir: este script vive dentro del proyecto y no tiene acceso
# a la fabrica. La equivalencia entre las dos copias la comprueba la suite de la fabrica.
leer_version() {
  local archivo="$1" claves valor
  [ -f "$archivo" ] || return 1
  claves=$(grep -c '^version:' "$archivo")
  [ "$claves" -eq 1 ] || return 1
  valor=$(sed -n 's/^version:[[:space:]]*\([1-9][0-9]*\)[[:space:]]*$/\1/p' "$archivo")
  [ -n "$valor" ] || return 1
  printf '%s' "$valor"
}

sec 'Version de la estructura'
if [ -f .estructura-proyecto.yml ]; then
  ver=$(leer_version .estructura-proyecto.yml)
  fecha=$(sed -n 's/^adoptada:[[:space:]]*\([0-9-]\+\)[[:space:]]*$/\1/p' .estructura-proyecto.yml | head -1)
  [ -n "$ver" ] || err '.estructura-proyecto.yml: "version" tiene que ser una unica clave con un entero positivo'
  if printf '%s' "$fecha" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
    [ -n "$ver" ] && echo "  ok     version $ver, adoptada $fecha"
  else
    err '.estructura-proyecto.yml: "adoptada" tiene que ser una fecha YYYY-MM-DD'
  fi
else
  adv 'sin .estructura-proyecto.yml: una adopcion futura no va a poder detectar esta estructura'
fi

# --- 9. Los adaptadores referencian AGENTS.md -------------------------------
# Son imports, no copias: cada herramienta usa su propia sintaxis y AGENTS.md queda
# como unico original. Aca solo se comprueba que apunten ahi y no tengan reglas
# propias que compitan con el canonico.
sec 'Adaptadores de agentes'
adaptadores=0
for f in CLAUDE.md GEMINI.md .cursor/rules/agents.mdc .github/copilot-instructions.md; do
  [ -f "$f" ] || continue
  adaptadores=$((adaptadores + 1))
  if grep -q 'AGENTS\.md' "$f"; then
    cuerpo=$(grep -cve '^\s*$' -e '^---' -e '^[a-zA-Z]*:' -e '^<!--' -e 'AGENTS\.md' "$f")
    if [ "$cuerpo" -gt 3 ]; then
      adv "$f: tiene $cuerpo lineas propias ademas del import. Las reglas van en AGENTS.md."
    else
      echo "  ok     $f"
    fi
  else
    err "$f no referencia AGENTS.md. Ejecuta: bash scripts/sincronizar-adaptadores.sh"
  fi
done
[ "$adaptadores" -eq 0 ] && echo '  ok     ninguno configurado'

# --- 10. Sin JavaScript -----------------------------------------------------
# Invariante 1 / ADR 0002 y 0004: la garantia de no leer las tareas es la
# ausencia de JS, no una promesa. Un .js en el repo (o un content script en el
# adaptador Chromium) la elimina por completo.
sec 'Sin JavaScript'
js=$(archivos_del_repo | grep -E '\.(js|mjs|cjs)$' || true)
if [ -n "$js" ]; then
  while IFS= read -r f; do err "$f: el invariante 1 prohibe JavaScript"; done <<< "$js"
else
  echo '  ok     ningun .js / .mjs / .cjs'
fi

# --- 11. Adaptador Chromium -------------------------------------------------
sec 'Adaptador Chromium'
if [ -d extension ]; then
  if [ ! -f scripts/sincronizar-extension.sh ]; then
    err 'existe extension/ pero falta scripts/sincronizar-extension.sh'
  elif bash scripts/sincronizar-extension.sh --check; then
    :
  else
    errores=$((errores + 1))
  fi

  extra=$(find extension -type f \
    ! -name 'manifest.json' ! -name 'omnifocus-dark.css' 2>/dev/null || true)
  if [ -n "$extra" ]; then
    while IFS= read -r f; do
      err "$f: en extension/ solo pueden estar manifest.json y omnifocus-dark.css"
    done <<< "$extra"
  fi

  if [ -f extension/manifest.json ]; then
    if grep -q '"background"' extension/manifest.json; then
      err 'extension/manifest.json declara background (implica JS)'
    fi
    if grep -q '"service_worker"' extension/manifest.json; then
      err 'extension/manifest.json declara service_worker'
    fi
    if grep -q '"js"' extension/manifest.json; then
      err 'extension/manifest.json declara content_scripts.js'
    fi
    if grep -qE '"permissions"|"host_permissions"|"optional_permissions"' \
         extension/manifest.json; then
      err 'extension/manifest.json declara permisos extra; alcanza con content_scripts.matches'
    fi
    if command -v python3 >/dev/null 2>&1; then
      if python3 -m json.tool extension/manifest.json >/dev/null 2>&1; then
        echo '  ok     extension/manifest.json es JSON valido'
      else
        err 'extension/manifest.json no es JSON valido'
      fi
    fi
  else
    err 'falta extension/manifest.json'
  fi
else
  echo '  ok     sin extension/ (Stylus sigue siendo la via principal)'
fi

# --- Resumen ----------------------------------------------------------------
printf '\n'
if [ "$errores" -gt 0 ]; then
  printf 'FALLO: %s error(es), %s aviso(s).\n' "$errores" "$avisos"
  exit 1
fi
printf 'OK: sin errores, %s aviso(s).\n' "$avisos"
