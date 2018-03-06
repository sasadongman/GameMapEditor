/**Created by the Morn,do not modify.*/
package morn {
	import morn.core.components.*;
	public class ImageAddSpaceUI extends View {
		public var target_im:Image = null;
		public var handle_btn:Button = null;
		public var clear_btn:Button = null;
		protected static var uiView:XML =
			<View width="810" height="380" left="0" right="0" top="0" bottom="0">
			  <Image skin="jpg.comp.灰色" x="106" y="515" left="0" right="0" top="0" bottom="0"/>
			  <Image x="0" y="0" var="target_im"/>
			  <Button label="处理图片" skin="png.comp.button" width="129" height="46" var="handle_btn" right="5" bottom="200"/>
			  <Button label="清除图片" skin="png.comp.button" width="129" height="46" var="clear_btn" right="5" bottom="260"/>
			</View>;
		public function ImageAddSpaceUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);
		}
	}
}