# Invariantes

Reglas que se pueden violar sin que nada falle y sin que nadie se entere.

**Ninguna está automatizada.** El repositorio no tiene tests, tipos ni linters, y el
resultado —cómo se ve la página— no es verificable por máquina. La única red es esta
lista. Los tres primeros están en `AGENTS.md`; los cinco se registraron el 2026-08-09 al
adoptar la estructura, a partir del código y del historial.

---

## 1. Solo CSS. Nunca JavaScript

**Riesgo: alto.**

Que este estilo no pueda leer ni exfiltrar tus tareas es una propiedad **estructural**:
Stylus es un gestor de estilos y no ejecuta JS. No es una promesa del autor ni una
política que se pueda auditar leyendo el código. Agregar JavaScript —o migrar a un gestor
que lo permita— no degrada la garantía: la elimina por completo.

- Evidencia: `README.md:9`, `omnifocus-dark.user.css:30-33`.
- Historia: el proyecto fue userscript hasta el commit `06a9669` (2026-07-09), que eliminó
  esa versión justamente por esto. Ver [ADR 0002](decisiones/0002-stylus-userstyle-solo-css.md).
- Cómo se rompe en silencio: "para arreglar tal detalle alcanza con un pequeño script".

## 2. Todo está invertido: para que algo se vea oscuro hay que darle un color CLARO

**Riesgo: alto.**

`html` lleva `filter: invert(...)`, así que cada color que se escriba en el CSS aparece
invertido en pantalla. El fondo de la página es `#fff` **porque** se invierte a
casi-negro y calza sin costuras con el contenido blanco de la app. Escribir un valor
oscuro ahí —el reflejo natural en un modo oscuro— lo convierte en gris claro y pinta un
marco brillante alrededor del contenido. Lo mismo vale para los scrollbars.

- Evidencia: `omnifocus-dark.user.css:24-28,58-67,69-87`, `README.md:39-41`.
- Historia: commit `81ec7ab` (2026-07-09). Ver
  [ADR 0003](decisiones/0003-consecuencias-de-invertir-la-pagina.md).

## 3. `color-scheme: light` es deliberado

**Riesgo: alto.**

En un archivo llamado "modo oscuro", `color-scheme: light` parece un error obvio. No lo
es, y es exactamente lo que un agente "corrige". Con `light`, el navegador pinta los
controles nativos (inputs, textareas) claros y la inversión los lleva a oscuro. Con
`dark`, los pinta oscuros y la inversión los devuelve blancos brillantes.

- Evidencia: `omnifocus-dark.user.css:49-50`, `README.md:42-45`.
- Historia: commit `04f78ba` (2026-07-09). Ver
  [ADR 0003](decisiones/0003-consecuencias-de-invertir-la-pagina.md).

## 4. Todo cambio publicado del CSS sube `@version`

**Riesgo: medio.**

`@updateURL` apunta a `main` en GitHub: Stylus decide si actualizar comparando la versión
instalada con la del archivo remoto. Un cambio con la misma versión no llega a nadie que
ya lo tenga instalado, y el arreglo queda invisible sin que nada falle.

- Evidencia: `omnifocus-dark.user.css:4,10`.
- Se cumplió en los 5 commits que tocaron el CSS: `1.0.0` → `1.1.0` → `1.2.0` → `1.3.0` →
  `1.3.1` → `1.3.2`.
- Va junto con la entrada correspondiente en `CHANGELOG.md`.

## 5. Los defaults documentados en el README coinciden con los del `:root`

**Riesgo: medio.**

`--of-darkness` y `--of-warmth` están escritos dos veces: en el CSS y, con su explicación,
en el README. Nada los sincroniza. Si divergen, la documentación empieza a describir un
estilo que no es el que la gente instala.

- Evidencia: `README.md:53-57` vs `omnifocus-dark.user.css:53-55`.
- Historia: el commit `9d9d522` (2026-07-09) existió, entre otras cosas, para
  resincronizarlos.
