@echo off
del KB_TB.EXE
bpc -B -U.. -U..\dos -i..\inc KB_TB.PAS

if errorlevel 1 goto end
KB_TB.EXE

:end
echo.
