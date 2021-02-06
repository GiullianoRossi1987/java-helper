#!/usr/bin/bash


if [ ! -d /usr/lib/java-helper ] && [ ! -f /usr/bin/jh ]; then
	echo "Installing Java Helper... "
	sudo mkdir /usr/lib/java-helper
	if [ "$1" == "-v" ] || [ "$1" == "--verbose" ]; then echo "Creating lib folder...."; fi
	sudo cp -r ./* /usr/lib/java-helper && sudo rm -rf /usr/lib/java-helper/jh /usr/lib/java-helper/classpaths
	sudo chmod -R 755 /usr/lib/java-helper
	if [ "$1" == "-v" ] || [ "$1" == "--verbose" ]; then echo "Copying all the source files to the lib..."; fi
	sudo mkdir /etc/java-helper
	sudo cp -rf classpaths /etc/java-helper/
	sudo cp helper_data.conf /etc/java-helper
	sudo cp ./jh /usr/bin
	sudo chmod 755 /usr/bin/jh
	if [ "$1" == "-v" ] || [ "$1" == "--verbose" ]; then echo "Creating command to user..."; fi
	echo "Installed successfully"
else
	# Uninstalls for now
	sudo rm -rf /usr/lib/java-helper
	sudo rm -f /usr/bin/jh
	echo "Uninstalled"
fi

