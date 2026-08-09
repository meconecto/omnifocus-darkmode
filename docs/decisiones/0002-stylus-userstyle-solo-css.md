# 0002. Stylus y UserCSS, no un userscript ni una extensión de modo oscuro

- Estado: aceptada
- Fecha: 2026-07-09

> Escrito retroactivamente el 2026-08-09, al adoptar la estructura. La decisión se tomó en
> el commit `06a9669`; la fecha es la real de ese commit.

> El contenido histórico de este archivo es inmutable: dice qué se decidió y con qué
> información, en esa fecha. Lo único editable es el campo `Estado` (para marcarlo
> reemplazado), el enlace al ADR que lo sustituye, y errores de hecho señalados como
> corrección.

## Contexto

La primera versión (`9cbb87a`) era un userscript: JavaScript que inyectaba el CSS. Lo que
esto se pone encima es una vista de **tareas personales** —la aplicación completa de
gestión de proyectos de alguien—, y cualquier cosa que corra ahí puede leerlas.

## Decisión

El proyecto se distribuye como **userstyle en formato UserCSS**, instalado con
[Stylus](https://github.com/openstyles/stylus). No contiene ni contendrá JavaScript.

## Por qué

Stylus es un gestor de estilos: **no ejecuta JavaScript**. Por lo tanto este estilo no
tiene capacidad de red y no puede leer ni enviar las tareas a ningún lado. La garantía es
estructural, no una promesa que haya que creerle a quien escribió el código. Para datos
sensibles, esa es la única forma defendible de distribuir un modo oscuro.

Además, UserCSS trae versionado y auto-actualización (`@version`, `@updateURL`) sin
depender de ningún store.

## Ya descartado — no reevaluar

La sección más importante del ADR. El error típico de un agente no es ignorar cómo
funciona el código: es proponer con total seguridad algo que ya se probó y falló.

- **Opción**: userscript con Violentmonkey o Tampermonkey
  - **Qué pasó**: era la versión inicial; se eliminó en el commit `06a9669`
  - **Motivo del descarte**: un userscript **puede** leer las tareas y hacer red; la
    garantía pasa a depender de confiar en el autor. Además, con la retirada de Manifest
    V2 en Chromium, el build estable de Violentmonkey ya no instala en Brave
  - **Se reconsidera si**: nunca, mientras el objetivo sea únicamente cambiar colores
- **Opción**: una extensión genérica de modo oscuro (tipo Dark Reader)
  - **Qué pasó**: descartada sin probar
  - **Motivo del descarte**: requiere permisos de lectura sobre la página; mismo problema
    de confianza, con menos control sobre el resultado
  - **Se reconsidera si**: nunca
- **Opción**: Stylish (el gestor original, no Stylus)
  - **Qué pasó**: descartada sin probar
  - **Motivo del descarte**: envió telemetría de navegación; Stylus nació como fork sin
    telemetría, y es open source (GPLv3)
  - **Se reconsidera si**: nunca

## Consecuencias

Fácil: auditar el proyecto entero —es un archivo de texto—; publicarlo sin store, sin
build y sin dependencias; sostener la afirmación de privacidad sin pedir confianza.

Caro: **nada que necesite lógica es posible.** No hay condicionales según el estado de la
página, ni detección de elementos, ni reacción a cambios del DOM. Todo problema tiene que
resolverse dentro de lo que puede expresar CSS, o no resolverse.

## Verificación

Automática y trivial de leer: el repositorio contiene un solo archivo de código y es CSS.
Si alguna vez aparece un `.js`, o un `<script>` dentro del CSS, el invariante 1 de
[docs/invariantes.md](../invariantes.md) está violado.
