#!/bin/bash
#
# From https://github.com/openmsa/etsi-mano-root/blob/master/do.sh
#
# Creation: 20/06/2024
# Author: BAT
# Description: Use this script to execute a GIT command (among a specific list) on each
#		subdirectory of the current dir (name of subdirs must start with etsi-*)

##
##  CONSTANT & GLOBALS
##
TEMP_DIR=$(mktemp -d)

DEV_NULL="/dev/null"

# List of valid git commands
VALID_GIT_COMMANDS=("fetch" "grep" "log" "pull" "show" "status" "tag")

# The built GIT cmd with the argument
GIT_CMD="git $*"

# Extract the first argument to check if it's a valid git command
GIT_SUBCOMMAND="$1"

# Array to store all the filenames of the temp files used
TEMP_LOG_FILES=()

# Array to store all the PIDs of the children process which execute git cmd on directories
PIDS=()

# Store the total number of git subdir we find
COUNT=0

# Store the number of git tasks already completed, starting at 0
COMPLETED=0

##
##  FUNCTIONS
##

count_completed_git_task() {
    # Reset nb of completed as we count all of them each time
    COMPLETED=0

    for pid in "${PIDS[@]}"; do
        if ! kill -0 "$pid" 2>"$DEV_NULL"; then
            COMPLETED=$((COMPLETED + 1))
        fi
    done
}

# Function to display a progress icon with counter
show_progress() {
    local total=$1
    local delay=0.1
    local spinstr='|/-\'

    while :; do
        count_completed_git_task

        local temp=${spinstr#?}
        printf " %c [%d/%d]  " "$spinstr" "$COMPLETED" "$total"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b"

        if [ "$COMPLETED" -eq "$total" ]; then
            break
        fi
    done
    printf "    \b\b\b\b"
}

exec_gitcmd_on_dir() {
    local directory=$1

    echo "*************************************************************************"
    echo "        Performing [$GIT_CMD] on $directory"
    echo
    pushd "$directory" >"$DEV_NULL"
    eval "$GIT_CMD"
    popd >"$DEV_NULL"
    echo
}

loop_git_directories() {
    for d in $(find . -maxdepth 1 -type d -name 'etsi-*'); do
        if [ -d "$d" ]; then
            # Create a temp file to store the ouput
            temp_file=$(mktemp --tmpdir="$TEMP_DIR")
            TEMP_LOG_FILES+=("$temp_file")
            COUNT=$((COUNT + 1))

            (exec_gitcmd_on_dir "$d") &>"$temp_file" &
            PIDS+=($!)
        fi
    done
}

show_result_and_cleanup() {
    for temp_log in "${TEMP_LOG_FILES[@]}"; do
        cat "$temp_log"
    done
    rm -rf "$TEMP_DIR"
}

##
##  MAIN
##

if [ -z "$*" ]; then
    echo "No git command provided"
    exit 1
fi

if [[ ! " ${VALID_GIT_COMMANDS[@]} " =~ " ${GIT_SUBCOMMAND} " ]]; then
    echo "Invalid git command: $GIT_SUBCOMMAND"
    exit 1
fi

# MAIN: execute the git cmd over all directories
loop_git_directories

# Run the progress icon in the background
show_progress "$COUNT" &
progress_pid=$!

wait

# Kill the progress icon process
kill $progress_pid 2>"$DEV_NULL"

show_result_and_cleanup

exit 0
