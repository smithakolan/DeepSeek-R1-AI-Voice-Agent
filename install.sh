#!/usr/bin/env bash

set -e  # exit on error

instl_hombrew(){
    echo "Homebrew is not installed. Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

instl_mpv_mac(){
    if ! command -v brew &> /dev/null
    then
        echo "installing homebrew"
        instl_hombrew
    fi
    if ! command -v mpv &> /dev/null
    then
        echo "installing mpv"
        brew install mpv
    else 
        echo "mpv is already installed"
    fi  
}

instl_mpv_lnx(){
    if ! command -v mpv &> /dev/null 
    then
        echo "installing mpv"
        sudo apt update
        sudo apt install -y mpv
    else
        echo "mpv is already installed"
    fi
}

instl_portaudio_mac (){
    if ! command -v brew &> /dev/null
    then
        echo "installing homebrew"
        instl_hombrew
    fi
    # portaudio is a library, so the brew package is named "portaudio"
    if ! brew list portaudio &> /dev/null
    then
        echo "installing portaudio"
        brew install portaudio
    else
        echo "portaudio is already installed"
    fi
}

instl_portaudio_lnx() {
    if ! dpkg -l | grep -q "portaudio"; then
        echo "installing portaudio"
        sudo apt update
        sudo apt install -y portaudio19-dev
    else
        echo "portaudio is already installed"
    fi
}

instl_ollama_mac(){
    if ! command -v brew &> /dev/null
    then
        echo "installing homebrew"
        instl_hombrew
    fi
    if ! command -v ollama &> /dev/null
    then
        echo "installing ollama"
        brew install ollama
    else
        echo "ollama is already installed"
    fi
}

instl_ollama_lnx(){
    # The name of the apt package for Ollama may vary or may not exist in standard repos.
    # If there is an official .deb or instructions, place them here.
    # For illustration, let's assume there's a PPA or direct apt source:
    if ! command -v ollama &> /dev/null
    then
        echo "Installing Ollama (Linux). Adjust this block if there's a different install method."
        # Example approach - change to your actual install steps:
        sudo apt update
        sudo apt install -y ollama
    else
        echo "ollama is already installed"
    fi
}

pull_deepseek_r1() {
    # Only pull the model if Ollama is installed
    if command -v ollama &> /dev/null
    then
        echo "Pulling DeepSeek R1 model via Ollama..."
        # Adjust the model identifier as needed, e.g. 'deepseek-r1' or a full repo reference.
        ollama pull deepseek-r1
    else
        echo "Skipping DeepSeek R1 model pull because Ollama is not installed."
    fi
}

# Detect OS
if [ "$(uname)" = "Darwin" ]; then
    echo "This is macOS."
    instl_mpv_mac
    instl_portaudio_mac
    instl_ollama_mac

elif [ "$(uname)" = "Linux" ]; then
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$ID" = "ubuntu" ]; then
            echo "This is Ubuntu."
            instl_mpv_lnx
            instl_portaudio_lnx
            instl_ollama_lnx
        else
            echo "This is Linux, but not Ubuntu (distro: $NAME)."
            exit 0
        fi
    else
        echo "This is Linux (no /etc/os-release found)."
        exit 0
    fi
else
    echo "Unsupported or unknown OS: $(uname)"
    exit 0
fi

echo "Installing mpv for audio playback and portaudio for the microphone (done)."

# Finally, pull the DeepSeek R1 model
pull_deepseek_r1

python -m venv open_agent 
source open_agent/bin/activate
python -m pip install -r requirements.txt 


echo "All installations complete."
