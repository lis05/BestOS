# stop on error (always good practice)
set -e

# create a FIFO file, used to manage the I/O redirection from shell
PIPE=$(mktemp -u --tmpdir ${0##*/}.XXXXXXXX)
mkfifo $PIPE
export PIPE

# attach a file descriptor to the file
exec 3<> $PIPE

# add handler to manage process shutdown
function on_exit() {
    # send command to yad through pipe
    echo "quit" >&3
    rm -f $PIPE
}
trap on_exit EXIT

amixer set Capture nocap
echo "0" > $HOME/scripts/micro-state.txt

function update_icon() {
    exec 3<> $PIPE         # just in case
    state="$(cat $HOME/scripts/micro-state.txt)"
    if [[ $state == "0" ]]; then
        echo "icon:$HOME/scripts/icons/micro-red.png" >&3
    else
        echo "icon:$HOME/scripts/icons/micro-green.png" >&3
    fi
}
export -f update_icon


# add handler for tray icon left click
function on_click() {
    exec 3<> $PIPE         # required
    state="$(cat $HOME/scripts/micro-state.txt)"
    echo "STATE " $state
    if [[ $state == "0" ]]; then
        state="1"
        amixer set Capture cap
    else
        state="0"
        amixer set Capture nocap
    fi


    echo "$state" > $HOME/scripts/micro-state.txt

    if [[ $state == "0" ]]; then
        echo "icon:$HOME/scripts/icons/micro-red.png" >&3
    else
        echo "icon:$HOME/scripts/icons/micro-green.png" >&3
    fi

    update_icon
}
export -f on_click

# add handler for right click menu Quit entry function
on_quit() {
    # signal to the script that it should end when this file is created
    echo "quit" > ./quit.txt
    exec 3<> $PIPE # required
    echo "quit" >&3
}
export -f on_quit

# Use a file to indicate a quit command to the script
# Make sure it is gone before we start the program to avoid immediate exit
rm -f quit.txt

# create the notification icon with right click menu and Quit option
yad --notification                  \
    --listen                        \
    --image="$HOME/scripts/icons/micro-red.png"  \
    --text="demo tray icon"   \
    --menu="Quit!bash -c on_quit" \
    --no-middle \
    --command="bash -c on_click" <&3 &

# allow user to end the loop from icon right click Quit menu option
while [ ! -f "quit.txt" ]; do
    #echo "Press [CTRL+C] to stop.."
    update_icon
    sleep 60
done
# clean up after quit
rm quit.txt
