#!/bin/bash

# git the PID of the currently active window
# if you are not using hyprland, you can change this 
# line for it to match your needs
ACTIVE_PID=$(hyprctl activewindow | awk '/pid:/ {print $2}')
# If no active window, start in home directory
if [[ -z "$ACTIVE_PID" ]]; then
    alacritty
    exit 0
fi

# (The CDW is in the shell process, not the terminal itself) 
# Find the child process of the active window
CHILD_PID=$(pgrep -P "$ACTIVE_PID" -o)
if [[ -z "$CHILD_PID" ]]; then
    alacritty
    exit 0
fi

# Get the name of the process
PROCESS_NAME=$(ps -p "$CHILD_PID" -o comm=)

# Check if the process is a terminal shell or terminal emulator
# you might want to add a different one in the regex here
if [[ "$PROCESS_NAME" =~ (bash|zsh|fish|xterm) ]]; then
    # Get the current working directory of the shell process
    SHELL_CWD=$(pwdx "$CHILD_PID" | cut -d ' ' -f2-)
    if [[ -n "$SHELL_CWD" && -d "$SHELL_CWD" ]]; then
        alacritty --working-directory "$SHELL_CWD"
        exit 0
    fi
fi

# If no terminal is detected, starts in home
alacritty
exit 0


