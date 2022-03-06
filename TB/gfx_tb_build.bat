@echo off
del GFX_TB.EXE
bpc -Q -B -U.. GFX_TB.PAS

if errorlevel 1 goto end
GFX_TB.EXE

:end
echo.
