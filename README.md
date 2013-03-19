livehaxe
========

Automatic compiler for Haxe and other tools. Monitors the files in a project and regen the output whenever it detects a change.

To launch livehaxe just execute the following command from your terminal (only tested on Mac):

   neko livehaxe.n -haxe build.hxml

Livehaxe will start the haxe compiler in server mode, scan all the -cp contained in your hxml and update your build whenever one of the .hx files in your project are modified.

Livehaxe can also be used to compile LESS files, just use:

   -less src.less dst.css

Multiple hxml and less files can be monitored at once.
