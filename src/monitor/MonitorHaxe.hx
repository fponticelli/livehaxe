package monitor;

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

	function parseHxmlClassPaths(content : String)
	{
		var re = ~/^\s*[-]cp\s+([^\n]+)(?:\n|$)/m,
			results = [];
		while(re.match(content))
		{
			var v = re.matched(1);
			results.push( v.trim() );
			content = re.matchedRight();
		}
		return results;
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