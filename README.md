# omnifocus-darkmode

Modo oscuro para **OmniFocus for the Web** (`https://web.omnifocus.com/`) mediante un userscript de Violentmonkey/Tampermonkey.

## Por qué un userscript y no una extensión de modo oscuro

Este script es **solo CSS** y se declara con `@grant none`: no tiene ninguna capacidad de red (nada de `fetch`, `XHR` ni `GM_xmlhttpRequest`). Técnicamente **no puede sacar tus tareas de tu máquina**. Todo el código está acá, versionado y auditable — no hay actualizaciones silenciosas de terceros.

## Instalación

1. Instalá el gestor de userscripts en tu navegador:
   - [Violentmonkey](https://violentmonkey.github.io/) (recomendado, open source), o
   - [Tampermonkey](https://www.tampermonkey.net/).
2. Abrí el script para instalarlo:
   [`omnifocus-dark.user.js`](https://raw.githubusercontent.com/meconecto/omnifocus-darkmode/main/omnifocus-dark.user.js)
   El gestor detecta el `.user.js` y ofrece instalarlo.
3. Entrá a <https://web.omnifocus.com/>. Debería verse oscuro.

## Cómo funciona

OmniFocus web usa clases CSS hasheadas (styled-components) que cambian en cada
build, así que apuntar a selectores concretos se rompe seguido. Para que sea
robusto, el script **invierte la página y rota el tono 180°** (los colores de
etiquetas, banderas y links conservan su matiz en vez de verse "en negativo") y
luego **re-invierte imágenes, video e íconos** para que se vean normales.

## Ajustes

En el propio `.user.js`:

- **`DARKNESS`** (default `1`): cuánto se oscurece. Bajalo a `0.92` para un gris menos duro.
- **`COUNTER_INVERT`**: lista de elementos que se re-invierten para no verse en negativo. Si algún ícono/imagen queda mal, agregá o sacá un selector.

Tras editar el archivo, reinstalá/actualizá el script en el gestor.

## Limitaciones

- La técnica de inversión es amplia por diseño; puede que algún detalle puntual
  no quede perfecto. Se puede afinar con overrides específicos una vez inspeccionado
  el DOM real (logueado).
- Probado contra OmniFocus 4 for the Web.

## Licencia

[MIT](LICENSE)
