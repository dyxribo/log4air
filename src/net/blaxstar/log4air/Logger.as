package net.blaxstar.log4air
{
	import net.blaxstar.log4air.dataholder.Level;
	import net.blaxstar.log4air.dataholder.LevelHolder;
	import net.blaxstar.log4air.manager.LogManager;
	
	public class Logger
	{
		
		private var _name:String;
		private var _log_manager:LogManager;
		
		// ! CONSTRUCTOR ! //
		
		public function Logger(name:String, log_manager:LogManager)
		{
			this._name = name;
			this._log_manager = log_manager;
		}
		
		// ! PUBLIC FUNCTIONS ! //
		
		public function success(format:String, ... args:Array):void
		{
			_log_manager.add_log(LevelHolder.SUCCESS, _name, format, args);
		}
		
		public function debug(format:String, ... args:Array):void
		{
			_log_manager.add_log(LevelHolder.DEBUG, _name, format, args);
		}
		
		public function info(format:String, ... args:Array):void
		{
			_log_manager.add_log(LevelHolder.INFO, _name, format, args);
		}
		
		public function warn(format:String, ... args:Array):void
		{
			_log_manager.add_log(LevelHolder.WARN, _name, format, args);
		}
		
		public function error(format:String, ... args:Array):void
		{
			_log_manager.add_log(LevelHolder.ERROR, _name, format, args);
		}
		
		public function fatal(format:String, ... args:Array):void
		{
			_log_manager.add_log(LevelHolder.FATAL, _name, format, args);
		}
		
		public function addLog(level:Level, format:String, ... args:Array):void
		{
			_log_manager.add_log(level, _name, format, args);
		}
	}
}