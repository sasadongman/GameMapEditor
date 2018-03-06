package display 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import morn.core.handlers.Handler;
	
	/**
	 * ...
	 * @author Alex
	 */
	public class ResourceBitmap extends Bitmap 
	{
		private var _url:String;
		private var _handler:Handler;
		private var _realSmoothing:Boolean;
		/**
		 * 基础资源图片对象搞糟函数
		 * @param	type		资源类型
		 * @param	key			资源key
		 * @param	handler		回调Handler
		 * @param	smoothing	平滑
		 */
		public function ResourceBitmap(url:String = null, handler:Handler = null, smoothing:Boolean = false) 
		{
			super();
			_handler = handler;
			this.smoothing = smoothing;
			setResource(url);
		}
		
		/**
		 * 设置资源
		 * @param	url
		 */
		public function setResource(url:String = null):void
		{
			_url = url;
			if (_url == null) 
			{
				this.bitmapData = null;
				return;
			}
			//设定BitmapData之后再设置smoothing才能真正起作用
			//this.smoothing = this.smoothing;
			//if (_handler && this.bitmapData) 
			//{
				//_handler.executeWith([true]);
			//}
			load();
		}
		
		private function load():void
		{
			var thisRef:ResourceBitmap = this;
			
			var loader:Loader = new Loader();
			loader.load(new URLRequest(_url));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_complete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loader_complete);
			
			function loader_complete(e:Event):void
			{
				//trace(e);
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loader_complete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loader_complete);
				if (e.type == Event.COMPLETE)
				{
					thisRef.bitmapData = (loader.content as Bitmap).bitmapData.clone();
				}
				loader.unload();
				_handler.execute();
			}
		}
		
		/**
		 * 清除
		 */
		public function clear():void
		{
			this.bitmapData = null;
		}
		
		/**
		 * 销毁
		 */
		public function dispose():void
		{
			this.bitmapData = null;
			if (this.parent) 
			{
				this.parent.removeChild(this);
			}
		}
		
		
		/**
		 * 设定回调
		 */
		public function set handler(value:Handler):void 
		{
			_handler = value;
		}
		/**
		 * 平滑属性
		 */
		override public function get smoothing():Boolean 
		{
			return _realSmoothing;
		}
		/**
		 * 平滑属性
		 */
		override public function set smoothing(value:Boolean):void 
		{
			_realSmoothing = value;
			super.smoothing = value;
		}
	}
}