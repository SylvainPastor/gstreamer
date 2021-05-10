#!/bin/bash
set -e

# Set your target branch
BRANCH="1.18.1"
GIT_GST_BASE_URI=git://anongit.freedesktop.org/git/gstreamer
INSTALL_DIR=$(pwd)/gst-$BRANCH

#################################################################

export PKG_CONFIG_PATH=$INSTALL_DIR/lib/x86_64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=$INSTALL_DIR/lib:$LD_LIBRARY_PATH
export LDFLAGS="-L$INSTALL_DIR/lib"

#################################################################

exec > >(tee build-gstreamer.log)
exec 2>&1

#################################################################

git_clone() {
	git clone $GIT_GST_BASE_URI/$1 -b $BRANCH
}

build() {
	cd $1
	meson -Dprefix=$INSTALL_DIR -Dlibdir=$INSTALL_DIR/lib build &&
		ninja -C build install
	cd ..
}

#################################################################

# Gstreamer plugins
plugins=(
	gst-plugins-base
	gst-plugins-good
	gst-plugins-bad
	gst-plugins-ugly
)

#################################################################

[ ! -d $INSTALL_DIR ] && mkdir $INSTALL_DIR

#################################################################

# Build Optimized Inner Loop Runtime Compiler (Orc)
[ ! -d orc ] && git clone $GIT_GST_BASE_URI/orc
build orc

#################################################################

# Build gstreamer
[ ! -d gstreamer ] && git_clone gstreamer
build gstreamer

#################################################################

# Build plugins
for plugin in "${plugins[@]}"; do
	[ ! -d $plugin ] && git_clone $plugin
	build $plugin
done
