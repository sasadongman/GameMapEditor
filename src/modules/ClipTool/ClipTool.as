package modules.ClipTool 
{
	import dragData.vily.DragDataManager;
	import dragData.vily.interfaces.IDragData;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.PNGEncoderOptions;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import utils.ImageCreator;
	import modules.IPage;
	import morn.ClipToolUI;
	import morn.core.handlers.Handler;
	
	/**
	 * ...
	 * @author Alex
	 */
	public class ClipTool extends ClipToolUI implements IDragData, IPage
	{
		//拖拽管理器
		private var _dragDM:DragDataManager;
		private var nativePath:String;
		private var nativeFile:File;
		private var extension:String = null;
		public function ClipTool() 
		{
			super();
			_dragDM = new DragDataManager();
			_dragDM.setTarget(this);
			_dragDM.setReceiver(this);
			//
			align_rg.selectHandler = new Handler(alignHandler);
			align_rg.selectedIndex = 4;
		}
		
		private var offsetRatioX:Number = 0.5;
		private var offsetRatioY:Number = 0.5;
		private function alignHandler(index:int):void 
		{
			switch (index) 
			{
				case 0:
					offsetRatioX = 0;
					offsetRatioY = 0;
				break;
				case 1:
					offsetRatioX = 0.5;
					offsetRatioY = 0;
				break;
				case 2:
					offsetRatioX = 1;
					offsetRatioY = 0;
				break;
				case 3:
					offsetRatioX = 0;
					offsetRatioY = 0.5;
				break;
				case 4:
					offsetRatioX = 0.5;
					offsetRatioY = 0.5;
				break;
				case 5:
					offsetRatioX = 1;
					offsetRatioY = 0.5;
				break;
				case 6:
					offsetRatioX = 0;
					offsetRatioY = 1;
				break;
				case 7:
					offsetRatioX = 0.5;
					offsetRatioY = 1;
				break;
				case 8:
					offsetRatioX = 1;
					offsetRatioY = 1;
				break;
			}
		}
		
		public function transIn():void
		{
			Log.log("支持两种模式：");
			Log.log("1.合图模式：");
			Log.log("	拖动素材所在文件夹到上面窗口");
			Log.log("	素材格式暂时支持png或jpg（一次处理只支持一种，顺序第一张图片的后缀）");
			Log.log("	最终生成的图片格式同原始素材");
			Log.log("2.切图模式：");
			Log.log("	拖动动画png或jpg文件到上面窗口");
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
			nativeFile = new File(String(obj.data));
			
			if (nativeFile.isDirectory) 
			{
				Log.log("拖入了文件夹，进入1.合图模式");
				Log.log("选择了" + (vertical_cb.selected ? "竖排" : "横排") + "模式！");
				nativePath = obj.data + "\\";
				//trace("nativePath:" + nativePath);
				fileNames = [];
				var files:Array = nativeFile.getDirectoryListing();
				for each (var file:File in files)
				{
					if (file.name == "clip.png" || file.name == "clip.jpg") 
					{
						continue;
					}
					if (extension == null)
					{
						if (file.extension == "png" || file.extension == "jpg") 
						{
							extension = file.extension;
							Log.log("图片后缀名确定为." + file.extension + "，其他后缀名将忽略！");
							fileNames.push(file.name);
						}
					}
					else
					{
						if (file.extension == extension)
						{
							fileNames.push(file.name);
						}
					}
				}
				bmd_arr = [];
				loadNext();
			}
			else
			{
				if (nativeFile.extension == "png" || nativeFile.extension == "jpg") 
				{
					Log.log("拖入了图片文件，进入2.切图模式");
					nativePath = nativeFile.parent.nativePath + "\\";
					//trace("nativePath:" + nativePath);
					extension = nativeFile.extension;
					var loader:Loader = new Loader();
					loader.load(new URLRequest(nativeFile.url));
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, image_complete);
				}
				else 
				{
					Log.log("拖入的文件无法处理！");
				}
			}
		}
		//========================================切图功能=============================================
		private function image_complete(e:Event):void 
		{
			e.target.removeEventListener(Event.COMPLETE, image_complete);
			
			var loaderInfo:LoaderInfo = e.target as LoaderInfo;
			var loader:Loader = loaderInfo.loader;
			var loader_bm:Bitmap = loader.content as Bitmap;
			//
			var source_bmd:BitmapData = loader_bm.bitmapData;
			loader.unload();
			//
			var clipX:int = int(clipX_ti.text);
			var clipY:int = int(clipY_ti.text);
			var frame_width:int = source_bmd.width / clipX;
			var frame_height:int = source_bmd.height / clipY;
			var destPoint:Point = new Point();
			var sourceRect:Rectangle = new Rectangle(0, 0, frame_width, frame_height);
			var transparent:Boolean = extension == "png";
			var compressor:Object = transparent ? new PNGEncoderOptions() : new JPEGEncoderOptions();
			for (var y:int = 0; y < clipY; y++) 
			{
				for (var x:int = 0; x < clipX; x++) 
				{
					sourceRect.x = x * frame_width;
					sourceRect.y = y * frame_height;
					var fileName:String = y + "_" + x + "." + extension;
					var url:String = this.nativePath + fileName;
					var frame_bmd:BitmapData = new BitmapData(frame_width, frame_height, transparent, 0x0);
					frame_bmd.copyPixels(source_bmd, sourceRect, destPoint, null, null, transparent);
					ImageCreator.createImage(url, frame_bmd, compressor);
					frame_bmd.dispose();
				}
			}
			source_bmd.dispose();
		}
		
		//========================================合图功能=============================================
		private var bmd_arr:Array;
		private var fileNames:Array;
		private function loadNext():void
		{
			if (fileNames.length == 0) 
			{
				loadFinish();
				return;
			}
			var curFileName:String = fileNames.shift();
			
			var loader:Loader = new Loader();
			//loader.load(new URLRequest(nativePath + curFileName + ".png"));
			loader.load(new URLRequest(nativePath + curFileName));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_complete);
		}
		
		private function loader_complete(e:Event):void 
		{
			e.target.removeEventListener(Event.COMPLETE, loader_complete);
			
			var loaderInfo:LoaderInfo = e.target as LoaderInfo;
			var loader:Loader = loaderInfo.loader;
			var loader_bm:Bitmap = loader.content as Bitmap;
			//
			bmd_arr.push(loader_bm.bitmapData.clone());
			loader_bm.bitmapData.dispose();
			loader.unload();
			//
			loadNext();
		}
		
		
		//文件夹内图片全部加载完成
		private function loadFinish():void
		{
			if (bmd_arr == null || bmd_arr.length == 0) 
			{
				return;
			}
			var limit_num:int = int(limit_ti.text);
			if (limit_num <= 0) 
			{
				limit_num = int.MAX_VALUE;
			}
			var frame_width:int = 0;
			var frame_height:int = 0;
			var bmd:BitmapData;
			for each (bmd in bmd_arr)
			{
				if (bmd.width > frame_width)
				{
					frame_width = bmd.width;
				}
				if (bmd.height > frame_height)
				{
					frame_height = bmd.height;
				}
			}
			var destPoint:Point = new Point();
			var sourceRect:Rectangle = new Rectangle(0, 0, frame_width, frame_height);
			//除数
			var divisor:int = Math.ceil(bmd_arr.length / limit_num);
			//余数
			var remainder:int = Math.min(bmd_arr.length, limit_num);
			var total_width:int;
			var total_height:int;
			if (vertical_cb.selected)
			{
				total_width = divisor * frame_width;
				total_height = remainder * frame_height;
			}
			else 
			{
				total_width = remainder * frame_width;
				total_height = divisor * frame_height;
			}
			var transparent:Boolean = extension == "png";
			var total_bmd:BitmapData = new BitmapData(total_width, total_height, transparent, 0x0);
			var index:int = 0;
			var offsetX:int;
			var offsetY:int;
			for each (bmd in bmd_arr)
			{
				//除数
				divisor = index / limit_num;
				//余数
				remainder = index % limit_num;
				//
				offsetX = (frame_width - bmd.width) * offsetRatioX;
				offsetY = (frame_height - bmd.height) * offsetRatioY;
				if (vertical_cb.selected)
				{
					destPoint.x = divisor * frame_width + offsetX;
					destPoint.y = remainder * frame_height + offsetY;
				}
				else 
				{
					destPoint.x = remainder * frame_width + offsetX;
					destPoint.y = divisor * frame_height + offsetY;
				}
				total_bmd.copyPixels(bmd, sourceRect, destPoint, null, null, transparent);
				index++;
			}
			var url:String = this.nativePath + "clip." + extension;
			ImageCreator.createImage(url, total_bmd, transparent ? new PNGEncoderOptions() : new JPEGEncoderOptions());
			Log.log("Clip图片生成：" + url);
			total_bmd.dispose();
			total_bmd = null;
			//清除
			for each (bmd in bmd_arr)
			{
				bmd.dispose();
			}
			bmd_arr = null;
			fileNames = null;
		}
	}
}