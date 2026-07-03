@echo off
set DIR=%~dp0

if /I "%1"=="start" goto start
if /I "%1"=="stop" goto stop
if /I "%1"=="clear" goto clear
if "%1"=="" goto start

echo Invalid command.
echo Usage: run_servers.bat [start ^| stop ^| clear]
goto end

:start
echo =========================================
echo Starting Backend API...
echo =========================================
start "EShop-Backend" cmd /k "title EShop-Backend && cd /d %DIR%backend && node server.js"

echo =========================================
echo Starting Frontend Web...
echo =========================================
start "EShop-FrontendWeb" cmd /k "title EShop-FrontendWeb && cd /d %DIR%frontend-web && npm run dev"

echo =========================================
echo Starting Frontend Admin...
echo =========================================
start "EShop-FrontendAdmin" cmd /k "title EShop-FrontendAdmin && cd /d %DIR%frontend-admin && npm run dev"

echo =========================================
echo Starting Frontend Mobile (Expo)...
echo =========================================
start "EShop-FrontendMobile" cmd /k "title EShop-FrontendMobile && cd /d %DIR%frontend-mobile && npx expo start"

echo =========================================
echo All servers are starting up in separate windows!
echo Run '.\run_servers.bat stop' to safely shut them all down.
echo =========================================
goto end

:stop
echo =========================================
echo Shutting down all EShop servers...
echo =========================================
taskkill /FI "WINDOWTITLE eq EShop-Backend*" /T /F >nul 2>&1
taskkill /FI "WINDOWTITLE eq EShop-FrontendWeb*" /T /F >nul 2>&1
taskkill /FI "WINDOWTITLE eq EShop-FrontendAdmin*" /T /F >nul 2>&1
taskkill /FI "WINDOWTITLE eq EShop-FrontendMobile*" /T /F >nul 2>&1
echo All EShop servers and their windows have been completely closed!
goto end

:clear
cls
echo Screen cleared!
goto end

:end
