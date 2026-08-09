# 0003. Consecuencias obligadas de invertir la página: fondo `#fff`, `color-scheme: light`, scrollbars claros

- Estado: aceptada
- Fecha: 2026-07-09

> Escrito retroactivamente el 2026-08-09, al adoptar la estructura. Las decisiones se
> tomaron en los commits `04f78ba` y `81ec7ab`; la fecha es la del segundo.

> El contenido histórico de este archivo es inmutable: dice qué se decidió y con qué
> información, en esa fecha. Lo único editable es el campo `Estado` (para marcarlo
> reemplazado), el enlace al ADR que lo sustituye, y errores de hecho señalados como
> corrección.

## Contexto

Con la inversión global ya en su lugar ([ADR 0001](0001-inversion-global-en-vez-de-selectores.md)),
aparecieron dos defectos visibles: un marco claro alrededor del contenido, y campos de
formulario que se veían como rectángulos blancos brillantes. Los dos venían de escribir
valores "oscuros" en un archivo donde todo se invierte.

## Decisión

Las tres partes del estilo que no forman parte del contenido de la app se escriben con
**valores claros**, para que la inversión las lleve a oscuro:

- `html, body { background: #fff }`
- `color-scheme: light`
- `::-webkit-scrollbar-*` con `#fff` y grises claros (`#b8b8b8`, `#a0a0a0`)

## Por qué

El filtro se aplica al elemento `html`, así que **todo** lo que se declare debajo aparece
invertido, incluido lo que uno escribe pensando en el resultado final y no en la entrada.

- Un fondo `#fff` se invierte a casi-negro y calza sin costuras con el contenido blanco de
  la aplicación, que se invierte igual. Un fondo oscuro se invierte a gris claro: de ahí
  el marco brillante.
- `color-scheme` le dice al navegador cómo pintar los controles nativos, **antes** del
  filtro. Con `light` los pinta claros y la inversión los oscurece. Con `dark` los pinta
  oscuros y la inversión los vuelve blancos.
- Los scrollbars sí son alcanzados por el filtro, así que siguen la misma regla.

## Ya descartado — no reevaluar

La sección más importante del ADR. El error típico de un agente no es ignorar cómo
funciona el código: es proponer con total seguridad algo que ya se probó y falló.

- **Opción**: poner un color oscuro en el fondo de `html`/`body` (lo intuitivo en un modo
  oscuro)
  - **Qué pasó**: se probó; corregido en el commit `81ec7ab`
  - **Motivo del descarte**: la inversión lo convierte en gris claro y pinta un marco
    brillante alrededor del contenido
  - **Se reconsidera si**: se elimina la inversión global, es decir si se reemplaza el
    [ADR 0001](0001-inversion-global-en-vez-de-selectores.md)
- **Opción**: `color-scheme: dark`
  - **Qué pasó**: se probó; corregido en el commit `04f78ba`
  - **Motivo del descarte**: el navegador pinta inputs y textareas oscuros, y el filtro los
    invierte a blanco brillante
  - **Se reconsidera si**: ídem anterior

## Consecuencias

Fácil: un modo oscuro sin costuras entre el marco del navegador y el contenido, con
formularios y scrollbars coherentes.

Caro: **el archivo se lee al revés de lo que significa.** Cualquiera —persona o agente—
que abra el CSS ve `background: #fff` y `color-scheme: light` en un estilo llamado "modo
oscuro" y concluye que hay un error. Por eso los tres valores están comentados en el
propio archivo y registrados como invariantes 2 y 3 en
[docs/invariantes.md](../invariantes.md).

## Verificación

No es automatizable. Se comprueba abriendo <https://web.omnifocus.com/> con el estilo
activo y mirando tres cosas: que no haya marco claro alrededor del contenido, que los
campos de texto se vean oscuros, y que la barra de scroll se vea oscura.
