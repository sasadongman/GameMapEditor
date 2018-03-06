package modules.AvatarNameTool 
{
	import dragData.vily.DragDataManager;
	import dragData.vily.interfaces.IDragData;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import modules.IPage;
	import morn.AvatarNameToolUI;
	import utils.FlashCookie;
	import utils.FlashCookieConst;
	
	/**
	 * ...
	 * @author Alex
	 */
	public class AvatarNameTool extends AvatarNameToolUI implements IDragData, IPage
	{
		//拖拽管理器
		private var _dragDM:DragDataManager;
		public function AvatarNameTool() 
		{
			super();
			_dragDM = new DragDataManager();
			_dragDM.setTarget(this);
			_dragDM.setReceiver(this);
			
			if (FlashCookie.getValue(FlashCookieConst.AVATAR_NAME_NUM) != null)
			{
				num_it.text = "" + int(FlashCookie.getValue(FlashCookieConst.AVATAR_NAME_NUM));
			}
			else
			{
				FlashCookie.setValue(FlashCookieConst.AVATAR_NAME_NUM, int(num_it.text));
			}
			
			reset_btn.addEventListener(MouseEvent.CLICK, reset_btn_click);
		}
		
		public function transIn():void
		{
			Log.log("拖动待重命名素材所在文件夹到上面窗口");
		}
		
		public function transOut():void
		{
			
		}
		
		private function reset_btn_click(e:MouseEvent):void 
		{
			FlashCookie.setValue(FlashCookieConst.AVATAR_NAME_NUM, int(num_it.text));
			Log.log("初始数字重置:" + num_it.text);
		}
		
		private var nativePath:String;
		private var nativeFile:File;
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
				Log.log("拖入的不是文件夹！");
				return;
			}
			Log.log("开始处理文件夹:" + nativeFile.nativePath);
			iterationHandle(nativeFile);
			Log.log("处理完毕！");
			return;
			
			//Log.log("文件类型:" + extensions_it.text);
			Log.log("初始数字:" + num_it.text);
			//extensions = extensions_it.text.split(",");
			startNum = int(num_it.text);
			var files:Array = nativeFile.getDirectoryListing();
			for each (var file:File in files)
			{
				renameHandle(file);
			}
			
			Log.log("初始数字截止:" + maxNum);
			//maxNum /= 10;
			//maxNum += 2;
			//maxNum *= 10;
			//Log.log("初始数字设置:" + maxNum);
			num_it.text = "" + maxNum;
			FlashCookie.setValue(FlashCookieConst.AVATAR_NAME_NUM, maxNum);
			Log.log("处理完毕！");
		}
		
		private function iterationHandle(folder:File):void
		{
			var files:Array = folder.getDirectoryListing();
			for each (var file:File in files)
			{
				if (file.isDirectory)
				{
					iterationHandle(file);
				}
				else
				{
					if (file.extension == "png") 
					{
						renameFileNameHandle(file);
					}
				}
			}
		}
		
		private function renameFileNameHandle(file:File):void 
		{
			var fileName:String = file.name;
			var re_obj:Object = num_re.exec(fileName);
			if (re_obj == null)
			{
				return;
			}
			var start_str:String = re_obj[1];
			var num:int = int(start_str);
			var end_str:String = fileName.substr(start_str.length);
			var renameFileName:String = (num - 1) + end_str;
			var renameFile:File = file.parent.resolvePath(renameFileName);
			file.moveTo(renameFile);
		}
		
		//=====================================================================================
		private var startNum:int = 0;
		private var maxNum:int = 0;
		private var num_re:RegExp = /(\d*)/;
		private function renameHandle(file:File):void 
		{
			var fileName:String = file.name;
			var re_obj:Object = num_re.exec(fileName);
			if (re_obj == null)
			{
				return;
			}
			var start_str:String = re_obj[1];
			var num:int = int(start_str);
			var end_str:String = fileName.substr(start_str.length);
			num += startNum;
			var renameFileName:String = num + end_str;
			if (fileName != renameFileName) 
			{
				var renameFile:File = nativeFile.resolvePath(renameFileName);
				file.moveTo(renameFile);
			}
			//
			if (maxNum < num) 
			{
				maxNum = num;
			}
		}
	}
}