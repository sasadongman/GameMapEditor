/**Created by the Morn,do not modify.*/
package morn {
	import morn.core.components.*;
	public class CutToolUI extends View {
		protected static var uiView:XML =
			<View width="810" height="380">
			  <Image skin="png.comp.blank" x="0" y="0" width="810" height="380"/>
			  <Label text="png裁剪工具" color="0x0" bold="true" size="14" centerX="0" top="10"/>
			</View>;
		public function CutToolUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);
		}
	}
}