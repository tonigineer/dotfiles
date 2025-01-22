#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
cd "$SCRIPT_DIR" || exit

git submodule update --init --recursive

function command_exists() {
  command -v "$1" &> /dev/null
}

function run_stow() {
  stow -v -R -t "$HOME" "$1"
}

function bootstrapping() {
  if ! command_exists yay; then
    echo "Installing yay from AUR..."
    cd /opt || exit
    sudo git clone https://aur.archlinux.org/yay.git
    sudo chown -R "$(whoami):$(id -gn)" ./yay
    cd yay || exit
    makepkg -si
  fi

  if ! command_exists stow; then
    echo "Installing stow..."
    sudo pacman -S --needed stow
  fi
}

bootstrapping


#
function Hyprland() {
  echo "Installing bare Hyprland..."
  yay -S hyprland kitty ttf-cascadia-code-nerd ttf-jetbrains-mono-nerd
  run_stow hyprland
}
#
# configure_vim() {
#   echo "Configuring Vim..."
#   run_stow vim
# }
#
# configure_bash() {
#   echo "Configuring Bash..."
#   yay -S --needed curl wget eza zip unzip tar
#   run_stow bash
# }
#
# configure_yazi() {
#   echo "Configuring Yazi..."
#   yay -S --needed yazi
# }
#
# install_zsh() {
#     if $1 == "get_state";then
#         [[ -h ~/.config/zsh ]] \
#   && yay -Qa | grep -q zsh \
#   && echo "off" \
#   || echo "on"
#         exit
#     fi
#         yay -Qa | grep zsh &&
#   echo "Installing Zsh..."
#   yay -S --needed zsh
#   run_stow zsh
# }
#
# install_nvim() {
#   echo "Installing Neovim and npm..."
#   yay -S --needed neovim npm
# }
#
#
# zsh_state="$([[ -h ~/.config/zsh ]] && yay -Qa | grep zsh>/dev/null & echo "off" | echo "on")"
#
# declare -A TASK_STATE=(
#   [install_hyprland]="off"
#   [configure_vim]="off"
#   [configure_bash]="off"
#   [configure_yazi]="off"
#   [install_zsh]=$zsh_state
#   [install_nvim]="off"
# )

# # Define your functions
# function greet() {
#     echo "Hello! Hope you're having a great day!"
# }
#
# function show_date() {
#     echo "Today's date is: $(date)"
# }
#
# function list_files() {
#     echo "Files in the current directory:"
#     ls -lh
# }
#
# function exit_script() {
#     echo "Exiting the script. Goodbye!"
#     exit 0
# }
#
# # Display the menu using column
# function display_menu() {
#     echo "Select an option:"
#     echo "1) Greet User"
#     echo "2) Show Date"
#     echo "3) List Files"
#     echo "4) Exit"
#     echo
# }
#
# # Main script loop
# while true; do
#     clear
#     display_menu | column -t
#     read -p "Enter your choice [1-4]: " choice
#
#     case $choice in
#         1)
#             greet
#             ;;
#         2)
#             show_date
#             ;;
#         3)
#             list_files
#             ;;
#         4)
#             exit_script
#             ;;
#         *)
#             echo "Invalid choice. Please select a valid option."
#             ;;
#     esac
#
#     echo
#     read -p "Press Enter to return to the menu..."
# done
#
#
#
#
#





function get_functions() {
    declare -F | awk '{print $3}' | grep -v -E "command_exists|bootstrapping|run_stow|get_functions|display_menu|run_function"
}

# Display the menu dynamically
function display_menu() {
    # echo "Select an option:"
    local i=1
    for func in $(get_functions); do
        echo "$i) $func"
        ((i++))
    done
    echo "$i) Exit"
}

function run_function() {
    local choice=$1
    local funcs=($(get_functions))
    local total_funcs=${#funcs[@]}

    if [[ $choice -gt 0 && $choice -le $total_funcs ]]; then
        ${funcs[$choice-1]}
    elif [[ $choice -eq $((total_funcs + 1)) ]]; then
        exit_script
    else
        echo "Invalid choice. Please select a valid option."
    fi
}

while true; do
    clear
    display_menu | column -t
    read -p "Enter your choice: " choice
    run_function "$choice"
    echo
    read -p "Press Enter to return to the menu..."
done
