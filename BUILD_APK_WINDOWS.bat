@echo off
chcp 65001 >nul
setlocal
title Amir Girgis Music - APK Builder

echo ============================================
echo       AMIR GIRGIS MUSIC - APK BUILDER
echo ============================================
echo.

where flutter >nul 2>nul
if errorlevel 1 (
  echo ERROR: Flutter is not installed or not added to PATH.
  echo Install Flutter SDK and Android Studio, then reopen this window.
  pause
  exit /b 1
)

echo [1/5] Creating Android platform files...
flutter create --platforms=android --org com.amir.girgis .
if errorlevel 1 goto failed

echo.
echo [2/5] Applying Android audio/background configuration...
copy /Y android_manifest_template.xml android\app\src\main\AndroidManifest.xml
if errorlevel 1 goto failed

echo.
echo [3/5] Downloading Flutter packages...
flutter pub get
if errorlevel 1 goto failed

echo.
echo [4/5] Generating Android launcher icons...
dart run flutter_launcher_icons
if errorlevel 1 goto failed

echo.
echo [5/5] Building release APK...
flutter build apk --release
if errorlevel 1 goto failed

echo.
echo ============================================
echo BUILD COMPLETED
echo APK location:
echo build\app\outputs\flutter-apk\app-release.apk
echo ============================================
explorer build\app\outputs\flutter-apk
pause
exit /b 0

:failed
echo.
echo BUILD FAILED. Copy the full error shown above and send it to ChatGPT.
pause
exit /b 1
