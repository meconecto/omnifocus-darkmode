# 0004. Extensión Chromium local, CSS only, como vía opcional de instalación

- Estado: aceptada
- Fecha: 2026-09-13

> Complementa [ADR 0002](0002-stylus-userstyle-solo-css.md): Stylus sigue siendo la
> distribución principal. Esta decisión agrega un adaptador, no lo reemplaza.

> El contenido histórico de este archivo es inmutable: dice qué se decidió y con qué
> información, en esa fecha. Lo único editable es el campo `Estado` (para marcarlo
> reemplazado), el enlace al ADR que lo sustituye, y errores de hecho señalados como
> corrección.

## Contexto

El estilo se instala con Stylus ([ADR 0002](0002-stylus-userstyle-solo-css.md)). Eso
exige una extensión de terceros en el navegador. En Chrome y Brave se puede cargar una
carpeta local como extensión desempaquetada, sin Chrome Web Store y sin otro gestor de
estilos.

El original sigue siendo `omnifocus-dark.user.css`. Chromium no entiende
`@-moz-document`: una at-rule desconocida se ignora **con todo su bloque**, así que
inyectar el `.user.css` tal cual no aplica ninguna regla.

## Decisión

El repositorio incluye `extension/`: una extensión Manifest V3 que inyecta CSS en
`https://web.omnifocus.com/*` y **no contiene JavaScript**. Se carga localmente
(developer mode → Load unpacked). `omnifocus-dark.user.css` es la fuente; el CSS de la
extensión se genera con `scripts/sincronizar-extension.sh`.

## Por qué

Una extensión Chromium puede inyectar hojas de estilo desde el `manifest.json` sin
`content_scripts.js`, sin `background` y sin `service_worker`. En ese recorte no hay
código que lea el DOM ni que haga red: la garantía del invariante 1 se sostiene por la
forma del paquete, igual que con Stylus.

Sirve a quien no quiere instalar Stylus y acepta recargar la extensión a mano después de
cada cambio. No compite con el auto-update de UserCSS.

## Ya descartado — no reevaluar

La sección más importante del ADR. El error típico de un agente no es ignorar cómo
funciona el código: es proponer con total seguridad algo que ya se probó y falló.

- **Opción**: userscript (Violentmonkey/Tampermonkey) o un `content_scripts.js` que
  inserte un `<style>`
  - **Qué pasó**: ya descartado en [ADR 0002](0002-stylus-userstyle-solo-css.md); el
    proyecto nació así y se eliminó en `06a9669`
  - **Motivo del descarte**: JavaScript en la página de las tareas **puede** leerlas y
    hacer red. El invariante 1 no es una política: es la ausencia de JS
  - **Se reconsidera si**: nunca, mientras el objetivo sea únicamente cambiar colores
- **Opción**: reemplazar Stylus por la extensión como distribución principal
  - **Qué pasó**: descartada al escribir esta decisión
  - **Motivo del descarte**: sin Stylus no hay `@updateURL`. La extensión local exige
    developer mode y no se actualiza sola. Stylus ya resuelve instalación y
    auto-update sin store propio
  - **Se reconsidera si**: el auto-update de Stylus deja de funcionar en Chromium
- **Opción**: publicarla en Chrome Web Store
  - **Qué pasó**: descartada sin publicar
  - **Motivo del descarte**: el store pide confiar en quien firma las actualizaciones.
    Una update puede agregar JS sin que quien instaló vuelva a leer el repo. La vía
    local es auditable archivo por archivo en disco
  - **Se reconsidera si**: nunca, mientras la garantía tenga que ser estructural y no
    una promesa del publicador
- **Opción**: popup, options page o service worker para editar `--of-darkness` /
  `--of-warmth`
  - **Qué pasó**: descartada sin implementar
  - **Motivo del descarte**: son HTML y JavaScript. El invariante 1 no admite
    "un poco de JS para la UI"
  - **Se reconsidera si**: nunca, mientras el invariante 1 siga vigente
- **Opción**: extensión genérica de modo oscuro (Dark Reader y similares)
  - **Qué pasó**: ya descartada en [ADR 0002](0002-stylus-userstyle-solo-css.md)
  - **Motivo del descarte**: permisos de lectura sobre la página; mismo problema de
    confianza, con menos control sobre el resultado
  - **Se reconsidera si**: nunca

## Consecuencias

Fácil: instalar en Chrome/Brave sin Stylus; auditar el paquete (manifest + una hoja
CSS, cero `.js`); el script de sync evita una segunda fuente de verdad.

Caro: Chrome muestra igual el aviso de "leer y cambiar datos en web.omnifocus.com"
aunque solo se inyecte CSS — el navegador no distingue. No hay auto-update. Hay que
recargar la extensión después de regenerar. Stylus y la extensión **no** pueden estar
activas a la vez: la inversión se aplicaría dos veces. Developer mode queda prendido
en ese perfil.

## Verificación

`bash scripts/verificar-repo.sh` comprueba que no haya `.js` en el repo, que
`extension/omnifocus-dark.css` coincida con el `.user.css`, que la `version` del
manifest sea el `@version`, y que el manifest no declare `js`, `background`,
`service_worker` ni permisos extra.
