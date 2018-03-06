/**Created by the Morn,do not modify.*/
package morn {
	import morn.core.components.*;
	public class CardBatchToolUI extends View {
		public var resource_it:TextInput = null;
		public var output_it:TextInput = null;
		public var excute_btn:Button = null;
		protected static var uiView:XML =
			<View width="810" height="380">
			  <Label text="资源文件夹：" x="12" y="11" color="0x0"/>
			  <TextInput skin="png.comp.textinput" x="85" y="12" width="625" height="22" var="resource_it" text="E:/Projects/SmhWorld/trunk/05 源代码/网页端/Main/SmhWorld/bin/assets/card/big"/>
			  <Label text="输出文件夹：" x="12" y="45" color="0x0"/>
			  <TextInput skin="png.comp.textinput" x="85" y="46" width="625" height="22" var="output_it"/>
			  <Button label="处理" skin="png.comp.button" x="724" y="312" var="excute_btn" width="75" height="56"/>
			</View>;
		public function CardBatchToolUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);
		}
	}
}