livehaxe
========

Automatic compiler for Haxe and other tools. Monitors the files in your project and regen the output whenever it detects a change.

Currently tested on Ubuntu and OSX, not tested on Windows.

### Installation

    haxelib install livehaxe

### Compiling Haxe

To launch livehaxe just execute the following command from your terminal (not tested on Windows):

    haxelib run livehaxe -haxe build.hxml

Livehaxe will start the haxe compiler in server mode, scan all the ``-cp`` contained in your hxml and update your build whenever one of the ``.hx`` files in your project is modified.

### Compiling Less

Livehaxe can also be used to compile LESS files, just add:

    -less src.less dst.css

### Notes

If you would like to display a replacement page, you can add

    -errorpage out/index.html

This will place a HTML file in "out/index.html" while the build is running, which will refresh automatically until the build is finished.
If the build fails, it will update the html file with a list of errors.
If the build succeeds, the html page will be removed.

Multiple hxml and LESS files can be monitored at once.
