package monitor;

interface IMonitor 
{
	public function start() : Void;
	public function poll() : Void;
	public function config(params : {}) : Void;
}