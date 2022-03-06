@echo off
del GFXX_TB.EXE
bpc -Q -B -U.. GFXX_TB.PAS

if errorlevel 1 goto end
GFXX_TB.EXE

:end
echo.
