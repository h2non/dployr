#!/bin/sh

createExecUser() {
	USERNAME=$1
	shift
	DIRECTORIES=$@

	NOLOGIN_PATH=$(which nologin)
	sudo useradd -M -U -s $NOLOGIN_PATH $USERNAME
	for dir in $DIRECTORIES; do
		if [ ! -d $dir ]
		then
			sudo mkdir $dir
		fi
		echo "Change owner to $dir ..."
		sudo chown -R ${USERNAME}:${USERNAME} $dir
	done
}