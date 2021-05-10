#!/bin/bash

BRANCH="1.18.1"
GST_DIR=$(pwd)/gst-$BRANCH

export LD_LIBRARY_PATH=$GST_DIR/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
export LD_PRELOAD="$GST_DIR/lib/libgstreamer-1.0.so"
export GST_PLUGIN_PATH=$GST_DIR/lib/

trace() {
	strace $GST_DIR/bin/gst-inspect-1.0 webrtc 2>&1 | grep '^open.*gst' >test.trace
}

test() {
	$GST_DIR/bin/gst-inspect-1.0 app
}

test_list_plugins() {
	$GST_DIR/bin/gst-inspect-1.0 --plugin
}

test_list_plugins
trace
test
