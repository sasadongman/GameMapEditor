/**Created by the Morn,do not modify.*/
package morn.common {
	import morn.core.components.*;
	public class AlertUI extends Dialog {
		public var close_btn:Button = null;
		public var ok_btn:Button = null;
		public var content_lb:Label = null;
		protected static var uiView:XML =
			<Dialog width="400" height="300">
			  <Image skin="png.comp.bg" top="0" bottom="0" right="0" left="0" x="0" y="0" sizeGrid="5,30,5,5"/>
			  <Button skin="png.comp.btn_close" x="367" y="3" name="close" var="close_btn"/>
			  <Button label="确定" skin="png.comp.button" x="168" y="258" name="ok" var="ok_btn"/>
			  <Label text="label" x="43" y="51" width="320" height="183" multiline="true" wordWrap="true" var="content_lb" size="20"/>
			</Dialog>;
		public function AlertUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);
		}
	}
}