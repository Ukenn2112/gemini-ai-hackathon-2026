#!/bin/bash

# Ensure we are in the project root directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR/.."

echo -e "\033[0;36m=============================================\033[0m"
echo -e "\033[0;36m  Gemini AI Hackathon - Starting Application  \033[0m"
echo -e "\033[0;36m=============================================\033[0m"

VENV_DIR="./.venv"

# 1. Check/Setup Virtual Environment
if [ ! -d "$VENV_DIR" ]; then
    echo -e "\033[0;33m[*] Virtual environment (.venv) not found. Creating one...\033[0m"
    if command -v uv &> /dev/null; then
        echo -e "\033[0;32m[+] 'uv' detected, initializing virtual environment via uv...\033[0m"
        uv venv .venv
        source .venv/bin/activate
        uv pip install -r requirements.txt
    else
        echo -e "\033[0;33m[-] 'uv' not found. Initializing virtual environment via standard python...\033[0m"
        python3 -m venv .venv
        source .venv/bin/activate
        pip install -r requirements.txt
    fi
else
    echo -e "\033[0;32m[+] Virtual environment (.venv) detected.\033[0m"
    source .venv/bin/activate || source .venv/Scripts/activate 2>/dev/null
fi

# 2. Check Environment Variables / .env
ENV_FILE="./.env"
if [ -f "$ENV_FILE" ]; then
    if grep -q "GEMINI_API_KEY=YOUR_GEMINI_API_KEY_HERE" "$ENV_FILE" || grep -q "GEMINI_API_KEY=$" "$ENV_FILE"; then
        echo -e "\033[0;31m[!] Warning: GEMINI_API_KEY is not configured in .env!\033[0m"
        echo -e "\033[0;33m    Please update the GEMINI_API_KEY in your .env file.\033[0m"
    else
        echo -e "\033[0;32m[+] GEMINI_API_KEY detected in .env file.\033[0m"
    fi
else
    echo -e "\033[0;33m[!] Warning: .env file not found! Copying from .env.example...\033[0m"
    cp .env.example .env 2>/dev/null
    echo -e "\033[0;33m    Please update the GEMINI_API_KEY in the newly created .env file.\033[0m"
fi

# 3. Start the application
echo -e "\033[0;36m[*] Starting Flask Application (app.py) on port 8080...\033[0m"
python app.py
