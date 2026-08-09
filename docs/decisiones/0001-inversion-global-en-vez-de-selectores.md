# 0001. Invertir toda la página en vez de apuntar a selectores

- Estado: aceptada
- Fecha: 2026-07-08

> Escrito retroactivamente el 2026-08-09, al adoptar la estructura. La decisión se tomó en
> el commit `9cbb87a`; la fecha es la real de ese commit.

> El contenido histórico de este archivo es inmutable: dice qué se decidió y con qué
> información, en esa fecha. Lo único editable es el campo `Estado` (para marcarlo
> reemplazado), el enlace al ADR que lo sustituye, y errores de hecho señalados como
> corrección.

## Contexto

OmniFocus for the Web no tiene modo oscuro: ignora `prefers-color-scheme` y siempre
renderiza claro. Su interfaz está construida con styled-components, así que las clases CSS
son hashes que **cambian en cada build** de la aplicación. No hay atributos estables,
ni control sobre cuándo Omni Group despliega una versión nueva.

## Decisión

El estilo aplica `filter: invert() hue-rotate(180deg)` sobre `html`, y re-invierte un
puñado de selectores genéricos (`img`, `video`, `svg`, `canvas`, `picture`, fondos de
imagen, avatares) para que las imágenes no queden en negativo.

## Por qué

Un modo oscuro escrito contra los selectores reales sería más prolijo y se rompería en
cada build ajeno, en silencio y sin aviso. La inversión no depende de ninguna clase: solo
de que exista un `html`. El `hue-rotate(180deg)` es lo que separa esto de un negativo
fotográfico: devuelve los tonos a su matiz original, así que las etiquetas, banderas y
enlaces conservan su color.

## Ya descartado — no reevaluar

La sección más importante del ADR. El error típico de un agente no es ignorar cómo
funciona el código: es proponer con total seguridad algo que ya se probó y falló.

- **Opción**: escribir reglas contra los selectores reales de la aplicación
  - **Qué pasó**: se descartó sin probar, al ver que las clases son hashes de
    styled-components
  - **Motivo del descarte**: cada build de OmniFocus cambia los nombres; el estilo se
    rompería sin que nadie lo note hasta abrirlo
  - **Se reconsidera si**: OmniFocus expone atributos estables (`data-*`, roles ARIA) o
    variables CSS temáticas
- **Opción**: `invert()` sin `hue-rotate`
  - **Qué pasó**: los colores quedan en negativo
  - **Motivo del descarte**: la interfaz depende de los colores para transmitir
    significado —etiquetas, banderas, enlaces—; en negativo dejan de ser reconocibles
  - **Se reconsidera si**: nunca

## Consecuencias

Fácil: sobrevivir a los builds ajenos sin mantenimiento; cubrir toda la aplicación,
incluidas las pantallas que nadie inspeccionó.

Caro: **la técnica invierte el significado de todos los colores del archivo** (ver
[ADR 0003](0003-consecuencias-de-invertir-la-pagina.md)), es imposible afinar un detalle
concreto sin volver a los selectores frágiles, y cualquier elemento nuevo que Omni agregue
—si es una imagen fuera de la lista de contra-inversión— va a aparecer en negativo hasta
que alguien lo note.

## Verificación

No hay forma automática de verificarlo: el resultado es visual y depende de una aplicación
de terceros que cambia sola. Se comprueba abriendo <https://web.omnifocus.com/> con el
estilo activo.
