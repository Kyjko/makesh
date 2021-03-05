# 2021 - Kyjko (Bognár Miklós)
# make.sh - v0.1
# Brief:
#       This script provides ease-of-workflow for CUDA kernel projects using
#       NVIDIA's nvcc compiler with custom or default flags and predefined output files
#       I did not implement Makefile features that do not directly correlate 
#       to my workflow and project management style, so feel free to add/remove/modify 
#       features. I am working on extending this project to a broader field of usage.

#!/bin/bash

function cleanup() {
    echo "cleaning up..."
    rm ./*.exe  2>/dev/null
    rm ./*.o    2>/dev/null
    rm ./*.exp  2>/dev/null
    rm ./*.lib  2>/dev/null
    echo "done."
}

function cleanlog() {
    rm "./.log" 2>/dev/null
}

function check() {
    nvcc --version 1>/dev/null
    if [ $? -ne 0 ]; then
        echo "error: nvcc is not installed!"
        exit
    fi
}

function build() {
    echo "flags: $1"
    echo "compilation issued"
    nvcc kernel.cu -o app $1 2>&1 | tee -a .log

    echo "DONE!"
}

#-->entry
check
if [ "$1" == "help" ]; then
    echo ""
    echo "make.sh : the CUDA compilation makefile-replacement tool"
    echo "filename MUST be kernel.cu"
    echo "default nvcc flags"
    echo "by: Kyjko (Bognár Miklós)"

    echo "options: "
    echo "    help - display help information"
    echo "    clean - cleans up every build file and log, deleting them. Does not build!"
    echo "    customflags <flags> - compile with custom flags (error if <flags> is empty)"
    echo "    <empty> - default behavior (cleans up, then builds with default flags (specified in makesh.conf))"
    exit

elif [ "$1" == "clean" ]; then
    cleanlog
    cleanup

elif [ "$1" == "customflags" ]; then
    if [ -z "$2" ]; then
        echo "error: no flags specified!"
        exit
    fi
    build $2
    
elif [ -z "$1" ]; then 
    cleanup
    DEFAULT_FLAGS=$(<makesh.conf)
    build "$DEFAULT_FLAGS"

else
    echo "undefined option!"
    exit
fi
