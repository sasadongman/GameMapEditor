package utils 
{
	import com.greensock.TweenLite;
	import modules.common.*;
	import morn.core.handlers.Handler;
	/**
	 * ...
	 * @author Alex
	 */
	public class MessageUtil 
	{
		private static var _promptView:Prompt;
		static private function get promptView():Prompt 
		{
			if (_promptView == null) 
			{
				_promptView = new Prompt();
			}
			return _promptView;
		}
		
		private static var _alertView:Alert;
		static private function get alertView():Alert 
		{
			if (_alertView == null) 
			{
				_alertView = new Alert();
			}
			return _alertView;
		}
		
		private static var _dialogView:Dialog;
		static private function get dialogView():Dialog 
		{
			if (_dialogView == null) 
			{
				_dialogView = new Dialog();
			}
			return _dialogView;
		}
		
		public function MessageUtil() 
		{
		}
		
		/**
		 * 提示信息
		 * @param	content
		 * @param	handler
		 */
		public static function prompt(content:String):void
		{
			promptView.content_lb.text = content;
			App.dialog.show(promptView);
			TweenLite.killTweensOf(promptView);
			TweenLite.fromTo(promptView, 1, { alpha: 1 }, { alpha: 0, delay: 1, onComplete:promptHandle } );
		}
		private static function promptHandle():void
		{
			App.dialog.close(promptView);
		}
		
		/**
		 * 提示框
		 * @param	content
		 * @param	handler
		 */
		public static function alert(content:String, handler:Handler=null):void
		{
			alertView.content_lb.text = content;
			App.dialog.popup(alertView);
			if (handler == null) 
			{
				return;
			}
			alertView.ok_btn.clickHandler = handler;
			alertView.close_btn.clickHandler = handler;
		}
		
		/**
		 * 对话框
		 * @param	content
		 * @param	handler
		 */
		public static function dialog(content:String, handler:Handler=null):void
		{
			dialogView.content_lb.text = content;
			App.dialog.popup(dialogView);
			if (handler == null) 
			{
				return;
			}
			dialogView.ok_btn.clickHandler = new Handler(dialogHandle, [handler, true]);
			dialogView.close_btn.clickHandler = dialogView.cancel_btn.clickHandler = new Handler(dialogHandle, [handler, false]);
			function dialogHandle(handler:Handler, value:Boolean):void
			{
				handler.executeWith([value]);
			}
		}
	}

}