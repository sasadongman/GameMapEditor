/**Created by the Morn,do not modify.*/
package morn.common {
	import morn.core.components.*;
	public class PromptUI extends Dialog {
		public var content_lb:Label = null;
		protected static var uiView:XML =
			<Dialog width="900" height="50">
			  <Image skin="png.comp.blank" left="0" right="0" top="0" bottom="0"/>
			  <Label text="提示文字！" x="0" y="5" align="center" bold="true" stroke="0x0" color="0xffffff" width="900" size="32" height="40" var="content_lb"/>
			</Dialog>;
		public function PromptUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);
		}
	}
}