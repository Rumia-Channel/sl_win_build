@echo off
setlocal

set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" (
    echo [ERROR] vswhere.exe not found: "%VSWHERE%"
    exit /b 1
)

set "VSROOT="
for /f "usebackq delims=" %%I in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do (
    set "VSROOT=%%I"
)

if not defined VSROOT (
    echo [ERROR] No suitable Visual Studio installation found.
    exit /b 1
)

if not exist "%VSROOT%\VC\Auxiliary\Build\vcvars64.bat" (
    echo [ERROR] vcvars64.bat not found under: "%VSROOT%"
    exit /b 1
)

echo [INFO] VSROOT=%VSROOT%

endlocal & call "%VSROOT%\VC\Auxiliary\Build\vcvars64.bat"
exit /b %ERRORLEVEL%