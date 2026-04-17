@echo off
title Awesome-Bear Windows Installer
color 0A

echo ================================================
echo    🐻 AWESOME-BEAR WINDOWS INSTALLATION
echo         Cybersecurity Command Center
echo ================================================
echo.

:: Check for Administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [WARNING] Not running as Administrator!
    echo Some features may be limited.
    echo For full functionality, right-click and select "Run as Administrator"
    echo.
)

:: Check Python installation
echo [INFO] Checking Python installation...
python --version >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Python not found!
    echo Please install Python 3.7+ from https://python.org
    echo Make sure to check "Add Python to PATH" during installation
    pause
    exit /b 1
)

:: Get Python version
for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VER=%%i
echo [OK] Python %PYTHON_VER% found

:: Check Python version (3.7+ required)
python -c "import sys; sys.exit(0 if sys.version_info >= (3,7) else 1)"
if %errorLevel% neq 0 (
    echo [ERROR] Python 3.7+ required!
    echo Current version: %PYTHON_VER%
    pause
    exit /b 1
)

:: Upgrade pip
echo [INFO] Upgrading pip...
python -m pip install --upgrade pip

:: Install requirements
echo [INFO] Installing Python dependencies...
if exist requirements.txt (
    pip install -r requirements.txt
) else (
    echo [ERROR] requirements.txt not found!
    pause
    exit /b 1
)

:: Create directories
echo [INFO] Creating directory structure...
set AWESOMEBEAR_DIR=%USERPROFILE%\.awesomebear

if not exist "%AWESOMEBEAR_DIR%" mkdir "%AWESOMEBEAR_DIR%"
if not exist "%AWESOMEBEAR_DIR%\payloads" mkdir "%AWESOMEBEAR_DIR%\payloads"
if not exist "%AWESOMEBEAR_DIR%\workspaces" mkdir "%AWESOMEBEAR_DIR%\workspaces"
if not exist "%AWESOMEBEAR_DIR%\scans" mkdir "%AWESOMEBEAR_DIR%\scans"
if not exist "%AWESOMEBEAR_DIR%\nikto_results" mkdir "%AWESOMEBEAR_DIR%\nikto_results"
if not exist "%AWESOMEBEAR_DIR%\whatsapp_session" mkdir "%AWESOMEBEAR_DIR%\whatsapp_session"
if not exist "%AWESOMEBEAR_DIR%\phishing_pages" mkdir "%AWESOMEBEAR_DIR%\phishing_pages"
if not exist "%AWESOMEBEAR_DIR%\traffic_logs" mkdir "%AWESOMEBEAR_DIR%\traffic_logs"
if not exist "%AWESOMEBEAR_DIR%\phishing_templates" mkdir "%AWESOMEBEAR_DIR%\phishing_templates"
if not exist "%AWESOMEBEAR_DIR%\captured_credentials" mkdir "%AWESOMEBEAR_DIR%\captured_credentials"
if not exist "%AWESOMEBEAR_DIR%\ssh_keys" mkdir "%AWESOMEBEAR_DIR%\ssh_keys"
if not exist "%AWESOMEBEAR_DIR%\ssh_logs" mkdir "%AWESOMEBEAR_DIR%\ssh_logs"
if not exist "%AWESOMEBEAR_DIR%\time_history" mkdir "%AWESOMEBEAR_DIR%\time_history"
if not exist "%AWESOMEBEAR_DIR%\wordlists" mkdir "%AWESOMEBEAR_DIR%\wordlists"
if not exist "%AWESOMEBEAR_DIR%\custom_phishing" mkdir "%AWESOMEBEAR_DIR%\custom_phishing"

echo [OK] Directories created

:: Create default configuration
echo [INFO] Creating default configuration...
(
echo {
echo     "monitoring": {
echo         "enabled": true,
echo         "port_scan_threshold": 10
echo     },
echo     "scanning": {
echo         "default_ports": "1-1000",
echo         "timeout": 30
echo     },
echo     "security": {
echo         "auto_block": false,
echo         "log_level": "INFO"
echo     },
echo     "nikto": {
echo         "enabled": true,
echo         "timeout": 300
echo     },
echo     "traffic_generation": {
echo         "enabled": true,
echo         "max_duration": 300,
echo         "allow_floods": false
echo     },
echo     "social_engineering": {
echo         "enabled": true,
echo         "default_port": 8080,
echo         "capture_credentials": true
echo     },
echo     "ssh": {
echo         "enabled": true,
echo         "default_timeout": 30,
echo         "max_connections": 5
echo     }
echo }
) > "%AWESOMEBEAR_DIR%\config.json"

echo [OK] Configuration created

:: Create batch launcher
echo [INFO] Creating launcher script...

(
echo @echo off
echo title Awesome-Bear Command Center
echo color 0B
echo python "%~dp0awesomebear.py"
echo pause
) > "launch_awesomebear.bat"

:: Create desktop shortcut (PowerShell)
echo [INFO] Creating desktop shortcut...

powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\Awesome-Bear.lnk'); $Shortcut.TargetPath = '%CD%\launch_awesomebear.bat'; $Shortcut.WorkingDirectory = '%CD%'; $Shortcut.IconLocation = 'shell32.dll,41'; $Shortcut.Save()"

:: Check for nmap
echo [INFO] Checking for optional tools...
where nmap >nul 2>&1
if %errorLevel% neq 0 (
    echo [WARNING] Nmap not found in PATH
    echo Download from: https://nmap.org/download.html
)

:: Check for nikto
where nikto >nul 2>&1
if %errorLevel% neq 0 (
    echo [WARNING] Nikto not found
    echo Perl version available at: https://github.com/sullo/nikto
)

:: Create firewall rule for web interface
echo [INFO] Creating Windows Firewall rule for port 8080...
netsh advfirewall firewall add rule name="Awesome-Bear Web Interface" dir=in action=allow protocol=TCP localport=8080 >nul 2>&1

echo.
echo ================================================
echo    ✅ AWESOME-BEAR INSTALLATION COMPLETE!
echo ================================================
echo.
echo 🚀 Quick Start:
echo    Double-click "launch_awesomebear.bat"
echo    or run: python awesomebear.py
echo.
echo 🌐 Web Interface:
echo    http://localhost:8080
echo.
echo 📁 Configuration Directory:
echo    %AWESOMEBEAR_DIR%
echo.
echo 📝 Log File:
echo    %AWESOMEBEAR_DIR%\awesomebear.log
echo.
echo ⚠️  For full functionality, run as Administrator!
echo.
pause