import sys.FileSystem;
import sys.io.File;
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
	public static function compile(hxml : String, port : Int, errorFile : Null<String>)
	{
		var start = Sys.time();

		createErrorFile(errorFile,'Running `haxe $hxml --connect port`');

		var p = new Process( 'haxe', [hxml, '--connect', '$port']);
		var exitCode = p.exitCode();


		var stderr = p.stderr.readAll().toString();
		var stdout = p.stdout.readAll().toString();
		Sys.println(stderr);
		Sys.println(stdout);

		switch exitCode {
			case 0: 
				var timeTaken = Sys.time() - start;
				Sys.println('Compiled $hxml in $timeTaken');
				if (errorFile!=null) FileSystem.deleteFile(errorFile);
			case exitCode:
				Sys.println('Failed to compile $hxml:');
				Sys.println('Exit code: $exitCode');
				createErrorFile(errorFile, '<h1>Error Compiling $hxml</h1><h3>Output:<pre>$stdout\n$stderr</pre>');
		}
	}
	static function createErrorFile(errorFile : String, content : String) {
		if ( errorFile!=null ) {
			var html = '<!DOCTYPE html><html><head>';
			html += '<title>LiveHaxe</title>';
			html += '<link href="//netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap.min.css" rel="stylesheet" />';
			html += '<meta http-equiv="refresh" content="1" />';
			html += '</head><body class="container">$content</body></html>';
			File.saveContent( errorFile, html );
		}

	}
}