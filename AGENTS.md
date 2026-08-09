# omnifocus-darkmode

Modo oscuro para OmniFocus for the Web, como userstyle de Stylus: un único archivo CSS.

<!-- verify: scripts/verificar-repo.cmd -->

## Glosario

| En el negocio | En el código | Significado |
|---|---|---|
| Stylus | — | El gestor de estilos (openstyles, GPLv3). **No es Stylish**, el original con telemetría. La diferencia es el argumento central del proyecto. |
| userstyle | `omnifocus-dark.user.css` | CSS que aplica Stylus. **No es un userscript** (Violentmonkey/Tampermonkey), aunque el sufijo `.user.css` se le parezca. El repo fue userscript hasta el 2026-07-09. |

## Invariantes

No hay ninguno impuesto por un mecanismo: el repositorio no tiene tests, tipos ni linters.
Los cinco están en [docs/invariantes.md](docs/invariantes.md); acá van los tres que rompen
el producto en silencio.

### No automatizados

- Regla: **solo CSS, nunca JavaScript** · Riesgo: alto · Automatizar en: sin plan
- Regla: **todo está invertido — para que algo se vea oscuro hay que darle un color CLARO**
  · Riesgo: alto · Automatizar en: sin plan
- Regla: **`color-scheme: light` es deliberado**, no un error a corregir · Riesgo: alto ·
  Automatizar en: sin plan

Los dos restantes (subir `@version` en cada cambio publicado; mantener los defaults del
README iguales a los del `:root`) están en [docs/invariantes.md](docs/invariantes.md).

## Verificación

Antes de dar algo por terminado, ejecutá `scripts\verificar-repo.cmd` (en Linux o macOS,
`bash scripts/verificar-repo.sh`). El marcador de arriba lo declara con barra normal a
propósito: es la única forma que resuelve tanto en Windows como en el CI.

Verifica la estructura del repositorio, no el CSS: **el resultado visual no se puede
verificar automáticamente**. Cualquier cambio en `omnifocus-dark.user.css` hay que mirarlo
en <https://web.omnifocus.com/> con el estilo aplicado.

Informá qué corriste, qué pasó y qué no pudiste verificar. Escribir el código no es
terminar.

## Autoridad ante contradicciones

1. Criterios de aceptación de la tarea.
2. ADRs vigentes en `docs/decisiones/`.
3. Código, tests y el resto de la documentación.

El código actual puede ser el bug que la tarea busca corregir: no lo tomes como correcto
por existir.

Si resolver la contradicción cambia el producto, los datos, la seguridad o una interfaz
pública: **pará y preguntá**. No elijas en silencio.

## Cuándo crear documentación

Cuando ocurre el hecho, nunca antes. Al crear el archivo, borrá su fila de esta tabla.

| Hecho observable | Se crea |
|---|---|
| Decisión con alternativas descartadas | ADR en `docs/decisiones/` |
| Primera variable de entorno | `.env.example` |
| Colaboradores externos | `CONTRIBUTING.md` |
| Reportes de seguridad de terceros | `SECURITY.md` |
| Invariantes de estructura que no entran acá | `docs/arquitectura/` |
| Procedimiento manual hecho dos veces | Script en `scripts/` |
| Recuperación ante fallas en producción | `docs/runbooks/` |
| Trabajo autónomo sin tracker externo | `tasks/` + sus reglas de coordinación |

No crees documentos vacíos ni especulativos.

## Ritual

- Decisión nueva o alternativa descartada → ADR. El contenido histórico de un ADR es
  inmutable: solo se editan su estado, el enlace al que lo reemplaza y errores de hecho
  señalados como tales. Si la decisión cambia, se escribe un ADR nuevo.
- Cambio publicado del CSS → subir `@version` y agregar la entrada en `CHANGELOG.md`.
- Corregiste a un agente por segunda vez → invariante nuevo en `docs/invariantes.md`.
- Explicaste lo mismo dos veces → script si es automatizable, doc si necesita criterio.
- Fechas absolutas siempre (`2026-08-09`), nunca "el mes pasado".
