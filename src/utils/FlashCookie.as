package utils 
{
	import flash.net.SharedObject;
	/**
	 * FlashCookie
	 * @author Alex
	 */
	public class FlashCookie 
	{
		public function FlashCookie()
		{
		}
		
		private static var _cookie_so:SharedObject;
		private static function get cookie_so():SharedObject
		{
			if (_cookie_so == null) 
			{
				_cookie_so = SharedObject.getLocal("FlashCookie");
			}
			return _cookie_so;
		}
		
		/**
		 * 塞入数据
		 * @param	valueName
		 * @param	value
		 */
		public static function setValue(valueName:String, value:*):void
		{
			cookie_so.data[valueName] = value;
			cookie_so.flush();
		}
		
		/**
		 * 取出数据
		 * @param	valueName
		 * @return
		 */
		public static function getValue(valueName:String):*
		{
			return cookie_so.data[valueName];
		}
		
		/**
		 * 删除数据
		 * @param	valueName
		 */
		public static function deleteValue(valueName:String):void
		{
			delete cookie_so.data[valueName];
			cookie_so.flush();
		}
	}
}