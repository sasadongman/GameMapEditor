package modules.MainPage 
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.filesystem.File;
	import modules.IKeyboardPage;
	import modules.IPage;
	import morn.core.components.Box;
	import morn.MainPageUI;
	import morn.core.handlers.Handler;
	import utils.FlashCookie;
	import utils.FlashCookieConst;
	
	/**
	 * ...
	 * @author Alex
	 */
	public class MainPage extends MainPageUI
	{
		public function MainPage() 
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		
		private function addedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			
			//版本号直接从文件描述里取
			var applicationDescriptor:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var adns:Namespace = applicationDescriptor.namespace();
			var ver_str:String = applicationDescriptor.adns::versionNumber.toString();
			ver_lb.text = "Ver " + ver_str;
			
			permission_cb.labels = GlobalConst.permission_arr.join(",");
			permission_cb.selectHandler = new Handler(permission_select_handle);
			permission_cb.selectedIndex = int(FlashCookie.getValue(FlashCookieConst.PERMISSION));
			
			log_btn.clickHandler = new Handler(log_show_handle);
			clear_log_btn.clickHandler = new Handler(clear_log_handle);
			if (FlashCookie.getValue(FlashCookieConst.MAIN_HIDE_LOG)) 
			{
				log_show_handle();
			}
			//
			applicationDirectory_bt.visible = false;
			applicationDirectory_bt.clickHandler = new Handler(applicationDirectoryHandle);
			applicationStorageDirectory_bt.clickHandler = new Handler(applicationStorageDirectoryHandle);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandle);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyHandle);
		}
		
		private function applicationDirectoryHandle():void
		{
			File.applicationDirectory.openWithDefaultApplication();
		}
		
		private function applicationStorageDirectoryHandle():void
		{
			File.applicationStorageDirectory.openWithDefaultApplication();
		}
		
		private function log_show_handle():void 
		{
			clear_log_btn.visible = log_ta.visible = !log_ta.visible;
			page_vs.bottom = log_ta.visible ? 210 : 10;
			log_btn.label = log_ta.visible ? "隐藏日志" : "显示日志";
			FlashCookie.setValue(FlashCookieConst.MAIN_HIDE_LOG, !log_ta.visible);
		}
		
		private function clear_log_handle():void
		{
			log_ta.text = "";
		}
		
		private function permission_select_handle(index:int):void
		{
			FlashCookie.setValue(FlashCookieConst.PERMISSION, index);
			GlobalConst.permission = index;
			//if (GlobalConst.permission == GlobalConst.PERMISSION_WHOLE) 
			//{
				//page_tab.labels = GlobalConst.TAB_NAMES.join(",");
			//}
			//else
			//{
				var labels:Array = [];
				for each (var index:int in GlobalConst.TAB_LIST[GlobalConst.permission])
				{
					labels.push(GlobalConst.TAB_NAMES[index]);
				}
				page_tab.labels = labels.join(",");
			//}
			//page_tab.selectHandler = page_vs.setIndexHandler;
			page_tab.addEventListener(Event.SELECT, page_tab_select);
			page_tab.selectedIndex = int(FlashCookie.getValue(FlashCookieConst.MAIN_SELECT_INDEX));
		}
		
		private var _lastPage:Box;
		private function page_tab_select(e:Event = null):void 
		{
			Log.clear();
			Log.log("================================================================================================================");
			if (_lastPage && (_lastPage is IPage)) 
			{
				(_lastPage as IPage).transOut();
			}
			FlashCookie.setValue(FlashCookieConst.MAIN_SELECT_INDEX, page_tab.selectedIndex);
			//var vs_index:int = GlobalConst.permission == GlobalConst.PERMISSION_WHOLE ? page_tab.selectedIndex : GlobalConst.TAB_LIST[GlobalConst.permission][page_tab.selectedIndex];
			var vs_index:int = GlobalConst.TAB_LIST[GlobalConst.permission][page_tab.selectedIndex];
			page_vs.selectedIndex = vs_index;
			_lastPage = page_vs.getChildByName("item" + vs_index) as Box;
			if (_lastPage is IPage) 
			{
				(_lastPage as IPage).transIn();
			}
		}
		
		private function keyHandle(e:KeyboardEvent):void
		{
			if (App.dialog.numChildren > 1) 
			{
				return;
			}
			if (_lastPage is IKeyboardPage) 
			{
				(_lastPage as IKeyboardPage).keyHandle(e);
			}
		}
	}
}