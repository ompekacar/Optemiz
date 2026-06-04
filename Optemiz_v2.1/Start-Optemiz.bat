@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title 🚀 Optemiz v2.1.0 - Akıllı Launcher

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║              🚀 OPTEMIZ v2.1.0 - LAUNCHER                   ║
echo ║          Tam Otomatik Sistem Bakım Aracı                    ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

set "ScriptPath=%~dp0Optemiz.ps1"

if not exist "%ScriptPath%" (
    echo ❌ HATA: Optemiz.ps1 dosyası bulunamadı!
    pause
    exit /b 1
)

echo [✓] Optemiz v2.1.0 scripti bulundu.
echo.

where pwsh >nul 2>nul
if %errorlevel%==0 (set "PSExec=pwsh") else (set "PSExec=powershell")

echo Yönetici izni isteniyor. Lütfen "Evet"e tıklayın...
echo.

%PSExec% -NoProfile -ExecutionPolicy Bypass -Command ^
"Start-Process %PSExec% -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%ScriptPath%\"' -Verb RunAs -Wait"

echo.
echo Optemiz v2.1.0 kapatıldı. İyi günler dileriz 👑
pause
endlocal