package modules.AvatarTool 
{
	import dragData.vily.DragDataManager;
	import dragData.vily.interfaces.IDragData;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import modules.IPage;
	import morn.AvatarToolUI;
	import utils.FlashCookie;
	import utils.FlashCookieConst;
	import utils.ImageCreator;
	
	/**
	 * ...
	 * @author Alex
	 */
	public class AvatarTool extends AvatarToolUI implements IDragData, IPage
	{
		//拖拽管理器
		private var _dragDM:DragDataManager;
		public function AvatarTool() 
		{
			super();
			_dragDM = new DragDataManager();
			_dragDM.setTarget(this);
			_dragDM.setReceiver(this);
			
			if (FlashCookie.getValue(FlashCookieConst.AVATAR_SWFFOLDER) != null)
			{
				swfFolder_it.text = FlashCookie.getValue(FlashCookieConst.AVATAR_SWFFOLDER);
			}
			else 
			{
				FlashCookie.setValue(FlashCookieConst.AVATAR_SWFFOLDER, swfFolder_it.text);
			}
			cocos2dx_cb.selected = Boolean(FlashCookie.getValue(FlashCookieConst.AVATAR_COCOS2DX));
			cocos2dx_cb.addEventListener(Event.SELECT, cocos2dx_cb_select);
			
			record_btn.addEventListener(MouseEvent.CLICK, record_btn_click);
		}
		
		private function cocos2dx_cb_select(e:Event):void 
		{
			FlashCookie.setValue(FlashCookieConst.AVATAR_COCOS2DX, cocos2dx_cb.selected);
		}
		
		public function transIn():void
		{
			Log.log("支持两种模式：");
			Log.log("1.Flash模式");
			Log.log("2.Cocos2d-x模式（勾选\"Cocos2d-x\"）");
		}
		
		public function transOut():void
		{
			
		}
		
		private function record_btn_click(e:MouseEvent):void 
		{
			FlashCookie.setValue(FlashCookieConst.AVATAR_SWFFOLDER, swfFolder_it.text);
		}
		
		//物品id
		private var item_id:int;
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
			
			nativePath = obj.data + "\\";
			//trace("nativePath:" + nativePath);
			
			nativeFile = new File(String(obj.data));
			
			if (!nativeFile.isDirectory) 
			{
				Log.log("请拖入文件夹！");
				return;
			}
			
			nativeFolderName = nativeFile.name;
			
			swfFolderFile = new File(swfFolder_it.text);
			//使用空格隔开，数组第0个表示序号id
			var temp_arr:Array = nativeFolderName.split(" ");
			//swfFolderFile = new File(swfFolder_it.text + "\\" + int(temp_arr[0]));
			item_id = 200000000 + int(temp_arr[0]);
			
			swfFolder = swfFolderFile.url;
			
			//this.startTime = getTimer();
			Log.log("开始处理文件夹:" + nativeFile.nativePath);
			
			fileNames = [];
			bmdDict = new Dictionary();
			minBmdDict = new Dictionary();
			var files:Array = nativeFile.getDirectoryListing();
			for each (var file:File in files)
			{
				if (file.extension == "png" || file.extension == "jpg")
				{
					//var temp_file_name:String = file.name.substr(0, file.name.length - file.extension.length - 1);
					var endCharIndex:int = file.name.length - file.extension.length - 2;
					var nameEndChar:String = file.name.charAt(endCharIndex);
					//根据文件名最后一个字符判断，如不是数字就打包swf，如果是数字就直接复制文件
					//if (isNaN(Number(temp_file_name.charAt(temp_file_name.length - 1))))
					if (isNaN(Number(nameEndChar)))
					{
						//fileNames.push(temp_file_name);
						fileNames.push(file.name);
					}
					else 
					{
						//var targetFile:File = swfFolderFile.resolvePath(file.name);
						var temp_item_id:int = item_id + int(file.name.substring(0, endCharIndex + 1)) * 100000;
						var targetFile:File = swfFolderFile.resolvePath(temp_item_id + "." + file.extension);
						file.copyTo(targetFile, true);
					}
				}
			}
			//删除旧文件
			for each (file in swfFolderFile.getDirectoryListing())
			{
				checkDeleteFile(file, int(temp_arr[0]));
			}
			loadNext();
		}
		
		private var startNum:int = 0;
		private var maxNum:int = 0;
		private var num_re:RegExp = /(\d*)/;
		private function checkDeleteFile(file:File, end_five_num:int):void
		{
			if (file.extension != "swf")
			{
				return;
			}
			var fileName:String = file.name;
			var re_obj:Object = num_re.exec(fileName);
			if (re_obj == null)
			{
				return;
			}
			var id_str:String = re_obj[1];
			if (id_str.length != 9) 
			{
				return;
			}
			var id:int = int(id_str);
			var part:int = int(id_str.substr(2, 2));
			if (part == 0 || part == 1 || part == 2)
			{
				return;
			}
			var five_num:int = int(id_str.substr(4));
			if (five_num == end_five_num) 
			{
				file.deleteFile();
			}
		}
		
		private var nativeFile:File;
		private var swfFolderFile:File;
		private var swfFolder:String;
		private var nativePath:String;
		private var nativeFolderName:String;
		private var fileNames:Array;
		private var curFileName:String;
		private var bmdDict:Dictionary;
		private var minBmdDict:Dictionary;
		private function loadNext():void
		{
			if (fileNames.length == 0) 
			{
				if (cocos2dx_cb.selected) 
				{
					loadFinishCocosdx();
				}
				else 
				{
					loadFinish();
				}
				return;
			}
			curFileName = fileNames.shift();
			
			var loader:Loader = new Loader();
			//loader.load(new URLRequest(nativePath + curFileName + ".png"));
			loader.load(new URLRequest(nativePath + curFileName));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_complete);
		}
		
		private function loader_complete(e:Event):void 
		{
			var loaderInfo:LoaderInfo = e.target as LoaderInfo;
			var loader:Loader = loaderInfo.loader;
			var loader_bm:Bitmap = loader.content as Bitmap;
			//
			bmdDict[curFileName] = loader_bm.bitmapData;
			//
			loadNext();
		}
		
		private var destPoint:Point = new Point();
		//文件夹内图片全部加载完成
		private function loadFinish():void
		{
			var frameTime:int = 1000 / int(frameRate_it.text);
			var imageInfoArr:Array = [];
			for (var imageName:String in bmdDict)
			{
				var name_arr:Array = imageName.split(".");
				var image_name_no_extention:String = name_arr[0];
				var temp_item_id:int = item_id + int(image_name_no_extention.substr(0, image_name_no_extention.length - 1)) * 100000;
				var temp_item_name:String = temp_item_id + image_name_no_extention.charAt(image_name_no_extention.length - 1);
				var extention:String = name_arr[1];
				if (extention == "png")
				{
					var bmd:BitmapData = bmdDict[imageName];
					var minRect:Rectangle = bmd.getColorBoundsRect(0xffffffff, 0x00000000, false);
					var minBmd:BitmapData = new BitmapData(minRect.width, minRect.height, true, 0);
					//copyPixels (sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, alphaBitmapData:BitmapData = null, alphaPoint:Point = null, mergeAlpha:Boolean = false) : void …
					minBmd.copyPixels(bmd, minRect, destPoint, null, null, true);
					//clippingInfo.imageArray.push( { name:imageLoader.name, bmd:minBmd } );
					
					//ImageCreator.createImage(this.nativePath + image_name_no_extention, minBmd);
					ImageCreator.createImage(this.nativePath + temp_item_name, minBmd);
					
					//var imageInfo:String = "{n:\"" + image_name_no_extention + "\",x:" + minRect.x + ",y:" + minRect.y + ",time:" + frameTime + "}";
					var imageInfo:String = "{n:\"" + temp_item_name + "\",x:" + minRect.x + ",y:" + minRect.y + ",time:" + frameTime + "}";
				}
				else 
				{
					var file:File = new File(this.nativePath + imageName);
					//var copy_file:File = new File(this.nativePath + image_name_no_extention);
					var copy_file:File = new File(this.nativePath + temp_item_name);
					file.copyTo(copy_file, true);
					//imageInfo = "{n:\"" + image_name_no_extention + "\",x:" + 0 + ",y:" + 0 + ",time:" + 0 + "}";
					imageInfo = "{n:\"" + temp_item_name + "\",x:" + 0 + ",y:" + 0 + ",time:" + 0 + "}";
				}
				imageInfoArr.push(imageInfo);
			}
			//return;
			//var nativePath:String = nativePath;
			var nativePath:String = nativeFile.url;
			//{imageName:{x:100,y:100},imageName:{x:100,y:100}}
			//var imagesInfo:String = "{" + imageInfoArr.join(",") + "}";
			var imagesInfo:String = "[" + imageInfoArr.join(",") + "]";
			//
			ExternalManager.callJsfl( { nativePath:nativePath, nativeFolderName:nativeFolderName, swfFolder:swfFolder, imageQuality:int(imageQuality_it.text), isAnimation:animation_cb.selected, frameNum:imageInfoArr.length, frameRate:int(frameRate_it.text), loop:false, imagesInfo:imagesInfo } );
			//
			Log.log("处理完成，等待Flash打包资源完毕！");
		}
		
		//==============================Cocos2d-x功能=================================
		private function loadFinishCocosdx():void
		{
			for (var imageName:String in bmdDict)
			{
				var name_arr:Array = imageName.split(".");
				var extention:String = name_arr[1];
				if (extention != "png")
				{
					continue;
				}
				var image_name_no_extention:String = name_arr[0];
				var temp_item_id:int = item_id + int(image_name_no_extention.substr(0, image_name_no_extention.length - 1)) * 100000;
				var temp_item_name:String = temp_item_id + image_name_no_extention.charAt(image_name_no_extention.length - 1);
				var bmd:BitmapData = bmdDict[imageName];
				var minRect:Rectangle = bmd.getColorBoundsRect(0xffffffff, 0x00000000, false);
				var minBmd:BitmapData = new BitmapData(minRect.width, minRect.height, true, 0);
				minBmd.copyPixels(bmd, minRect, destPoint, null, null, true);
				var url:String = swfFolder + "/" + temp_item_name + "." + extention;
				ImageCreator.createImage(url, minBmd);
				generatorJson(temp_item_name, minRect.x, minRect.y);
			}
			Log.log("处理完成！");
		}
		
		private function generatorJson(name:String, x:int, y:int):void
		{
			var url:String = swfFolder + "/" + name + ".json";
			var str:String = "[{\"x\":" + x + ",\"y\":" + y + "}]";
			var fs:FileStream = new FileStream();
			var file:File = new File(url);
			fs.open(file, FileMode.WRITE);
			fs.writeUTFBytes(str);
			fs.close();
		}
	}
}