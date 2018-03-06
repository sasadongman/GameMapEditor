package modules.VersionTool 
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Alex
	 */
	public class UniteDataUtil 
	{
		//public static const UNITE_DAT_URL:String = "type_1.dat";
		public static const UNITE_DAT_URL:String = "unite.dat";
		private static var root_folder:File;
		private static var unite_dat_file:File;
		private static var unite_dat_ba:ByteArray;
		public function UniteDataUtil() 
		{
		}
		public static function packageUniteData(folder_url:String):void
		{
			root_folder = new File(folder_url);
			unite_dat_file = root_folder.resolvePath(UNITE_DAT_URL);
			//
			//testReadFile(unite_dat_file);
			//return;
			//
			unite_dat_ba = new ByteArray();
			iterationHandle(root_folder);
			unite_dat_ba.compress();
			var fs:FileStream = new FileStream();
			fs.open(unite_dat_file, FileMode.WRITE);
			fs.writeBytes(unite_dat_ba);
			fs.close();
		}
		
		private static function testReadFile(file:File):void
		{
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.READ);
			var ba:ByteArray = new ByteArray();
			fs.readBytes(ba);
			ba.uncompress();
			ba.position = 0;
			while (ba.bytesAvailable > 0) 
			{
				var path_len:int = ba.readByte();
				var path_str:String = ba.readUTFBytes(path_len);
				var content_len:int = ba.readInt();
				var content_ba:ByteArray = new ByteArray();
				ba.readBytes(content_ba, 0, content_len);
				//content_ba.uncompress();
				var content_str:String = content_ba.readUTFBytes(content_ba.length);
				
				trace("-----path_str:" + path_str);
				trace("-----content_str:\n" + content_str);
			}
		}
		
		private static function iterationHandle(folder_file:File):void
		{
			for each (var file:File in folder_file.getDirectoryListing()) 
			{
				//if (file.name == "unite.dat") 
				if (file.extension == "dat") 
				{
					continue;
				}
				else if (file.isDirectory) 
				{
					iterationHandle(file);
				}
				else 
				{
					var relativePath:String = root_folder.getRelativePath(file);
					//trace("relativePath:" + relativePath);
					unite_dat_ba.writeByte(relativePath.length);
					unite_dat_ba.writeUTFBytes(relativePath);
					
					var utf_str:String = "";
					var fs:FileStream = new FileStream();
					fs.open(file, FileMode.READ);
					utf_str = fs.readUTFBytes(fs.bytesAvailable);
					fs.close();
					
					var ba:ByteArray = new ByteArray();
					ba.writeUTFBytes(utf_str);
					//ba.compress();
					ba.position = 0;
					unite_dat_ba.writeInt(ba.length);
					unite_dat_ba.writeBytes(ba);
				}
			}
		}
	}
}