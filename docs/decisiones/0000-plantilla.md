# 0000. @@PLANTILLA:Título de la decisión@@

- Estado: @@PLANTILLA:propuesta | aceptada | reemplazada por 00XX@@
- Fecha: @@PLANTILLA:YYYY-MM-DD@@

> El contenido histórico de este archivo es inmutable: dice qué se decidió y con qué
> información, en esa fecha. Lo único editable es el campo `Estado` (para marcarlo
> reemplazado), el enlace al ADR que lo sustituye, y errores de hecho señalados como
> corrección.
>
> Si la decisión cambia, se escribe un ADR nuevo. Así desaparece la tarea de "mantener la
> documentación al día", que es la que nunca se hace.

## Contexto

@@PLANTILLA:Qué problema había, y qué era cierto en ese momento. Sin justificar todavía.@@

## Decisión

@@PLANTILLA:Qué se hace. En presente y en una o dos frases.@@

## Por qué

@@PLANTILLA:La razón concreta. Lo que un agente no puede deducir leyendo el resultado.@@

## Ya descartado — no reevaluar

La sección más importante del ADR. El error típico de un agente no es ignorar cómo
funciona el código: es proponer con total seguridad algo que ya se probó y falló.

- **Opción**: @@PLANTILLA:qué se consideró@@
  - **Qué pasó**: @@PLANTILLA:se probó y falló así | se descartó sin probar por esta razón@@
  - **Motivo del descarte**: @@PLANTILLA:concreto, no "no nos gustó"@@
  - **Se reconsidera si**: @@PLANTILLA:qué tendría que cambiar. "Nunca" es una respuesta válida, pero es rara.@@

## Consecuencias

@@PLANTILLA:Qué se vuelve fácil y qué se vuelve caro. Incluir lo malo: un ADR sin costos no fue una decisión, fue una preferencia.@@

## Verificación

@@PLANTILLA:Cómo se comprueba que la decisión sigue vigente en el código: un test, un constraint, un script. Si no hay forma de verificarlo, decirlo explícitamente.@@
