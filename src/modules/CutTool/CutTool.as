package modules.CutTool 
{
	import dragData.vily.DragDataManager;
	import dragData.vily.interfaces.IDragData;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import modules.IPage;
	import morn.CutToolUI;
	import utils.ImageCreator;
	
	/**
	 * ...
	 * @author Alex
	 */
	public class CutTool extends CutToolUI implements IDragData, IPage
	{
		//拖拽管理器
		private var _dragDM:DragDataManager;
		public function CutTool() 
		{
			super();
			_dragDM = new DragDataManager();
			_dragDM.setTarget(this);
			_dragDM.setReceiver(this);
		}
		
		public function transIn():void
		{
			Log.log("拖动png文件或者文件夹到上面窗口");
			Log.log("注：原图片会被替换！");
		}
		
		public function transOut():void
		{
			
		}
		
		/* INTERFACE dragData.vily.interfaces.IDragData */
		/**
			添加数据到接收者
			@param		obj:{format:"数据类型",data:*,x:0,y:0},format表示的数据类型都包含在dragData.vily.data.DragDataFormat中
						x和y属性记录了拖动时放开鼠标的位置坐标
		*/
		public function setDragData(obj:Object):void
		{
			//trace("obj.format:" + obj.format);
			//trace("obj.data:" + obj.data);
			var root_file:File = new File(String(obj.data));
			iterate(root_file);
			Log.log("处理完成！");
		}
		
		private function iterate(file:File):void
		{
			if (file.isDirectory)
			{
				var sub_files:Array = file.getDirectoryListing()
				for each (var sub_file:File in sub_files) 
				{
					iterate(sub_file);
				}
			}
			else if (file.extension == "png")
			{
				Log.log("处理图片：" + file.nativePath);
				var loader:Loader = new Loader();
				loader.load(new URLRequest(file.url));
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, image_complete);
			}
		}
		
		private var destPoint:Point = new Point();
		private function image_complete(e:Event):void 
		{
			e.target.removeEventListener(Event.COMPLETE, image_complete);
			
			var loaderInfo:LoaderInfo = e.target as LoaderInfo;
			var loader:Loader = loaderInfo.loader;
			var loader_bm:Bitmap = loader.content as Bitmap;
			var minRect:Rectangle = loader_bm.bitmapData.getColorBoundsRect(0xffffffff, 0x00000000, false);
			if (minRect.width > 0 && minRect.height > 0)
			{
				var minBmd:BitmapData = new BitmapData(minRect.width, minRect.height, true, 0);
				minBmd.copyPixels(loader_bm.bitmapData, minRect, destPoint, null, null, true);
				ImageCreator.createImage(loaderInfo.url, minBmd);
			}
		}
	}
}