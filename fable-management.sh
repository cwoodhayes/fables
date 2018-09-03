#!/bin/bash

#start a fable
fable() {
        pushd ~/fables > /dev/null
        ./start-$1.sh "${@:2}"
        popd > /dev/null
}

#quickly control which monitors are enabled
monitor() {
        if [ "$1" = 'left' ]; then
                xrandr --output HDMI-2 --off --output HDMI-1 --auto
                echo "LEFT =ON"
                echo "RIGHT=OFF"
        elif [ "$1" = 'right' ]; then
                xrandr --output HDMI-1 --off --output HDMI-2 --auto
                echo "LEFT =OFF"
                echo "RIGHT=ON"
        elif [ "$1" = 'both' ]; then
                xrandr --output HDMI-2 --auto --output HDMI-1 --auto --left-of HDMI-2
                echo "LEFT =ON"
                echo "RIGHT=ON"
        else
                echo "invalid command. select from left, right, or both"
                return 1
        fi
}
