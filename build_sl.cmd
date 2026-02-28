@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "BUILD_DIR=%SCRIPT_DIR%build"

echo [INFO] SCRIPT_DIR=%SCRIPT_DIR%
echo [INFO] BUILD_DIR=%BUILD_DIR%

call "%SCRIPT_DIR%get_vs_env.cmd" || exit /b 1

cd /d "%SCRIPT_DIR%" || exit /b 1

call "%SCRIPT_DIR%download.cmd" || exit /b 1

if not exist "%SL_DIR%\" (
    echo [ERROR] sl directory not found: "%SL_DIR%"
    exit /b 1
)

if exist "%BUILD_DIR%" rd /s /q "%BUILD_DIR%"
md "%BUILD_DIR%" || exit /b 1
cd /d "%BUILD_DIR%" || exit /b 1

cmake -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release .. || exit /b 1
nmake || exit /b 1

if not exist "%BUILD_DIR%\sl.exe" (
    echo [ERROR] sl.exe not found: "%BUILD_DIR%\sl.exe"
    exit /b 1
)

"%BUILD_DIR%\sl.exe"

pause
endlocal