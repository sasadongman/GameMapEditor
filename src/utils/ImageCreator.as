package utils 
{
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.JPEGXREncoderOptions;
	import flash.display.PNGEncoderOptions;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	/**
	 * png生成
	 * @author Alex
	 */
	public class ImageCreator 
	{
		public static function createImage(fileUrl:String, bd:BitmapData, compressor:Object = null):void
		{
			if (compressor == null) 
			{
				compressor = new PNGEncoderOptions();
				//JPEGXREncoderOptions (quantization:uint=20, colorSpace:String="auto", trimFlexBits:uint=0) …
				//compressor = new JPEGXREncoderOptions(20);
			}
			var jpg_bmd:BitmapData = bd.clone();
			var imgByteArray:ByteArray = jpg_bmd.encode(jpg_bmd.rect, compressor);
			jpg_bmd.dispose();
			//trace("fileUrl:" + fileUrl);
			//var file:File = new File(fileUrl + "_xr.jpg");
			var file:File = new File(fileUrl);
			//file.url = fileUrl;
			//Use a FileStream to save the bytearray as bytes to the new file
			var fs:FileStream = new FileStream();
			try
			{
				//open file in write mode
				fs.open(file,FileMode.WRITE);
				//write bytes from the byte array
				fs.writeBytes(imgByteArray);
				//close the file
				fs.close();
			}
			catch (e:Error)
			{
				trace(e.message);
			}
			//
			/*var alpha_bmd:BitmapData = new BitmapData(bd.rect.width, bd.rect.height, true, 0x0);
			//var alphaByteArray:ByteArray = new ByteArray();
			for (var x:int = 0; x < alpha_bmd.rect.width; x++) 
			{
				for (var y:int = 0; y < alpha_bmd.rect.height; y++) 
				{
					//alpha_bmd.setPixel32(x, y, (alpha_bmd.getPixel32(x, y) >> 24) << 24);
					//alpha_bmd.setPixel(x, y, 0xff000000 + bd.getPixel(x, y) >> 24 << 0);
					alpha_bmd.setPixel32(x, y, bd.getPixel32(x, y) >> 24 << 24);
					//alphaByteArray.writeShort(alpha_bmd.getPixel32(x, y) >> 24);
				}
			}
			imgByteArray = alpha_bmd.encode(alpha_bmd.rect, new PNGEncoderOptions());
			//imgByteArray = alpha_bmd.encode(alpha_bmd.rect, new JPEGEncoderOptions(80));
			alpha_bmd.dispose();
			//alphaByteArray.compress();
			file = new File(fileUrl + "_alpha.jpg");
			fs = new FileStream();
			try
			{
				//open file in write mode
				fs.open(file,FileMode.WRITE);
				//write bytes from the byte array
				fs.writeBytes(imgByteArray);
				//fs.writeBytes(alphaByteArray);
				//close the file
				fs.close();
			}
			catch (e:Error)
			{
				trace(e.message);
			}*/
		}
	}

}