@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title 🚀 Optemiz v2.1.3 - Akıllı Launcher

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║              🚀 OPTEMIZ v2.1.3 - LAUNCHER                   ║
echo ║          Tam Otomatik Sistem Bakım Aracı                    ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

set "ScriptPath=%~dp0Optemiz.ps1"

if not exist "%ScriptPath%" (
    echo ❌ HATA: Optemiz.ps1 dosyası bulunamadı!
    echo.
    echo Lütfen kontrol edin:
    echo   - Optemiz.ps1 dosyasının script ile aynı klasörde olduğundan emin olun
    echo   - Dosya adı yazılı olarak Optemiz.ps1 olmalıdır
    echo.
    pause
    exit /b 1
)

echo [✓] Optemiz v2.1.3 scripti bulundu.
echo.

:: PowerShell sürümünü seç (pwsh varsa kullan, yoksa powershell)
where pwsh >nul 2>nul
if %errorlevel%==0 (set "PSExec=pwsh") else (set "PSExec=powershell")

echo [✓] PowerShell sürümü: %PSExec%
echo.

echo ⏳ Yönetici izni isteniyor. Lütfen "Evet"e tıklayın...
echo.

:: Yönetici olarak çalıştır
%PSExec% -NoProfile -ExecutionPolicy Bypass -Command ^
"Start-Process %PSExec% -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%ScriptPath%\"' -Verb RunAs -Wait"

:: Hata kontrolü
if %errorlevel% neq 0 (
    echo.
    echo ⚠️  Bir hata oluştu. Detaylar için yukarıdaki kırmızı satırı inceleyin.
    echo.
    echo Sorun devam ederse:
    echo   1. PowerShell'i Yönetici olarak açın
    echo   2. Şu komutu yazın:
    echo      powershell -NoProfile -ExecutionPolicy Bypass -File "%ScriptPath%"
    echo.
)

echo.
echo ✅ Optemiz v2.1.3 kapatıldı. İyi günler dileriz 👑
echo.
pause
endlocal
exit /b 0