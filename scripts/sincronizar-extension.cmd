@echo off
REM Punto de entrada en Windows para sincronizar-extension.sh
REM
REM Tres trampas, en orden:
REM  1. `bash` a secas resuelve primero a C:\Windows\System32\bash.exe, que es WSL y
REM     falla si no hay distro instalada.
REM  2. Git trae dos bash: `Git\bin\bash.exe` y `Git\usr\bin\bash.exe`. Se usa el
REM     primero.
REM  3. Que `Git\bin\bash.exe` arme por si solo el PATH de msys (/usr/bin, /mingw64/bin)
REM     depende de la instalacion: en algunas lo hace y en otras no, y ahi faltan
REM     dirname, mktemp, cp y rm. Tocar el PATH de Windows antes de abrir Bash NO
REM     alcanza: el wrapper lo reconstruye al iniciar. El PATH se arma adentro de Bash
REM     -- lo hace el propio .sh -- y no con `--login`, que cargaria los perfiles
REM     personales del usuario.
setlocal

set "BASH="
for %%P in (
  "%ProgramFiles%\Git\bin\bash.exe"
  "%ProgramFiles(x86)%\Git\bin\bash.exe"
  "%LOCALAPPDATA%\Programs\Git\bin\bash.exe"
) do if not defined BASH if exist %%P set "BASH=%%~P"

if not defined BASH (
  for /f "delims=" %%G in ('where git 2^>nul') do (
    if not defined BASH if exist "%%~dpG..\bin\bash.exe" set "BASH=%%~dpG..\bin\bash.exe"
  )
)

if not defined BASH (
  echo ERROR: no se encontro el bash de Git ^(Git\bin\bash.exe^).
  echo Instala Git para Windows: https://git-scm.com/download/win
  exit /b 1
)

REM Raiz de la instalacion de Git, solo para el mensaje de diagnostico.
for %%I in ("%BASH%") do set "GIT_ROOT=%%~dpI.."
for %%I in ("%GIT_ROOT%") do set "GIT_ROOT=%%~fI"

REM Guard: mismo bootstrap que hace el .sh, sin perfiles de usuario.
"%BASH%" --noprofile --norc -c "PATH=/usr/bin:/mingw64/bin:$PATH; export PATH; command -v dirname >/dev/null && command -v mktemp >/dev/null" 2>nul
if errorlevel 1 (
  echo ERROR: no se resuelven las utilidades POSIX ^(dirname, mktemp^).
  echo BASH:     "%BASH%"
  echo GIT_ROOT: "%GIT_ROOT%"
  echo Comproba que exista "%GIT_ROOT%\usr\bin".
  exit /b 1
)

"%BASH%" "%~dp0sincronizar-extension.sh" %*
exit /b %ERRORLEVEL%
