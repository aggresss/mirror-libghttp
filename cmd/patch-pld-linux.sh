#!/bin/bash
# patch libghttp-1.0.9 with repo https://github.com/pld-linux/lighttp.git
cd $(git rev-parse --show-toplevel)
cd libghttp
patch -p1 < ../third_party/pld-linux/libghttp/libghttp-ac.patch
patch -p1 < ../third_party/pld-linux/libghttp/libghttp-fixlocale.patch
patch -p1 < ../third_party/pld-linux/libghttp/libghttp-ssl.patch

