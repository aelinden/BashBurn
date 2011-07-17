#!/bin/bash

if [ $# -ne 1 ]; then
	echo 'You must supply a version number as an argument.'
else
	cp -r trunk BashBurn-$1
	tar cvf BashBurn-$1.tar BashBurn-$1
	gzip BashBurn-$1.tar
	rm -rf BashBurn-$1
fi
