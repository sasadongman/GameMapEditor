package modules.EnumTool 
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import morn.core.components.ComboBox;
	import morn.EnumToolUI;
	import utils.FlashCookie;
	import utils.FlashCookieConst;
	
	/**
	 * ...
	 * @author Alex
	 */
	public class EnumTool extends EnumToolUI 
	{
		private var _selectIndex:Number;
		
		public function EnumTool() 
		{
			super();
			LoadConfig.getInstatnce().loadXML();
			myEventDispatcher.getInstance().addEventListener(AllEvent.LOAD_COMPLETE,onSetData);
		}
		
		private function onSetData(e:AllEvent):void 
		{
			var public_folder:String = FlashCookie.getValue(FlashCookieConst.ENUM_PUBLIC_FOLDER);
			if (public_folder)
			{
				this.public_ti.text = public_folder;
			}
			var socket_folder:String = FlashCookie.getValue(FlashCookieConst.ENUM_SOCKET_FOLDER);
			if (socket_folder)
			{
				this.socket_ti.text = socket_folder;
			}
			this.record_btn.addEventListener(MouseEvent.MOUSE_UP, record_btn_mouseUp);
			
			//Log.log("开始设置");
			this.selectList.labels = AppConfig.fileName.join(",");
			this.selectList.selectedIndex = 0;
			_selectIndex = this.selectList.selectedIndex;
			this.selectList.addEventListener(Event.CHANGE,onChange);
			this.sure_btn.addEventListener(MouseEvent.MOUSE_UP,onSure);

			showFileNameList();
		}
		
		private function showFileNameList():void 
		{
			this.fileName_lb.text = "";
			for (var i:int = 0; i < AppConfig.fileName.length; i++) 
			{
				this.fileName_lb.text += AppConfig.fileName[i] + "\n";
			}
		}
		
		private function record_btn_mouseUp(e:MouseEvent):void 
		{
			FlashCookie.setValue(FlashCookieConst.ENUM_PUBLIC_FOLDER, public_ti.text);
			FlashCookie.setValue(FlashCookieConst.ENUM_SOCKET_FOLDER, socket_ti.text);
		}
		
		protected function onSure(event:MouseEvent):void
		{
			if (as3_socket_cb.selected) 
			{
				parseFile(this.socket_ti.text);
			}
			
			if (laya_socket_cb.selected) 
			{
				parseFile(this.laya_socket_ti.text);
			}
			
		}
		
		protected function onChange(event:Event):void
		{
			_selectIndex = (event.currentTarget as ComboBox).selectedIndex;
		}
		
		/**
		 * 解析文件
		 */
		private function parseFile(save_url:String):void 
		{
			////Log.log("sure");
			////AppConfig.packageName = getPackageName(AppConfig.packageURL[_selectIndex]);
			//AppConfig.packageName = AppConfig.packageURL[_selectIndex];
			////AppConfig.SAVE_URL = AppConfig.saveURL[_selectIndex];
			//AppConfig.SAVE_URL = this.socket_ti.text + AppConfig.saveURL[_selectIndex];
			////Log.log("AppConfig.packageName:"+AppConfig.packageName);
			//if (AppConfig.saveURL[_selectIndex] != "")
			//{
				////删除旧的文件
				//var folder_file:File = new File(AppConfig.SAVE_URL);
				//folder_file.deleteDirectory(true);
			//}
			////_fileUrl = AppConfig.ROOT_URL + AppConfig.fileURL[_selectIndex];
			//_fileUrl = this.public_ti.text + "\\" + AppConfig.fileURL[_selectIndex];
			//Analysis.getInstance().loadH(_fileUrl);
			//
			for (var i:int = 0; i < AppConfig.fileURL.length; i++) 
			{
				AppConfig.packageName = AppConfig.packageURL[i];
				AppConfig.SAVE_URL = save_url + AppConfig.saveURL[i];
				if (AppConfig.saveURL[i] != "")
				{
					//删除旧的文件
					var folder_file:File = new File(AppConfig.SAVE_URL);
					folder_file.deleteDirectory(true);
				}
				
				var _fileUrl:String = this.public_ti.text + "\\" + AppConfig.fileURL[i];
				Analysis.getInstance().execute(_fileUrl);
			}
		}
	}

}