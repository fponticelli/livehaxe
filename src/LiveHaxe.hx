import monitor.*;

class LiveHaxe
{
	static public function consumeArgument(args : Array<String>, ?msg : String)
	{
		var arg = args.shift();
		if(null == arg)
			throw null == msg ? 'expected argument' : msg;
		return arg;
	}

	static public function error(msg : String)
	{
		Sys.println(msg);
		Sys.exit(1);
	}

	static public function clear()
	{
		Sys.command('clear');
	}

	static public function print(msg : String)
	{
		Sys.println(msg);
	}

	static public function main()
	{
		var args = Sys.args(),
			monitors : Array<IMonitor> = [],
			config = {
				delay    : 1.0,
				haxeport : 7777,
				hashaxe  : false,
				lesscompress : false,
				lesslinenumbers : null,
				errorfile : null
			};
		while(args.length > 0)
		{
			switch(args.shift().toLowerCase())
			{
				case "-less-compress":
					config.lesscompress = true;
				case "-less-line-numbers":
					config.lesslinenumbers = consumeArgument(args);
				case "-delay":
					config.delay = Std.parseInt(consumeArgument(args));
				case "-haxe-port":
					config.haxeport = Std.parseInt(consumeArgument(args));
				case "-haxe":
					config.hashaxe = true;
					monitors.push(MonitorHaxe.createFromArguments(args));
				case "-less":
					monitors.push(MonitorLess.createFromArguments(args));
				case "-errorpage":
					config.errorfile = consumeArgument(args);
				case invalid:
					throw 'invalid command: $invalid';
			}
		}

		if(monitors.length == 0) {
			Sys.println("nothing to monitor. exiting ....");
			Sys.exit(0);
		}

		if(config.hashaxe)
		{
			if(HaxeService.isPortInUse(config.haxeport))
			{
				if(!HaxeService.isPortUsedByHaxe(config.haxeport))
				{
					error('port "${config.haxeport}" already in use by another service');
				}
			} else {
				HaxeService.start(config.haxeport);
			}
		}

		for(monitor in monitors)
			monitor.config(config);

		for(monitor in monitors)
			monitor.start();

		while(true)
		{
			for(monitor in monitors)
				monitor.poll();
			Sys.sleep(config.delay);
		}
	}
}