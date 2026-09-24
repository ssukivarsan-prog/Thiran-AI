@echo off
echo ====================================================
echo Running Jeevika AI Full Monorepo Test Suites
echo ====================================================

echo [1/3] Running Backend API Tests...
cd /d "%~dp0..\backend"
call npm test
if %errorlevel% neq 0 (
  echo Backend tests failed!
  exit /b %errorlevel%
)

echo.
echo [2/3] Running Mobile Flutter Tests...
cd /d "%~dp0..\mobile_flutter"
call flutter test
if %errorlevel% neq 0 (
  echo Mobile Flutter tests failed!
  exit /b %errorlevel%
)

echo.
echo [3/3] Running Web Flutter Tests...
cd /d "%~dp0..\web_flutter"
call flutter test
if %errorlevel% neq 0 (
  echo Web Flutter tests failed!
  exit /b %errorlevel%
)

echo.
echo ====================================================
echo All Jeevika AI Tests Passed Successfully!
echo ====================================================
