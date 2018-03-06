package modules.ComicsTool 
{
	import dragData.vily.DragDataManager;
	import dragData.vily.interfaces.IDragData;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.setTimeout;
	import modules.IPage;
	import morn.ComicsToolUI;
	import morn.core.handlers.Handler;
	import utils.ImageCreator;
	
	/**
	 * ...
	 * @author Alex
	 */
	public class ComicsTool extends ComicsToolUI implements IDragData, IPage
	{
		//拖拽管理器
		private var _dragDM:DragDataManager;
		private var nativePath:String;
		private var nativeFile:File;
		private var extension:String = null;
		private var file_arr:Array;
		private var total_len:int;
		private var cur_index:int;
		
		public function ComicsTool() 
		{
			super();
			_dragDM = new DragDataManager();
			_dragDM.setTarget(this);
			_dragDM.setReceiver(this);
			//
			mode_cb.selectHandler = new Handler(modeUpdateHandle);
			modeUpdateHandle();
		}
		
		private var cut_columns:int;
		private var cut_rows:int;
		private function modeUpdateHandle(index:int = 0):void
		{
			switch (index) 
			{
				case 0:
					cut_columns = 2;
					cut_rows = 2;
				break;
				case 1:
					cut_columns = 3;
					cut_rows = 2;
				break;
			}
		}
		
		public function transIn():void
		{
			Log.log("拖动漫画所在文件夹到上面窗口");
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
			setCutRects();
			//
			file_arr = [];
			total_len = 0;
			cur_index = 0;
			//
			var root_file:File = new File(String(obj.data));
			iterate(root_file);
			iterationLoadFile();
		}
		
		private var limitWidth:int;
		private var limitHeight:int;
		private var quantization:int = 80;
		private var leftRects:Array;
		private var rightRects:Array;
		//设定裁剪的矩形
		private function setCutRects():void
		{
			limitWidth = int(limit_w_it.text);
			limitHeight = int(limit_h_it.text);
			quantization = int(quantization_it.text);
			//
			var x:int;
			var y:int;
			var w:int;
			var h:int;
			var r:int;
			var c:int;
			//左
			x = int(left_x_it.text);
			y = int(left_y_it.text);
			w = int(left_w_it.text) / cut_columns;
			h = int(left_h_it.text) / cut_rows;
			leftRects = [];
			for (r = 0; r < cut_rows; r++) 
			{
				for (c = 0; c < cut_columns; c++)
				{
					leftRects.push(new Rectangle(x + c * w, y + r * h, w, h));
				}
			}
			//leftRects = [new Rectangle(x, y, w, h), new Rectangle(x + w, y, w, h), new Rectangle(x, y + h, w, h), new Rectangle(x + w, y + h, w, h)];
			//右
			x = int(right_x_it.text);
			y = int(right_y_it.text);
			w = int(right_w_it.text) / cut_columns;
			h = int(right_h_it.text) / cut_rows;
			//rightRects = [new Rectangle(x, y, w, h), new Rectangle(x + w, y, w, h), new Rectangle(x, y + h, w, h), new Rectangle(x + w, y + h, w, h)];
			rightRects = [];
			for (r = 0; r < cut_rows; r++) 
			{
				for (c = 0; c < cut_columns; c++)
				{
					rightRects.push(new Rectangle(x + c * w, y + r * h, w, h));
				}
			}
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
			else if (file.extension == "jpg")
			{
				file_arr.push(file.nativePath);
				total_len++;
			}
		}
		
		private function iterationLoadFile():void
		{
			var loader:Loader = new Loader();
			loader.load(new URLRequest(file_arr[cur_index]));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, image_complete);
		}
		
		private function image_complete(e:Event):void 
		{
			e.target.removeEventListener(Event.COMPLETE, image_complete);
			
			var loaderInfo:LoaderInfo = e.target as LoaderInfo;
			var loader:Loader = loaderInfo.loader;
			var loader_bm:Bitmap = loader.content as Bitmap;
			var file:File = new File(loaderInfo.url);
			cutFile(file, loader_bm.bitmapData);
			
			loader.unload();
			if (delete_cb.selected) 
			{
				file.deleteFile();
			}
			file = null;
		}
		
		private var destPoint:Point = new Point();
		private function cutFile(file:File, bmd:BitmapData):void
		{
			Log.log("处理图片：" + file.nativePath);
			var fileName:String = file.name.substr(0, file.name.length - 4);
			var rects:Array = int(fileName.charAt(1)) % 2 == 0 ? leftRects : rightRects;
			for (var i:int = 0; i < rects.length; i++) 
			{
				var page_rect:Rectangle = rects[i];
				var page_bmd:BitmapData = new BitmapData(page_rect.width, page_rect.height, false, 0x0);
				page_bmd.copyPixels(bmd, page_rect, destPoint);
				
				var page_file:File = file.parent.resolvePath(fileName + "_" + (i + 1) + ".jpg");
				createPage(page_file.nativePath, page_bmd);
				
				page_bmd.dispose();
			}
			bmd.dispose();
			//
			cur_index++;
			if (cur_index == total_len) 
			{
				Log.log("全部图片处理完成！");
			}
			else 
			{
				//iterationLoadFile();
				setTimeout(iterationLoadFile, 100);
			}
		}
		
		private function createPage(path:String, page_bmd:BitmapData):void
		{
			var scale_bmd:BitmapData;
			if ((limitWidth == 0 || limitWidth >= page_bmd.width) && (limitHeight == 0 || limitHeight >= page_bmd.height)) 
			{
				//可以按照原始尺寸
				scale_bmd = page_bmd;
			}
			else 
			{
				var ratio_w:Number = limitWidth == 0 ? 1 : limitWidth / page_bmd.width;
				var ratio_h:Number = limitHeight == 0 ? 1 : limitHeight / page_bmd.height;
				var ratio:Number = Math.min(ratio_w, ratio_h);
				var scale_width:int = ratio * page_bmd.width;
				var scale_height:int = ratio * page_bmd.height;
				
				var spr:Sprite = new Sprite();
				var bm:Bitmap = new Bitmap(page_bmd);
				bm.scaleX = bm.scaleY = ratio;
				spr.addChild(bm);
				
				scale_bmd = new BitmapData(scale_width, scale_height, false, 0x0);
				scale_bmd.draw(spr, null, null, null, null, true);
			}
			ImageCreator.createImage(path, scale_bmd, new JPEGEncoderOptions(quantization));
			Log.log("生成图片：" + path);
		}
	}
}