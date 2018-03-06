/**Created by the Morn,do not modify.*/
package morn {
	import morn.core.components.*;
	public class ImageCompressUI extends View {
		public var ratio_ti:TextInput = null;
		protected static var uiView:XML =
			<View width="810" height="380">
			  <Image skin="jpg.comp.灰色" x="0" y="0" width="810" height="380"/>
			  <TextInput text="80" skin="png.comp.textinput" x="737" y="16" var="ratio_ti" width="57" height="22"/>
			  <Label text="压缩率" x="694" y="17" color="0xffffff"/>
			  <Label text="将图片（jpg或png）或者图片文件夹拖入此区域" x="194" y="176.5" size="20" color="0xcccccc"/>
			</View>;
		public function ImageCompressUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);
		}
	}
}