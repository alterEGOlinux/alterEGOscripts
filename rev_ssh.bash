#!/usr/bin/env bash

## { alterEGO Linux: "Open the vault of knowledge" } ----------------------- ##
##                                                                           ##
## /usr/local/bin/rev_ssh.bash                                               ##
##   created       : 2022-01-10 16:23:27 UTC                                 ##
##   updated       : 2022-01-10 16:23:36 UTC                                 ##
##   description   : Set up a reverse ssh connexion.                         ##
## _________________________________________________________________________ ##

msg_action() {
    _msg="${1}"

    _msg_bold="\033[1m"
    _msg_green="\033[32m"
    _msg_reset="\033[0m"

    printf '%b\n' "${_msg_green}[*]${_msg_reset} ${_msg_bold}${_msg}${_msg_reset}"
}

msg_result() {
    _msg="${1}"

    _msg_bold="\033[1m"
    _msg_blue="\033[34m"
    _msg_reset="\033[0m"

    printf '%b\n' "${_msg_blue}[-]${_msg_reset} ${_msg_bold}${_msg}${_msg_reset}"
}

msg_warning() {
    _msg="${1}"

    _msg_bold="\033[1m"
    _msg_red="\033[31m"
    _msg_reset="\033[0m"

    printf '%b\n' "${_msg_red}[!]${_msg_reset} ${_msg_bold}${_msg}${_msg_reset}"
}

usage() {
    _bold=$(printf '%b' "\033[1m")
    _reset=$(printf '%b' "\033[0m")

    msg_action "HELP"
    cat << EOF
${_bold}USAGE:${_reset} rev_ssh.bash <user@home_address:port>

  ${_bold}How does it work: the basic${_reset}

SSH reverse tunneling uses local port forwarding on the local machine from an
already existing ssh connection:

  $ ssh user@local_machine
  local machine <- ssh connection <- remote server

Using -R option, a specified port on the local machine will be listening and
forward the reverse connection through the secured tunnel to port 22 on the 
remote server.

                                         ssh tunnel
                                <-------------------------
  local machine:<local_port> ->    reversed connection     -> remote server:22
                                <-------------------------

  ${_bold}The other options${_reset}

  ${_bold}Localhost${_reset}

  ${_bold}SSH key vs Password${_reset}

#--- In order to this to work, generate a ssh-key.
#... Otherwise, the script will keep asking for a password.
#... localhost must be defined in /etc/hosts on the remote machine on
#... which this script is running.
#... Use a tmux session (detached) to remain connected, even after logging out
#... of the machine.
#... At home, connect to the reverse shell:
#... $ ssh -p 2010 localhost

  ${_bold}Further reading${_reset}

• https://www.ssh.com/academy/ssh/tunneling/example
• https://www.howtogeek.com/428413/what-is-reverse-ssh-tunneling-and-how-to-use-it/
EOF
}

reverse_ssh() {
    ## ref. https://serverfault.com/a/615751
    msg_action "Initiating reverse ssh connection..."
    msg_result "Use ssh -p ${port} localhost at home..."
    while true
    do
        # ssh -f ${user}@${home_address} -R ${port}:localhost:22  -N -o ExitOnForwardFailure=yes -o ServerAliveInterval=60
        ssh ${user}@${home_address} -R ${port}:localhost:22 -o ExitOnForwardFailure=yes -o ServerAliveInterval=60
        sleep 180
    done
}

case ${@} in

    *"@"*":"* )
        user=$(cut -d '@' -f1 <<< "${@}")
        home_address=$(grep -oP "(?<=@).*(?=:)" <<< "${@}")
        port=$(cut -d ':' -f2 <<< "${@}")
        reverse_ssh
        ;; 

    * ) usage;;

esac

## FIN _____________________________________________________________ ¯\_(ツ)_/¯
