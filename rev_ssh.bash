#!/usr/bin/env bash

## { alterEGO Linux: "Open the vault of knowledge" } ----------------------- ##
##                                                                           ##
## /usr/local/bin/rev_ssh.bash                                               ##
##   created       : 2022-01-10 16:23:27 UTC                                 ##
##   updated       : 2022-01-22 10:55:04 UTC                                 ##
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
    _blue=$(printf '%b' "\033[34m")
    _bold=$(printf '%b' "\033[1m")
    _reset=$(printf '%b' "\033[0m")

    cat << EOF | less -R
${_bold}USAGE:${_reset} rev_ssh.bash <user@home_address:port>

## [ ${_blue}${_bold}How does it work: the basic${_reset} ] ----------------------------------------- ##

SSH reverse tunneling uses local port forwarding on the local machine from an
already existing ssh connection:

  $ ssh user@local_machine

  local machine:22 <- ssh connection <- remote server

Using -R option, a specified port on the local machine will be listening and
forward the reverse connection through the secured tunnel to port 22 on the 
remote server.

                                         ssh tunnel
                                <-------------------------
  local machine:<local_port> ->    reversed connection     -> remote server:22
                                <-------------------------

• ServerAliveInterval=60

Usually, a ssh connection will timeout and disconnect from the server if no
data is received from the server. In order to bypass this, ServerAliveInterval
option sets automatic message every 60 seconds if no activity occurs.

## [ ${_blue}${_bold}localhost${_reset} ] ----------------------------------------------------------- ##

ssh doesn't seem to require localhost to be defined to work, but it doesn't 
hurt to set the localhost in /etc/hosts like so:

  127.0.0.1        localhost
  ::1              localhost

## [ ${_blue}${_bold}Password vs ssh-key${_reset} ] ------------------------------------------------- ##

Using this script with a password will work with limitation.

• The password to connect home will be required on first launch.
• The password will be required on every reconnections.

This is a problem knowing the script runs on the remote server...

To connect or reconnect automatically, it is a good idea to use a ssh key.

On the remote server:

  $ ssh-keygen -t rsa
  $ ssh-copy-id <user>@<home_address>

This will create a public and private key on the remote server, and then copy 
the public key to home.

## [ ${_blue}${_bold}In the background with tmux${_reset} ] ----------------------------------------- ##

Although running rev_ssh.bash by itself is nice, to enable a more permanent
reverse connection, you can use a multiplexer like tmux to keep the process
running, even if you logout from your remote server session.

  $ tmux new-session -d -s <session_name>
  $ tmux send-keys -t <session_name> "bash rev_ssh.bash <user@home_address:port>" enter

## [ ${_blue}${_bold}Further reading${_reset} ] ----------------------------------------------------- ##

• ServerFault - SSH remote port forwarding failed
  https://serverfault.com/questions/595323/ssh-remote-port-forwarding-failed/615751#615751

• SSH.com - SSH port forwarding - Example, command, server config
  https://www.ssh.com/academy/ssh/tunneling/example

• Dave McKay - What Is Reverse SSH Tunneling? (and How to Use It)
  https://www.howtogeek.com/428413/what-is-reverse-ssh-tunneling-and-how-to-use-it/

• Hussein Nasser - SSH Tunneling - Local & Remote Port Forwarding (by Example)
  https://www.youtube.com/watch?v=N8f5zv9UUMI
EOF
}

reverse_ssh() {
    ## ref. https://serverfault.com/a/615751
    msg_action "Initiating reverse ssh connection..."
    msg_result "Use ssh -p ${port} localhost at home..."
    while true
    do
        ssh -f ${user}@${home_address} -R ${port}:localhost:22  -N -o ExitOnForwardFailure=yes -o ServerAliveInterval=60
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
