package modules.ImageAddSpace 
{
	import dragData.vily.DragDataManager;
	import dragData.vily.interfaces.IDragData;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.PNGEncoderOptions;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import modules.IPage;
	import morn.core.events.DragEvent;
	import morn.core.handlers.Handler;
	import morn.ImageAddSpaceUI;
	import utils.ImageCreator;
	
	/**
	 * ...
	 * @author hypo.chen
	 */
	public class ImageAddSpace extends ImageAddSpaceUI implements IDragData, IPage
	{
		//拖拽管理器
		private var _dragDM:DragDataManager;
		private var nativePath:String;
		private var fileName:String;
		private var destPoint:Point;
		private var extension:String;
		private var loader:Loader;
		
		private var lineGraph:Sprite;
		private var maxW:Number;
		
		private var curTargetImageX:Number;
		private var curWidth:Number;
		
		private var imageArr:Array;
		private var handleCount:int;
		
		public function ImageAddSpace() 
		{
			super();
			
			_dragDM = new DragDataManager();
			_dragDM.setTarget(this);
			_dragDM.setReceiver(this);
			
			loader = new Loader();
			destPoint = new Point();
			
			lineGraph = new Sprite();
			this.addChild(lineGraph);
			updateGraphics();
			
			this.addEventListener(Event.RESIZE, resize_handle);
			handle_btn.clickHandler = new Handler(startHandle);
			clear_btn.clickHandler = new Handler(clearOldData);
			
			target_im.addEventListener(DragEvent.DRAG_COMPLETE, image_dragComplete);
			target_im.addEventListener(MouseEvent.MOUSE_DOWN, imageDown);
			
			curTargetImageX = target_im.x;
			curWidth = this.width;
			
			imageArr = [];
			handleCount = 0;
		}
		
		private function updateGraphics():void
		{
			lineGraph.graphics.clear();
			lineGraph.graphics.lineStyle(1, 0x00ff00);
			lineGraph.graphics.moveTo(this.width * 0.5, 0);
			lineGraph.graphics.lineTo(this.width * 0.5, this.height);
		}
		
		private function resize_handle(e:Event = null):void
		{
			target_im.x = curTargetImageX * this.width / curWidth;
			curTargetImageX = target_im.x;
			curWidth = this.width;
			updateGraphics();
		}
		
		private function imageDown(e:MouseEvent):void
		{
			App.drag.doDrag(target_im);
		}
		
		private var wL:Number;
		private var wR:Number;
		
		private function image_dragComplete(e:DragEvent):void
		{
			target_im.y = 0;
			wL = this.width * 0.5 - target_im.x;
			wR = target_im.width + target_im.x - this.width * 0.5;
			maxW = Math.max(wL, wR);
			//trace(target_im.x, target_im.y, target_im.width);
			curTargetImageX = target_im.x;
		}
		
		public function transIn():void
		{
			Log.log("注意：只处理png图片");
			Log.log("1：把需要处理的npc文件夹拖到相应区域");
			Log.log("2：调整居中的位置");
			Log.log("3：点击处理图片按钮");
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
			clearOldData();
			var root_file:File = new File(String(obj.data));
			iterate(root_file);
			for each (var image:File in imageArr)
			{
				if (image.name == "0.png")
				{
					target_im.url = image.url;
					return;
				}
			}
			target_im.url = imageArr[0].url;
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
		
		private function startHandle():void
		{
			handleImage(imageArr[handleCount]);
		}
		
		private function handleImage(image:File):void
		{
			if (image == null)
			{
				Log.log("处理对象不存在");
				return;
			}
			Log.log("处理图片：" + image.nativePath);
			extension = image.extension;
			fileName = image.name;
			nativePath = image.parent.nativePath + "\\";
			
			loader.load(new URLRequest(image.url));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, image_complete);
		}
		
		private function image_complete(e:Event):void
		{
			e.target.removeEventListener(Event.COMPLETE, image_complete);
			
			var loader_bm:Bitmap = e.target.content as Bitmap;
			var loader_bmd:BitmapData = loader_bm.bitmapData;
			
			var sourceRect:Rectangle = new Rectangle(0, 0, maxW * 2, loader_bmd.height);
			var compressor:Object = new PNGEncoderOptions();
			
			var url:String = this.nativePath + fileName;
			destPoint.x = (wL - wR) >= 0 ? 0 : -(wL - wR);
			var frame_bmd:BitmapData = new BitmapData(maxW * 2, loader_bmd.height, true, 0x0);
			frame_bmd.copyPixels(loader_bmd, sourceRect, destPoint, null, null, true);
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
		
		/**
		 * 清除老数据
		 */
		private function clearOldData():void
		{
			while (imageArr.length)
			{
				imageArr.splice(0, 1);
			}
			handleCount = 0;
			target_im.url = null;
			target_im.x = target_im.y = 0;
		}
		
	}

}