#!/bin/sh

libname='livehaxe'
rm -f "${libname}.zip"
zip -r "${libname}.zip" haxelib.json src run.n README.md
echo "Saved as ${libname}.zip"
