# FUNCTION create_symlink
#
# Usage
#   source utils.sh
#   create_symlink /source/path /target/path
#
cd "$(dirname "$0")" || exit
REPO_DIR=$(git rev-parse --show-toplevel)

function target_dir() { echo "/home/$USER/$1"; }
function source_dir() { echo "$REPO_DIR/home/$1"; }

create_symlink() {
	SOURCE=$(source_dir "$1")
	TARGET=$(target_dir "$1")

	if [[ (-f "$TARGET" || -d "$TARGET") && ! -L "$TARGET" ]]; then
		mv "${TARGET}" "${TARGET}_backup"
		echo -e "$(color  red) $(color "${TARGET}" magenta) was backuped into $(color "${TARGET}_backup" white)"
	fi

	if [[ -L "$TARGET" ]]; then
		if [ ! "$(readlink -- "$TARGET")" = "$SOURCE" ]; then
			echo -e "$(color  yellow) Symlink for $(color "${SOURCE}" white) exists, but from different target"
			rm "${TARGET}"
		else
			echo -e "$(color  green)  $(color "${SOURCE}" white) is already linked to $(color "${TARGET}" white)"
			return
		fi
	fi
	echo -e "$(color  green) Symlink for $(color "${SOURCE}" white) to $(color "${TARGET}" white) was created"
	ln -s "$SOURCE" "$TARGET"
}

# FUNCTION color
#
# Usage
#   source utils.sh
#   color color_string output_string
#
function color() {
	# https://dev.to/ifenna__/adding-colors-to-bash-scripts-48g4

	ENDCOLOR="\e[0m"

	case "${2,,}" in # lowercase
	# a*             ) foo;;    # matches anything starting with "a"
	# b?             ) bar;;    # matches any two-character string starting with "b"
	# c[de]          ) baz;;    # matches "cd" or "ce"
	# me?(e)t        ) qux;;    # matches "met" or "meet"
	# @(a|e|i|o|u)   ) fuzz;;   # matches one vowel
	# m+(iss)?(ippi) ) fizz;;   # matches "miss" or "mississippi" or others
	# *              ) bazinga;; # catchall, matches anything not matched above
	black) COLOR="\e[30m" ;;
	red) COLOR="\e[31m" ;;
	green) COLOR="\e[32m" ;;
	yellow) COLOR="\e[33m" ;;
	blue) COLOR="\e[34m" ;;
	magenta) COLOR="\e[35m" ;;
	cyan) COLOR="\e[36m" ;;
	white) COLOR="\e[37m" ;;
	*) COLOR="\e[97m" ;;
	esac

	echo -n -e "${COLOR}$1${ENDCOLOR}"
}
