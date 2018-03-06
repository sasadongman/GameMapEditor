package 
{
	import com.adobe.crypto.MD5;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import smh.utils.TraceTimer;
	
	/**
	 * ...
	 * @author Alex
	 */
	public class TestMain extends Sprite 
	{
		private var fileStream:FileStream;
        private var filePath:String = "E:/Projects/SmhWorld/trunk/05 源代码/网页端/Main/SmhWorld/bin/assets/animation/battle_lose.swf";//679 KB
		public function TestMain() 
		{
			super();
			if (stage) init();
				else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			//
			TraceTimer.start();
			var file:File = new File(filePath)
			TraceTimer.end("new File()");
			
			TraceTimer.start();
			file.modificationDate;
			TraceTimer.end("修改日期");
			
			var ba:ByteArray = new ByteArray();
			TraceTimer.start();
			fileStream = new FileStream();
			fileStream.open(file, FileMode.READ);
			fileStream.readBytes(ba);
			fileStream.close();
			TraceTimer.end("读取文件");
			//
			TraceTimer.start();
			var md5:String = MD5.hashBinary(ba);
			trace("md5:" + md5);
			TraceTimer.end("MD5转码");
		}
	}
}