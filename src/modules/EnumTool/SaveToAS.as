package modules.EnumTool
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileReference;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	import utils.TxtGenerator;
	
	/**
	 * @author: hypo.chen
	 * @E-mail: 645338868@qq.com
	 * @create: 2015-10-26 下午2:31:57
	 *
	 */
	public class SaveToAS
	{
		private static var _instance:SaveToAS;
		
		public function SaveToAS(s:S)
		{
		}
		
		public static function getInstance():SaveToAS
		{
			if (_instance == null)
			{
				_instance = new SaveToAS(new S());
			}
			return _instance;
		}
		
		public function getAS($str:String):void
		{
			//Log.log($str);
			//var file:FileReference = new FileReference();
			//file.save($str,AppConfig.constructorName + ".as");
			
			//$str = transEncode($str, "gbk");
			//$str = transEncode($str, "gb2312");
			//$str = transEncode($str, "big5");
			
			//var fs:FileStream = new FileStream();
			////fs.open(file, FileMode.READ);
			////var fileStr:String = fs.readUTFBytes(fs.bytesAvailable)
			////fileStr = fileStr.replace("package", "package " + PACKAGE_NAME);
			//
			//var data:ByteArray = new ByteArray();
			////构造一个UTF8的BOM，即3个字节分别是EF BB BF的二进制文件
			//data.writeByte(0xEF);
			//data.writeByte(0xBB);
			//data.writeByte(0xBF);
			//
			//data.writeUTFBytes($str);
			////fs.close();
			//
			//var move_file:File = new File(AppConfig.SAVE_URL + "\\" + AppConfig.constructorName+".as");
			//fs.open(move_file, FileMode.WRITE);
			////fs.truncate();
			//fs.writeBytes(data);
			//fs.close();
			
			var move_file_str:String = AppConfig.SAVE_URL + "\\" + AppConfig.constructorName + ".as";
			var move_file:File = new File(move_file_str);
			TxtGenerator.generate(move_file_str, $str, true);
			Log.log("保存路径：" + AppConfig.SAVE_URL);
			Log.log("生成as类：" + move_file.name);
		}
	}
}

class S
{
}