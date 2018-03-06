package utils 
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	/**
	 * 文本生成器
	 * @author Alex
	 */
	public class TxtGenerator 
	{
		public function TxtGenerator() 
		{
		}
		
		/**
		 * 生成文本文件
		 * @param	url
		 * @param	str
		 * @param	isUTF8
		 */
		public static function generate(url:String, str:String, isUTF8:Boolean = false):void
		{
			var data:ByteArray = new ByteArray();
			//构造一个UTF8的BOM，即3个字节分别是EF BB BF的二进制文件
			if (isUTF8) 
			{
				data.writeByte(0xEF);
				data.writeByte(0xBB);
				data.writeByte(0xBF);
			}
			data.writeUTFBytes(str);
			
			var fs:FileStream = new FileStream();
			var file:File = new File(url);
			fs.open(file, FileMode.WRITE);
			fs.writeBytes(data);
			fs.close();
		}
		
		/**
		 * 读取文本文件
		 * @param	url
		 * @param	charSet
		 * @return
		 */
		public static function read(url:String, charSet:String = null):String
		{
			var file:File = new File(url);
			if (!file.exists || file.isDirectory)
			{
				return "";
			}
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.READ);
			var result_str:String;
			if (charSet == null) 
			{
				result_str = fs.readUTFBytes(fs.bytesAvailable);
			}
			else 
			{
				result_str = fs.readMultiByte(fs.bytesAvailable, charSet);
			}
			
			fs.close();
			return result_str;
		}
	}
}