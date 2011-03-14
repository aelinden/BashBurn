#! /bin/bash

MAJOR=3
MINOR=1
VERSION=1
rev=$MAJOR.$MINOR
tartmproot=/tmp/bbsrc.$$
tartmp=$tartmproot/bashburn-$rev
mkdir -p $tartmp
savedir=$PWD

# Check to see if the rpmbuild dir exists. Make it if needed.
if ! [[ -d ~/rpmbuild ]]
then
    echo 'You do not have an rpmbuild tree. Creating.' 1>&2
    mkdir -p ~/rpmbuild/{BUILD,RPMS,S{PEC,OURCE,RPM}S}
    if ! [[ -f ~/.rpmmacros ]]
    then
	echo "%_topdir $HOME/rpmbuild" > ~/.rpmmacros
    else
	cat <<EOF 1>&2
Your rpmbuild directory did not exist but your ~/.rpmmacros file does.
I am appending a directive so that _topdir will be in rpmbuild.
EOF
    fi
fi

# Step 1. Create the tar file
cd ..
mkdir -p $tartmp
./Install.sh --prefix $tartmp --make-tar
(cd $tartmproot && tar -jcf ~/rpmbuild/SOURCES/bashburn-$rev.tar.bz2 .)
echo rm -rf $tartmproot
cd -

# Step 2. Copy the spec file
cp bashburn.spec ~/rpmbuild/SPEC

cat <<EOF
The tar file has been created in your SOURCES directory
and your spec file has been copied to your SPECS directory.

You may now run 

rpmbuild -ba bashburn.spec 
to give you both a .src.rpm and a .noarch.rpm
EOF
exit
