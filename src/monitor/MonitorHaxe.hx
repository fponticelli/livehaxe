package monitor;

import sys.io.Process;
using StringTools;
using haxe.io.Path;

class MonitorHaxe implements IMonitor
{
	public static function createFromArguments(args : Array<String>)
	{
		var hxmlfile = LiveHaxe.consumeArgument(args);
		return new MonitorHaxe(hxmlfile);
	}

	var port : Int = 7777;
	var hxml : String;
	var classpaths : Array<String>;
	var map : Map<String, Float>;
	var cwd : String;
	var errorFile:String;

	public function new(hxml : String)
	{
		this.hxml = hxml;
		var parts = hxml.split('/');
		if(parts.length > 1)
			parts.splice(0, parts.length - 1);
		else
			parts = [];
		cwd = Sys.getCwd();
		if(StringTools.endsWith(cwd, "/"))
			cwd = cwd.substr(0, cwd.length-1);
		cwd = [cwd].concat(parts).join('/');
		errorFile = null;
	}

	public function start()
	{
		// read hxml content
		var content = sys.io.File.getContent(hxml);
		// parse -cp
		classpaths = parseHxmlClassPaths(content);
		// set initial set of files
		map = loadFiles();
	}

	public function poll()
	{
		// iterate cp and collect files
		var newmap = loadFiles();
		// compare with existing ones
		if(!compareMaps(map, newmap)) {
			// compile
			LiveHaxe.clear();
			HaxeService.compile(hxml, port, errorFile);
			// update map
			map = newmap;
		}
	}

	public function config(params : Dynamic)
	{
		if(null != params.haxeport && Std.is(params.haxeport, Int))
			port = params.haxeport;
		if(null != params.errorfile && Std.is(params.errorfile, String))
			errorFile = params.errorfile;
	}

	function compareMaps(oldmap : Map<String, Float>, newmap : Map<String, Float>)
	{
		for(key in newmap.keys())
			if(!oldmap.exists(key) || oldmap.get(key) < newmap.get(key))
				return false;
		return true;
	}

	function parseHxmlClassPaths(origContent : String)
	{
		var cpRE = ~/^\s*[-]cp\s+([^\n]+)(?:\n|$)/m,
			libRE = ~/^\s*[-]lib\s+([^: \s]+)(?:\n|$)/m,
			results = [];
		
		// Extract `-cp` paths from the hxml
		var content = origContent;
		while(cpRE.match(content))
		{
			var v = cpRE.matched(1);
			results.push( v.trim() );
			content = cpRE.matchedRight();
		}

		// Extract `-lib` paths from the hxml, including dependencies, and check for paths
		// which are outside the Haxelib repo, (probably the dev versions we want to monitor).
		var content = origContent;
		var haxelibPath = getCmdOutput("haxelib",["config"]).trim();
		var pathArgs = ["path"];
		while(libRE.match(content))
		{
			var libName = libRE.matched(1).trim();
			pathArgs.push(libName);
			content = libRE.matchedRight();
		}
		var libPaths = getCmdOutput("haxelib",pathArgs);
		for (line in libPaths.split("\n"))
		{
			line = line.trim();
			var isEmpty = line.length==0;
			var isDefineLine = line.startsWith("-");
			var isInsideHaxelibRepo = line.startsWith(haxelibPath);
			var isAlreadyListed = results.indexOf(line)!=-1;
			if ( (isEmpty || isDefineLine || isInsideHaxelibRepo || isAlreadyListed)==false ) {
				results.push(line);
			}
		}
		Sys.println( 'Monitoring Class Paths:' );
		for (r in results) Sys.println( ' $r' );
		return results;
	}

	function getCmdOutput(cmd : String, args : Array<String>)
	{
		var p = new Process(cmd,args);
		p.exitCode();
		return p.stdout.readAll().toString();
	}

	function loadFiles()
	{
		var map = new Map();
		for(cp in classpaths)
			traverseDirectories(map, (cp.startsWith('/')) ? cp : cwd + '/' + cp);
		traverseDirectories(map, cwd);
		return map;
	}

	function traverseDirectories(map : Map<String, Float>, path : String)
	{
		var files = sys.FileSystem.readDirectory(path);
		for(name in files)
		{
			var file = path.addTrailingSlash()+name;
			if(sys.FileSystem.isDirectory(file))
			{
				// Traverse into other directories, unless it's hidden (we want to avoid '.git' and '.svn' etc).
				if (StringTools.startsWith(name, ".") == false)
					traverseDirectories(map, file);
			} else if(StringTools.endsWith(name, '.hx')) {
				if(StringTools.startsWith(file, "./"))
					file = file.substr(2);
				if(map.exists(file))
					continue;
				var stat = sys.FileSystem.stat(file);
				map.set(file, stat.mtime.getTime());
			}
		}
	}
}