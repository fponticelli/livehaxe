import sys.io.Process;

class HaxeService 
{
	public static function isPortInUse(port : Int) : Bool
	{
		var cmd = 'lsof -Pni4 | grep LISTEN',
			process = new Process('lsof', ['-Pni4']),
			out = process.stdout.readAll().toString();
		process.close();
		return new EReg('TCP [^:]+:$port [(]', '').match(out);
	}
	public static function isPortUsedByHaxe(port : Int) : Bool
	{
		var cmd = 'lsof -Pni4 | grep LISTEN',
			process = new Process('lsof', ['-Pni4']),
			out = process.stdout.readAll().toString();
		process.close();
		return new EReg('^haxe\\s+\\d+[^:]+[:]$port', 'm').match(out);
	}
	public static function start(port : Int)
	{
		var cmd = 'haxe --wait $port &';
		Sys.command(cmd);
	}
	public static function compile(hxml : String, port : Int)
	{
		var cmd = 'haxe $hxml --connect $port &';
		Sys.command(cmd);
	}
}