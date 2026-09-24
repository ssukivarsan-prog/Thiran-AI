@echo off
echo ====================================================
echo Starting Jeevika AI Flutter Web App (Port 3000)...
echo ====================================================
cd /d "%~dp0..\web_flutter"
flutter run -d chrome --web-port 3000
