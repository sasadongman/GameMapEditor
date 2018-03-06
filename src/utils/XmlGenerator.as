package utils 
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	/**
	 * XML生成器
	 * @author Alex
	 */
	public class XmlGenerator 
	{
		
		public function XmlGenerator() 
		{
			
		}
		
		/**
		 * 生成
		 * @param	url
		 * @param	xml
		 */
		public static function generate(url:String, xml:XML):void
		{
			var data:ByteArray = new ByteArray();
			//构造一个UTF8的BOM，即3个字节分别是EF BB BF的二进制文件
			data.writeByte(0xEF);
			data.writeByte(0xBB);
			data.writeByte(0xBF);
			data.writeUTFBytes("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
			data.writeUTFBytes(xml.toXMLString());
			
			var fs:FileStream = new FileStream();
			var file:File = new File(url);
			fs.open(file, FileMode.WRITE);
			//fs.truncate();
			fs.writeBytes(data);
			fs.close();
		}
	}

}