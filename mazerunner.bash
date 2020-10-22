#!/bin/bash

SERVER="localhost:1337"

function startMaze() {

    echo "Waiting on server to start.."
    sleep 1
    echo "The maze server is now listening on: 1337"
    sleep 2
	
}

cleanExit() {
    # Kill all nodejs background processes
    kill -HUP $(pgrep -x nodejs)
    exit 0
}
function init() {
	curl -s "$SERVER?type=csv" > "gamestatus.txt"
	cat "gamestatus.txt" | tail -1 | cut -d ',' -f2 > "gameid.txt"
	cat "gamestatus.txt"
}
function maps() {
	curl -s "$SERVER/map?type=csv" > "maps.txt"
	map1=$(cat "maps.txt" | tail -1 | cut -d ',' -f1)
	map2=$(cat "maps.txt" | tail -1 | cut -d ',' -f2)
	echo "1. $map1"
	echo "2. $map2"
	echo ""
	echo "use 'mazerunner select # to choose map'"
	echo ""
}
function maps1() {
    curl -s "$SERVER/map?type=csv" > "maps.txt"
    map1=$(cat "maps.txt" | tail -1 | cut -d ',' -f1)
    map2=$(cat "maps.txt" | tail -1 | cut -d ',' -f2)
    echo "1. $map1"
    echo "2. $map2"
    echo ""
    echo "choose map and press enter: "
    read choice
        if [ "$choice" = "1" ];then
            selectMap "1"
        elif [ "$choice" = "2" ]; then
            selectMap "2"
        fi
    enter
}

function selectMap() {
	id=$(cat "gameid.txt")
	map=$(cat "maps.txt" | tail -1 | cut -d ',' -f"$1")
	curl -s "$SERVER/$id/map/$map" > /dev/null 
	echo "You selected: $map"
}

function getAvailableRooms() {
	for val in 3 4 5 6;
	do
		temp=$(cat "info.txt" | tail -1 | cut -d ',' -f"$val")
		if [ "$temp" = "-" ];then
			continue
		else
			holder=$(cat "info.txt" | tail -2 | cut -d ',' -f"$val")
			rooms="$rooms $holder"
		fi
	done
	echo $rooms
}

function enter() {
	id=$(cat "gameid.txt")
	if [ -z "$1" ];then
		curl -s "$SERVER/$id/maze?type=csv" > "info.txt"
	fi
	roomid=$(cat "info.txt" | tail -1 | cut -d ',' -f1)
	desc=$(cat "info.txt" | tail -1 | cut -d ',' -f2)

	echo "You are in room: $roomid"
	echo "Description: $desc"
    echo ""
	echo "You can go to: $(getAvailableRooms)"
	echo ""
}

function go() {
	id=$(cat "gameid.txt")
	currRoom=$(cat "info.txt" | tail -1 | cut -d ',' -f1)
	curl -s "$SERVER/$id/maze/$currRoom/$1?type=csv" > "info.txt"
	enter $currRoom
	echo ""
}
function info() {
	currRoom=$(cat "info.txt" | tail -1 | cut -d ',' -f1)
	enter $currRoom
	echo ""
}
function loop() {
        echo "Enter command:('help' for help, 'done' to quit)"

        read inp

        if [ "$inp" == "west" ]; then
                go "west"
        elif [ "$inp" == "east" ]; then
                go "east"
        elif [ "$inp" == "north" ]; then
                go "north"
        elif [ "$inp" == "south" ]; then
                go "south"
        elif [ "$inp" == "done" ]; then
                echo "No one remembers a coward..."
                cleanExit
        elif [ "$inp" == "exit" ]; then
                echo "No one remembers a coward..."
                cleanExit
        elif [ "$inp" == "help" ]; then
                echo "example: move west = west"
        else
                echo "I don't understand"
        fi
    loop
}

function usage() {
    echo ""
    echo "Usage: mazerunner2 [command]"
    echo ""
    echo "Commands:"
    echo "loop                Starts the main loop"
    echo ""
}
while (($#))
do
	case "$1" in

		init)
			init
			shift
			exit 0
		;;

		maps)
			maps
			shift
			exit 0
		;;

		select)
			selectMap "$2"
			shift
			exit 0
		;;

		enter)
			enter
			shift
			exit 0
		;;
        info)
			info
			shift
			exit 0
		;;
		go)
			go "$2"
			shift
			exit 0
		;;
         loop)
            clear
            startMaze
            echo "** MAZERUNNER **"
            echo ""
            echo "Initializes new game..."
            echo ""
            init
            echo ""
            echo "Setting up the maps..."
            echo ""
            maps1
            echo ""
            loop
            shift
            cleanExit
        ;;

		*)
			shift
			;;

	esac
done

usage
cleanExit