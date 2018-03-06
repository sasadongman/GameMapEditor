package 
{
	import flash.utils.getTimer;
	import morn.core.components.TextArea;
	/**
	 * ...
	 * @author Alex
	 */
	public class Log 
	{
		private static var START_TIME:int = 0;
		private static var cache_arr:Array = [];
		private static var _log_ta:TextArea;
		public function Log() 
		{
		}
		/**
		 * 设定文本组件
		 */
		public static function set log_ta(value:TextArea):void
		{
			_log_ta = value;
			if (_log_ta == null) 
			{
				return;
			}
			for each (var str:String in cache_arr) 
			{
				log(str);
			}
			cache_arr.length = 0;
		}
		/**
		 * log内容
		 * @param	obj
		 */
		public static function log(obj:*):void
		{
			var str:String = String(obj);
			if (_log_ta == null)
			{
				cache_arr.push(str);
				return;
			}
			_log_ta.text += str + "\n";
		}
		/**
		 * 清除log
		 */
		public static function clear():void
		{
			if (_log_ta == null)
			{
				cache_arr.length = 0;
				return;
			}
			_log_ta.text = "";
		}
		/**
		 * 计时开始
		 */
		public static function timerStart():void
		{
			START_TIME = getTimer();
		}
		/**
		 * 计时结束
		 * @param	content
		 */
		public static function timerEnd(content:String = ""):void
		{
			log("[计时]" + (getTimer() - START_TIME) + "ms " + content);
		}
	}
}