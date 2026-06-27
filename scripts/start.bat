@echo off
setlocal

REM Ensure we are in the project root directory
cd /d "%~dp0.."

echo =============================================
echo   Gemini AI Hackathon - Starting Application  
echo =============================================

REM 1. Check/Setup Virtual Environment
if exist ".venv\Scripts\activate.bat" goto :venv_exists

echo [*] Virtual environment (.venv) not found. Creating one...
where uv >nul 2>nul
if %errorlevel% equ 0 goto :use_uv

echo [-] 'uv' not found. Initializing virtual environment via standard python...
python -m venv .venv
if %errorlevel% neq 0 goto :venv_fail
call .venv\Scripts\activate.bat
pip install -r requirements.txt
goto :venv_done

:use_uv
echo [+] 'uv' detected, initializing virtual environment via uv...
uv venv .venv
if %errorlevel% neq 0 goto :venv_fail
call .venv\Scripts\activate.bat
uv pip install -r requirements.txt
goto :venv_done

:venv_exists
echo [+] Virtual environment (.venv) detected.
call .venv\Scripts\activate.bat

:venv_done

REM 2. Check Environment Variables / .env
if not exist ".env" goto :no_env

findstr /c:"GEMINI_API_KEY=YOUR_GEMINI_API_KEY_HERE" .env >nul
if %errorlevel% equ 0 (
    echo [!] Warning: GEMINI_API_KEY is not configured in .env!
    echo     Please update the GEMINI_API_KEY in your .env file.
) else (
    echo [+] GEMINI_API_KEY detected in .env file.
)
goto :env_done

:no_env
echo [!] Warning: .env file not found! Copying from .env.example...
copy .env.example .env >nul
echo     Please update the GEMINI_API_KEY in the newly created .env file.

:env_done

REM 3. Start the application
echo [*] Starting Flask Application (app.py) on port 8080...
python app.py
goto :eof

:venv_fail
echo [!] Error: Failed to create virtual environment. Please install Python and try again.
pause
exit /b 1
