#!/bin/bash

# check the distro type and user
if [[ $(cat /etc/os-release) == *"Arch"* ]]
then
	target_distro=Arch
elif [[ $(cat /etc/os-release) == *"Debian"* ]]
then
	target_distro=Debian
else
	echo System not supported
	exit
fi

user=$(whoami)

read -p "Installing for $user on $target_distro, Correct? [Y/n]" -n 1 -r
echo $'\n'

if [[ $REPLY =~ ^[Nn]$ ]]
then
	echo "Abort"
	exit
fi
#install zsh based on which distro and perms
echo "Installing zsh"
if [[ $user == root ]]
then
	echo "you are root"
	case $target_distro in
		"Arch")
			pacman -Syu zsh
			;;
		"Debian")
			apt update
			apt install zsh
			;;
	esac
else
	echo "you are not root"
	case $target_distro in
		"Arch")
			sudo pacman -Syu zsh
			;;
		"Debian")
			sudo apt update
			sudo apt install zsh
			;;
	esac
fi

#set zshell as default and copy the config files
chsh -s zsh
mkdir -p $HOME/.cache/zsh/
cp .config/zsh/.zshrc $HOME #there are two .zshrcs for some reason, I'm not bothering to check which one is used
mv -iv .config $HOME
mv -iv .zprofile $HOME

#install syntax highlighting
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting $HOME

if [[ $user == root ]]
then
	mv -iv fast-syntax-highlighting /usr/share/zsh/plugins/
else
	sudo mv -iv fast-syntax-highlighting /usr/share/zsh/plugins/
fi

rm -rf fast-syntax-highlighting

#set the aliases
$HOME/.config/shell/aliasrc
