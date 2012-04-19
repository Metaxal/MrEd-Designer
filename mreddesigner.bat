@echo off
if not defined SCHEME_PATH (
  echo Environment variable SCHEME_PATH not found, trying default directory...
  if exist "c:\program files\Racket\gracket.exe" (
    set SCHEME_PATH="c:\program files\Racket"
  ) else (
    echo "Default directory not found. Exiting..."
    pause
    exit 0
  )
)

"%SCHEME_PATH%\racket.exe" main.ss

::pause
