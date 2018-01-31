#!/bin/sh

rm -f *.pkg.tar.xz local.db* local.files*
cp ../build/*/*.pkg.tar.xz .

repo-add local.db.tar.xz *.pkg.tar.xz
