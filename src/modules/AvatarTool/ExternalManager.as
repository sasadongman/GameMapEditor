package modules.AvatarTool 
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	/**
	 * 外部交互管理器
	 * @author Alex
	 */
	public class ExternalManager 
	{
		public function ExternalManager() 
		{
		}
		
		private static const AVATAR_JSFL_URL:String = "jsfl/avatar.jsfl";
		
		public static function callAvatarJsfl(value:Object):void
		{
			trace("ExternalManager/callAvatarJsfl()");
			var binJsflFile:File = File.applicationDirectory.resolvePath(AVATAR_JSFL_URL);
			var storageJsflFile:File = File.applicationStorageDirectory.resolvePath(AVATAR_JSFL_URL);
			trace("storageJsflFile:" + storageJsflFile.nativePath);
			
			var fs:FileStream = new FileStream();
			fs.open(binJsflFile, FileMode.READ);
			var fileStr:String = fs.readUTFBytes(fs.bytesAvailable)
			if (value != null) 
			{
				for (var key:String in value)
				{
					fileStr = fileStr.replace("%" + key + "%", value[key]);
				}
			}
			
			var data:ByteArray = new ByteArray();
			//构造一个UTF8的BOM，即3个字节分别是EF BB BF的二进制文件
			data.writeByte(0xEF);
			data.writeByte(0xBB);
			data.writeByte(0xBF);
			
			data.writeUTFBytes(fileStr);
			fs.close();
			
			fs.open(storageJsflFile, FileMode.WRITE);
			//fs.truncate();
			fs.writeBytes(data);
			fs.close();
			
			storageJsflFile.openWithDefaultApplication();
		}
		
		private static const JSFL_URL:String = "jsfl/package.jsfl";
		
		public static function callJsfl(value:Object):void
		{
			trace("ExternalManager/callJsfl()");
			var binJsflFile:File = File.applicationDirectory.resolvePath(JSFL_URL);
			var storageJsflFile:File = File.applicationStorageDirectory.resolvePath(JSFL_URL);
			trace("storageJsflFile:" + storageJsflFile.nativePath);
			
			var fs:FileStream = new FileStream();
			fs.open(binJsflFile, FileMode.READ);
			var fileStr:String = fs.readUTFBytes(fs.bytesAvailable)
			if (value != null) 
			{
				for (var key:String in value)
				{
					fileStr = fileStr.replace("%" + key + "%", value[key]);
				}
			}
			
			var data:ByteArray = new ByteArray();
			//构造一个UTF8的BOM，即3个字节分别是EF BB BF的二进制文件
			data.writeByte(0xEF);
			data.writeByte(0xBB);
			data.writeByte(0xBF);
			
			data.writeUTFBytes(fileStr);
			fs.close();
			
			fs.open(storageJsflFile, FileMode.WRITE);
			//fs.truncate();
			fs.writeBytes(data);
			fs.close();
			
			storageJsflFile.openWithDefaultApplication();
		}
	}
}