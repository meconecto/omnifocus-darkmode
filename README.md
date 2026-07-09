# omnifocus-darkmode

Modo oscuro para **OmniFocus for the Web** (`https://web.omnifocus.com/`) mediante un estilo de **[Stylus](https://github.com/openstyles/stylus)**.

## Por qué Stylus (y no una extensión de modo oscuro cualquiera)

El modo oscuro es **100% CSS**. Stylus es un gestor de *estilos*: **no ejecuta JavaScript**, así que el estilo **no tiene ninguna capacidad de red y es incapaz de leer o exfiltrar tus tareas** — la garantía es estructural, no una promesa. Además Stylus es open source (GPLv3) y nació como fork sin telemetría de "Stylish". Para datos sensibles como tus tareas, es lo más defendible. Todo el código está acá, versionado y auditable.

## Instalación

1. Instalá **[Stylus](https://github.com/openstyles/stylus)** desde la tienda de tu navegador.
   > Ojo: es **Stylus** (de `openstyles`), **no** "Stylish" (el original con telemetría).
2. Abrí el estilo para instalarlo:
   [`omnifocus-dark.user.css`](https://raw.githubusercontent.com/meconecto/omnifocus-darkmode/main/omnifocus-dark.user.css)
   Stylus detecta el formato UserCSS y ofrece instalarlo (con auto-update).
3. Entrá a <https://web.omnifocus.com/>. Debería verse oscuro.

Alternativa sin auto-update: en el dashboard de Stylus → **"Write new style"** → pegá el contenido de [`omnifocus-dark.user.css`](omnifocus-dark.user.css) → **Save**.

## Cómo funciona

OmniFocus web usa clases CSS hasheadas (styled-components) que cambian en cada
build, así que apuntar a selectores concretos se rompe seguido. Para que sea
robusto, se **invierte la página y se rota el tono 180°** (los colores de
etiquetas, banderas y links conservan su matiz en vez de verse "en negativo") y
luego se **re-invierten imágenes, video e íconos** para que se vean normales.

## Ajustes

En el `.user.css`, dentro del bloque `:root`:

- **`--of-darkness`** (default `1`): cuánto se oscurece. Bajalo a `0.92` para un gris menos duro.
- **`--of-bg`**: color de fondo real detrás de la app.
- **Lista de contra-inversión**: los selectores que se re-invierten para no verse en negativo. Si algún ícono/imagen queda mal, agregá o sacá un selector.

Tras editar, guardá en Stylus (se aplica al instante).

## Limitaciones

- La técnica de inversión es amplia por diseño; puede que algún detalle puntual
  no quede perfecto. Se puede afinar con overrides específicos una vez inspeccionado
  el DOM real (logueado).
- Probado contra OmniFocus 4 for the Web.

## Licencia

[MIT](LICENSE)
