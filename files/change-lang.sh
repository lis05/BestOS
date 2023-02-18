x="$(setxkbmap -query | grep layout)"
if [[ $x == "layout:     us" ]]; then setxkbmap ua;
else setxkbmap us
fi
