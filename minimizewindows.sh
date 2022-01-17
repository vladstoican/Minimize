#!/bin/bash

FILE=/tmp/minimize.txt # keep the status of the minimized windows in a file
declare -a active_windows # global array to keep all windows ids, opened in foreground 

function minimize() {
    active_windows=() # reset the array
	currentwindowid=$(xdotool getactivewindow)
	currentdesktopid=$(xdotool get_desktop)
    
	for w in $(xdotool search --all --maxdepth 3 --desktop $currentdesktopid --name ".*"); do
	    window_state=$(xprop -id "$w"| grep "_NET_WM_STATE(ATOM)")
	    
        if [[ -n "$window_state" ]]; then
            window_hidden=$(echo "$window_state" | grep "_NET_WM_STATE_HIDDEN")
            if [[ -z "$window_hidden" ]]; then
                active_windows+=($w)
            fi
        fi
        
        # Minimize all windows. (even if are already minimized)
		if [ $w -ne $currentwindowid ] ; then
			xdotool windowminimize "$w"
	    fi
	done
}

function restore() {
	for w in ${active_windows[@]}; do
	    xdotool search --onlyvisible --name '.*' windowactivate $w
	done
}

if [[ -f $FILE ]];then
	source $FILE

	if [[ $MINIMIZE == "1" ]]; then
		MINIMIZE=0
		minimize
	else
		MINIMIZE=1
		restore
	fi
else 
	MINIMIZE=0
	minimize
fi

declare -p MINIMIZE ACTIVE > $FILE
