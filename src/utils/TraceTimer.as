package utils
{
	import flash.utils.getTimer;
	/**
	 * trace计时器
	 * @author Alex
	 */
	public class TraceTimer 
	{
		public function TraceTimer()
		{
		}
		private static var START_TIME:int = 0;
		public static function start():void
		{
			START_TIME = getTimer();
		}
		public static function end(title:String = ""):void
		{
			trace("~~~~~~~~~~ " + title + " 耗时(ms): " + (getTimer() - START_TIME));
		}
	}

}