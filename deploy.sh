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
mkdir -p $HOME/.config
touch $HOME/.cache/zsh/history

cp .config/zsh/.zshrc $HOME/.zshrc #there are two .zshrcs for some reason, I'm not bothering to check which one is used

cp -r .config/shell $HOME/.config/
cp -r .config/zsh $HOME/.config/


#install syntax highlighting
if [[$user == root ]]
then
	mkdir -p /usr/share/zsh/plugins
	pushd /usr/share/zsh/plugins
	git clone https://github.com/zdharma-continuum/fast-syntax-highlighting
	popd
else
	su
	mkdir -p /usr/share/zsh/plugins
	pushd /usr/share/zsh/plugins
	git clone https://github.com/zdharma-continuum/fast-syntax-highlighting
	popd
	exit
fi

#set the aliases
chmod -R +x $HOME/.config/shell
$HOME/.config/shell/aliasrc
