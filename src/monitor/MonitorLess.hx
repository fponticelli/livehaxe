package monitor;

class MonitorLess implements IMonitor
{
	public static function createFromArguments(args : Array<String>)
	{
		var src = LiveHaxe.consumeArgument(args),
			dst = LiveHaxe.consumeArgument(args);
		return new MonitorLess(src, dst);
	}

	var src : String;
	var dst : String;
	var mod : Float;
	var linenumbers : String;
	var compress : Bool = false;

	public function new(src : String, dst : String)
	{
		this.src = src;
		this.dst = dst;
	}

	public function start()
	{
		mod = sys.FileSystem.stat(src).mtime.getTime();
	}

	public function poll()
	{
		var newmod = sys.FileSystem.stat(src).mtime.getTime();
		if(newmod > mod)
		{
			LiveHaxe.clear();
			compileLess();
			mod = newmod;
		}
	}

	public function config(params : Dynamic)
	{
		if(null != params.lesscompress && Std.is(params.lesscompress, Bool))
			compress = params.lesscompress;
		if(null != params.lesslinenumbers && Lambda.indexOf(['comments','mediaquery','all'], params.lesslinenumbers) >= 0)
			linenumbers = params.lesslinenumbers;
	}

	public function compileLess()
	{
		var options = [];
		if(compress)
			options.push("-x");
		if(null != linenumbers)
			options.push("--line-numbers="+linenumbers);
		var cmd = 'lessc ${options.join(" ")} $src $dst';
		Sys.command(cmd);
	}
}