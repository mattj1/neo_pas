@echo off
del GFX_TB.EXE
bpc -Q -B GFX_TB.PAS

if errorlevel 1 goto end
GFX_TB.EXE

:end
echo.
