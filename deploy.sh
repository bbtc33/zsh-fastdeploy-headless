#!/bin/bash

# check the distro type and user
if [[ $(cat /etc/os-release) == *"Arch"* ]]
then
	target_distro=Arch
elif [[ $(cat /etc/os-release) == *"Debian"* ]]
then
	target_distro=Debian

elif [[ $(cat /etc/os-release) == *"Ubuntu"* ]]
then
	target_distro=Debian #same package manager
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

#Do you have sudo???
if [[ $user != root ]]
then
	echo "Do you have sudo?"
	read -p "[Y/n]" -n 1 -r
	echo $'\n'
	if [[ $REPLY =~ ^[Nn]$ ]]
	then
		echo "Abort"
		exit
	fi
fi

#install zsh based on which distro and perms
echo "Installing zsh"
if [[ $user == root ]]
then
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
chsh -s /bin/zsh
mkdir -p $HOME/.cache/zsh/
mkdir -p $HOME/.config/shell
mkdir -p $HOME/.config/zsh
touch $HOME/.cache/zsh/history

cp config/zsh/.zshrc $HOME/.zshrc #there are two .zshrcs for some reason, I'm not bothering to check which one is used
cp config/zsh/.zshrc $HOME/.config/zsh/.zshrc

cp config/shell/inputrc $HOME/.config/shell/
cp config/shell/profile $HOME/.config/shell/

if [[ $user == root ]]
then
	cp config/shell/aliasrc.root $HOME/.config/shell/aliasrc
else
	cp config/shell/aliasrc $HOME/.config/shell/aliasrc
fi

#install syntax highlighting
if [[ $user == root ]]
then
	mkdir -p /usr/share/zsh/plugins
	pushd /usr/share/zsh/plugins
	git clone https://github.com/zdharma-continuum/fast-syntax-highlighting
	popd
else
	sudo mkdir -p /usr/share/zsh/plugins
	sudo git clone https://github.com/zdharma-continuum/fast-syntax-highlighting /usr/share/zsh/plugins
	exit
fi

#set the aliases
chmod -R +x $HOME/.config/shell
source $HOME/.config/shell/aliasrc
