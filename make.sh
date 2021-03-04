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
    rm ./*.log 2>/dev/null
}

function build() {
    echo "flags: $1"
    echo "compilation issued"
    nvcc kernel.cu -o app $1

    if [ $? -ne 0 ]; then
        echo "error in compilation! - nvcc"
        echo "compilation terminated (failure)"
        exit
    else
        echo "compilation finished (success)"
    fi

    echo "DONE!"
}

#-->entry
if [ "$1" == "help" ]; then
    echo ""
    echo "make.sh : the CUDA compilation makefile-replacement tool"
    echo "filename MUST be kernel.cu"
    echo "default nvcc flags"
    echo "by: Kyjko (Bognár Miklós)"

    echo "options: "
    echo "    help - display help information"
    echo "    clean - cleans up every build file, deleting them. Does not build!"
    echo "    customflags <flags> - compile with custom flags (error if <flags> is empty)"
    echo "    defaultflags - compile with default flags - you can specify the default flags in the makesh.conf file"
    echo "    <empty> - default behavior (cleans up, then builds)"
    exit

elif [ "$1" == "clean" ]; then
    cleanup

elif [ "$1" == "customflags" ]; then
    if [ -z "$2" ]; then
        echo "error: no flags specified!"
        exit
    fi
    build $2
elif [ "$1" == "defaultflags" ]; then
    DEFAULT_FLAGS=$(<makesh.conf)
    build "$DEFAULT_FLAGS"

elif [ -z "$1" ]; then 
    cleanup
    build

else
    echo "undefined option!"
    exit
fi
