/**Created by the Morn,do not modify.*/
package morn {
	import morn.core.components.*;
	public class AvatarNameToolUI extends View {
		public var num_it:TextInput = null;
		public var reset_btn:Button = null;
		protected static var uiView:XML =
			<View width="810" height="380">
			  <Image skin="png.comp.blank" x="0" y="0" width="810" height="380"/>
			  <Label text="初始数字：" x="13" y="14"/>
			  <TextInput skin="png.comp.textinput" x="74" y="13" var="num_it" width="643" height="22" text="0" restrict="0-9"/>
			  <Button label="重置" skin="png.comp.button" x="725" y="12" var="reset_btn"/>
			</View>;
		public function AvatarNameToolUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);
		}
	}
}