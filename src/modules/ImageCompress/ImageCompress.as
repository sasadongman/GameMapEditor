package modules.ImageCompress 
{
	import dragData.vily.DragDataManager;
	import dragData.vily.interfaces.IDragData;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.Loader;
	import flash.display.PNGEncoderOptions;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import modules.IPage;
	import morn.ImageCompressUI;
	import utils.ImageCreator;
	
	/**
	 * ...
	 * @author hypo.chen
	 */
	public class ImageCompress extends ImageCompressUI implements IDragData, IPage
	{
		//拖拽管理器
		private var _dragDM:DragDataManager
		private var extension:String;
		private var nativePath:String;
		private var fileName:String;
		private var destPoint:Point;
		private var imageArr:Array;
		private var loader:Loader;
		private var handleCount:int;
		
		public function ImageCompress() 
		{
			super();
			
			_dragDM = new DragDataManager();
			_dragDM.setTarget(this);
			_dragDM.setReceiver(this);
			
			loader = new Loader();
			destPoint = new Point();
			handleCount = 0;
			imageArr = [];
			
			this.ratio_ti.text = "80";
		}
		
		public function transIn():void
		{
			Log.log("1：本压缩只支持jpg和png两种格式");
		}
		public function transOut():void
		{
			
		}
		
		/**
			添加数据到接收者
			@param		obj:{format:"数据类型",data:*,x:0,y:0},format表示的数据类型都包含在dragData.vily.data.DragDataFormat中
						x和y属性记录了拖动时放开鼠标的位置坐标
		*/
		public function setDragData(obj:Object):void
		{
			var root_file:File = new File(String(obj.data));
			iterate(root_file);
			if (imageArr.length) 
			{
				handleImage(imageArr[handleCount]);
			}
		}
		
		/**
		 * 迭代
		 * @param	file
		 */
		private function iterate(file:File):void
		{
			if (file.isDirectory)
			{
				//文件夹
				var sub_files:Array = file.getDirectoryListing();
				for each (var sub_file:File in sub_files) 
				{
					iterate(sub_file);
				}
			}
			else if (file.extension == "png" || file.extension == "jpg") 
			{
				imageArr.push(file);
			}
		}
		
		private function handleImage(image:File):void 
		{
			Log.log("处理图片：" + image.nativePath);
			//Log.log("image.name：" + image.name);
			fileName = image.name;
			nativePath = image.parent.nativePath + "\\";
			extension = image.extension;
			
			loader.load(new URLRequest(image.url));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, image_complete);
		}
		
		private function image_complete(e:Event):void
		{
			e.target.removeEventListener(Event.COMPLETE, image_complete);
			
			var loader_bm:Bitmap = e.target.content as Bitmap;
			var loader_bmd:BitmapData = loader_bm.bitmapData;
			
			var sourceRect:Rectangle = new Rectangle(0, 0, loader_bmd.width, loader_bmd.height);
			var transparent:Boolean = extension == "png";
			var compressor:Object = transparent ? new PNGEncoderOptions() : new JPEGEncoderOptions(int(this.ratio_ti.text));
			
			var url:String = this.nativePath + fileName;
			
			var frame_bmd:BitmapData = new BitmapData(loader_bmd.width, loader_bmd.height, transparent, 0x0);
			frame_bmd.copyPixels(loader_bmd, sourceRect, destPoint, null, null, transparent);
			ImageCreator.createImage(url, frame_bmd, compressor);
			frame_bmd.dispose();
			
			handleCount++;
			//trace("handleCount:" + handleCount, imageArr.length);
			if (handleCount == imageArr.length) 
			{
				Log.log("所有图片处理完毕");
				loader.unload();
			}
			else 
			{
				handleImage(imageArr[handleCount]);
			}
		}
		
	}

}