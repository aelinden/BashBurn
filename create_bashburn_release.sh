#!/bin/bash

echo 'BashBurn release script'

if [ $# -ne 1 ]; then
	echo 'You must supply a version number as an argument.'
else
	cp -r trunk BashBurn-$1
	tar cvfz BashBurn-$1.tar.gz BashBurn-$1
	rm -rf BashBurn-$1
fi
