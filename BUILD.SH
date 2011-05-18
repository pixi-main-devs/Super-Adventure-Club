#!/bin/bash


# Main build script
# TODO - make this a proper build script, atm its hard coded, no error checking

checkisroot() {

if [ "$(id -u)" != "0" ]; then
	echo "Sorry, you are not root. Root is needed to install some modules"
	exit 1
fi
}

runcspace() {
echo ""
echo "Run cspace now? (y/n)"
read USERCHOICE
case $USERCHOICE in
	y) python cspace/CSpace.pyw;;
	n) exit 0;;
	*) exit 0;;
esac
}



checkisroot

# First build and install pyrex, its needed to build ncrypt

cd Pyrex-0.9.5

python setup.py build
python setup.py install

cd ..

cd ncrypt-0.6.4
python setup.py build
python setup.py install

cd ..


runcspace

