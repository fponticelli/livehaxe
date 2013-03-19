livehaxe
========

Automatic compiler for Haxe and other tools. Monitors the files in your project and regen the output whenever it detects a change.

To launch livehaxe just execute the following command from your terminal (only tested on Mac):

    neko livehaxe.n -haxe build.hxml

Livehaxe will start the haxe compiler in server mode, scan all the ``-cp`` contained in your hxml and update your build whenever one of the ``.hx`` files in your project is modified.

Livehaxe can also be used to compile LESS files, just add:

    -less src.less dst.css

Multiple hxml and LESS files can be monitored at once.
