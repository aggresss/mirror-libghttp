#!/bin/bash
# Operate on Ubuntu 14.04
# Substitute config.guess config.sub from autotools version 20130810.1
cd $(git rev-parse --show-toplevel)
cd libghttp
cp /usr/share/misc/config.guess .
cp /usr/share/misc/config.sub .

