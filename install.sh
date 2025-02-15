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
        sudo apt install mpv
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
    if ! command -v portaudio &> /dev/null
    then
        echo "installing portaudio"
        brew install portaudio
    else
        echo "portaudio is already installed"
    fi
}

instl_portaudio_lnx() {
    if ! command -v portaudio &> /dev/null
    then
        echo "installing portaudio"
        sudo apt update
        sudo apt install portaudio
    else
        echo "portaudio is already installed"
    fi
}

instl_ollama_mac(){
    if ! command -v ollama &> /dev/null
    then
        echo "installing ollama"
        brew install ollama
    else
        echo "ollama is already installed"
    fi
}
instl_ollama_lnx(){
    if ! command -v ollama &> /dev/null
    then
        echo "installing ollama"
        sudo apt update
        sudo apt install ollama
    else
        echo "ollama is already installed"
    fi
}
# check to see if the operating system is known
if [ "$(uname)" = "Darwin" ]; then

    echo "This is macOS."
    instl_mpv_mac
    instl_portaudio_mac
    instl_ollama_mac

elif [ "$(uname)" = "Linux" ]; then
    # On Linux, we can check /etc/os-release for distribution details
    if [ -f /etc/os-release ]; then
        . /etc/os-release  # source it to get $ID, $NAME, etc.
        if [ "$ID" = "ubuntu" ]; then
            echo "This is Ubuntu."
            instl_mpv_lnx
            instl_portaudio_lnx
            instl_ollama_lnx
        else
            echo "This is Linux, but not Ubuntu (distro: $NAME)."
            return
        fi
    else
        echo "This is Linux (no /etc/os-release found)."
    fi
else
    echo "Unsupported or unknown OS: $(uname)"
    return
fi


echo "installing mpv for audio playback and portaudio for the microphone"


