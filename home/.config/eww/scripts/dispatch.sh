#!/usr/bin/env bash

active_monitor=$(hyprctl monitors -j | jq '.[] | select(.focused == true).id')
passive_monitor=$(hyprctl monitors -j | jq '.[] | select(.focused == false).id')
# active_workspace=$(hyprctl monitors -j | jq '.[] | select(.focused == true).activeWorkspace.id')
# passive_workspace=$(hyprctl monitors -j | jq '.[] | select(.focused == false).activeWorkspace.id')

# echo $active_monitor $passive_monitor $active_workspace $passive_workspace

case $2 in
--focus-workspace)
	echo "$1 $active_monitor"
	hyprctl dispatch moveworkspacetomonitor "$1 $active_monitor"
	hyprctl dispatch workspace "$1"
	;;
--move-workspace)
	hyprctl dispatch moveworkspacetomonitor "$1 $passive_monitor"
	hyprctl dispatch focusmonitor "$passive_monitor"
	hyprctl dispatch workspace "$1"
	;;
"")
	echo "No mode as second argument given, --focus-workspace or --move-workspace."
	;;
*)
	echo "Mode \`$2\` not defined."
	;;
esac
