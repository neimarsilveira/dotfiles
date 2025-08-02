# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Causes bash to append to history instead of overwriting it so if you start a new terminal, you have old session history
shopt -s histappend
PROMPT_COMMAND='history -a'

##### PROMPT SETUP #####

function __setprompt
{
	local LAST_COMMAND=$? # Must come first!

	# Define colors
	local LIGHTGRAY="\033[0;37m"
	local WHITE="\033[1;37m"
	local BLACK="\033[0;30m"
	local DARKGRAY="\033[1;30m"
	local RED="\033[0;31m"
	local LIGHTRED="\033[1;31m"
	local GREEN="\033[0;32m"
	local LIGHTGREEN="\033[1;32m"
	local BROWN="\033[0;33m"
	local YELLOW="\033[1;33m"
	local BLUE="\033[0;34m"
	local LIGHTBLUE="\033[1;34m"
	local MAGENTA="\033[0;35m"
	local LIGHTMAGENTA="\033[1;35m"
	local CYAN="\033[0;36m"
	local LIGHTCYAN="\033[1;36m"
	local NOCOLOR="\033[0m"

	# Show error exit code if there is one
	if [[ $LAST_COMMAND != 0 ]]; then
		# PS1="\[${RED}\](\[${LIGHTRED}\]ERROR\[${RED}\])-(\[${LIGHTRED}\]Exit Code \[${WHITE}\]${LAST_COMMAND}\[${RED}\])-(\[${LIGHTRED}\]"
		PS1="\[${DARKGRAY}\](\[${LIGHTRED}\]ERROR\[${DARKGRAY}\])-(\[${RED}\]Exit Code \[${LIGHTRED}\]${LAST_COMMAND}\[${DARKGRAY}\])-(\[${RED}\]"
		if [[ $LAST_COMMAND == 1 ]]; then
			PS1+="General error"
		elif [ $LAST_COMMAND == 2 ]; then
			PS1+="Missing keyword, command, or permission problem"
		elif [ $LAST_COMMAND == 126 ]; then
			PS1+="Permission problem or command is not an executable"
		elif [ $LAST_COMMAND == 127 ]; then
			PS1+="Command not found"
		elif [ $LAST_COMMAND == 128 ]; then
			PS1+="Invalid argument to exit"
		elif [ $LAST_COMMAND == 129 ]; then
			PS1+="Fatal error signal 1"
		elif [ $LAST_COMMAND == 130 ]; then
			PS1+="Script terminated by Control-C"
		elif [ $LAST_COMMAND == 131 ]; then
			PS1+="Fatal error signal 3"
		elif [ $LAST_COMMAND == 132 ]; then
			PS1+="Fatal error signal 4"
		elif [ $LAST_COMMAND == 133 ]; then
			PS1+="Fatal error signal 5"
		elif [ $LAST_COMMAND == 134 ]; then
			PS1+="Fatal error signal 6"
		elif [ $LAST_COMMAND == 135 ]; then
			PS1+="Fatal error signal 7"
		elif [ $LAST_COMMAND == 136 ]; then
			PS1+="Fatal error signal 8"
		elif [ $LAST_COMMAND == 137 ]; then
			PS1+="Fatal error signal 9"
		elif [ $LAST_COMMAND -gt 255 ]; then
			PS1+="Exit status out of range"
		else
			PS1+="Unknown error code"
		fi
		PS1+="\[${DARKGRAY}\])\[${NOCOLOR}\]\n"
	else
		PS1=""
	fi

	# Date
	PS1+="\[${DARKGRAY}\]("
	# PS1+="\[${CYAN}\]\$(date +%a) $(date +%b-'%-m')" # Date
	PS1+="${YELLOW}$(date +'%T')" # Time
	PS1+="\[${DARKGRAY}\])-"

	# CPU
	# PS1+="(\[${MAGENTA}\]CPU $(cpu)%"

	# Jobs
	# PS1+="\[${DARKGRAY}\]:\[${MAGENTA}\]\j"

	# Network Connections (for a server - comment out for non-server)
	# PS1+="\[${DARKGRAY}\]:\[${MAGENTA}\]Net $(awk 'END {print NR}' /proc/net/tcp)"

	# PS1+="\[${DARKGRAY}\])-"

	# User and server
	# local SSH_IP=`echo $SSH_CLIENT | awk '{ print $1 }'`
	# local SSH2_IP=`echo $SSH2_CLIENT | awk '{ print $1 }'`
	# if [ $SSH2_IP ] || [ $SSH_IP ] ; then
		# PS1+="(\[${RED}\]\u@\h"
	# else
		# PS1+="(\[${RED}\]\u"
	# fi

	# Current directory
	PS1+="\[${DARKGRAY}\](\[${LIGHTBLUE}\]\w\[${DARKGRAY}\])"

	# Total size of files in current directory
	# PS1+="(\[${GREEN}\]$(/bin/ls -lah | /bin/grep -m 1 total | /bin/sed 's/total //')\[${DARKGRAY}\]:"

	# # Number of files
	# PS1+="\[${GREEN}\]\$(/bin/ls -A -1 | /usr/bin/wc -l)\[${DARKGRAY}\])"

	# Git info
    branch=$(git branch --show-current 2>/dev/null)
    if [ -n "$branch" ]; then
        status=$(git status --porcelain 2>/dev/null)
        if [[ -n "$status" ]]; then
          PS1+="-(\[${LIGHTRED}\]$branch* ⚒️ ${DARKGRAY})${NOCOLOR}"
        else
          PS1+="-(\[${LIGHTGREEN}\]$branch 🖒 ${DARKGRAY})${NOCOLOR}"
        fi
    fi

	# Skip to the next line
	PS1+="\n"

    # Prompt entry
    PS1+="\[${DARKGRAY}\]>\[${NOCOLOR}\] "

	# PS2 is used to continue a command using the \ character
	PS2="\[${DARKGRAY}\]>\[${NOCOLOR}\] "

	# PS3 is used to enter a number choice in a script
	# PS3='Please enter a number from above list: '

	# PS4 is used for tracing a script in debug mode
	# PS4='\[${DARKGRAY}\]+\[${NOCOLOR}\] '
}
PROMPT_COMMAND='__setprompt'


##### PATH #####

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
PATH="$PATH:."
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# Autocompletition and list of completition
# Wrapping it so it is only defined in interactive shells
# if [[ $- == *i* ]]; then
    # bind 'TAB:menu-complete'
# fi
bind 'set show-all-if-ambiguous on'
bind "set completion-ignore-case on"

##### UTILS ##### 

# Fuzzy Find integration
eval "$(fzf --bash)"
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"


#### ALIASES ####
# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi

alias new_latex_proj=". ~/pCloudDrive/03_rsc/06_software/linux_scripts_and_files/new_latex_report.sh"
alias new_proj=". ~/pCloudDrive/03_rsc/06_software/linux_scripts_and_files/new_project.sh"
alias cpuf="while true; do cat /proc/cpuinfo | grep -i MHz; sleep 0.5; clear; done;"
# alias cpuu="grep 'cpu ' /proc/stat | awk '{usage=(\$2+\$4)*100/(\$2+\$4+\$5)} END {print usage}' | awk '{printf(\"%.1f\n\", \$1)}'"
alias nano=micro
alias bat="bat --color=always"
alias la='ls -Alh --color=auto'
# setting micro as EDITOR
export EDITOR=micro

##### FUNCTIONS #####

# Create and go to the directory
mkcd ()
{
	mkdir -p $1
	cd $1
}


# Function to open or create a file with gnome-text-editor
gte() {
    for file in "$@"; do
        # Check if the file exists
        if [ ! -e "$file" ]; then
            # If it doesn't exist, create it
            touch "$file"
        fi
        # Open the file in gnome-text-editor
        gnome-text-editor "$file" 2>/dev/null &
    done
}

# Function to get memory usage of a process
function memuse() {
    if [ $# -eq 0 ]; then
        echo "Usage: memuse <process_name_or_pid> [<process_name_or_pid> ...]"
        return 1
    fi

    total_memory=0
    use_pmap=false

    # checking for the -m option
    if [[ "$1" == "-m"  ]]; then
        use_pmap=true
        shift # Remove the -m option from the arguments
    fi
    for arg in "$@"; do
        # Check if the argument is a number (PID) or a process name
        if [[ "$arg" =~ ^[0-9]+$ ]]; then
            # It's a PID
            pids=("$arg")
        else
            # It's a process name, use pgrep to find PIDs
            pids=($(pgrep -f "$arg"))
        fi

        # If no PIDs were found, print a message and continue
        if [ ${#pids[@]} -eq 0 ]; then
            echo "No processes found for: $arg"
            continue
        fi

        # Sum the memory usage for each PID found
        for pid in "${pids[@]}"; do
            if $use_pmap; then
                # Get the memory usage from pmap
                mem_usage=$(pmap -x "$pid" | awk '/total/ {print $3}')
            else
                # Get the memory usage from ps (RSS in KB)
                mem_usage=$(ps -o rss= -p "$pid" | awk '{sum += $1} END {print sum}')
            fi

            # Updating the total memory
            if [ -n "$mem_usage" ]; then
                total_memory=$((total_memory + mem_usage))
            fi
        done
    done

    # Convert total_memory to appropriate units
    if [ "$total_memory" -ge 1048576 ]; then
        # Convert to GB
        echo "Total Memory Usage: $(echo "scale=2; $total_memory / 1024 / 1024" | bc) GB"
    elif [ "$total_memory" -ge 1024 ]; then
        # Convert to MB
        echo "Total Memory Usage: $(echo "scale=2; $total_memory / 1024" | bc) MB"
    else
        # Keep in KB
        echo "Total Memory Usage: ${total_memory} KB"
    fi
}

# Function to monitor memory of a app
function memwatch() {
    while true ; do
      tput clear
      echo "Running memuse with arguments: $@";
      memuse $@
      sleep 1
    done
}

# ISET function: sums reactions of output.txt
function sum_reactions() {
    if [ "$#" -ne 1 ]; then
        echo "Usage: sum_reactions <column_number>"
        return 1
    fi

    column_number=$1

    awk -F, -v col="$column_number" '
        /Reac/ {
            id = $1
            value = $col

            if (first_id == "") {
                first_id = id
            } else if (id == first_id && seen_first_id) {
                # New step started
                step++
                first_id = id
            }

            values[step] += value

            # Set seen_first_id true after the first time we hit first_id
            if (id == first_id) {
                seen_first_id = 1
            }
        }
        END {
            for (i = 0; i <= step; i++) {
                printf "Step %d: %.2f\n", i + 1, values[i]
            }
        }
    ' output.txt
}

unset rc
