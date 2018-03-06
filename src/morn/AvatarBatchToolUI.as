/**Created by the Morn,do not modify.*/
package morn {
	import morn.core.components.*;
	public class AvatarBatchToolUI extends View {
		public var target_it:TextInput = null;
		public var imageQuality_it:TextInput = null;
		public var cocos2dx_cb:CheckBox = null;
		public var origin_it:TextInput = null;
		public var save_btn:Button = null;
		public var excute_btn:Button = null;
		public var total_cb:CheckBox = null;
		public var reset_btn:Button = null;
		protected static var uiView:XML =
			<View width="810" height="380">
			  <Label text="目标文件夹：" x="12" y="47"/>
			  <TextInput skin="png.comp.textinput" x="85" y="46" width="625" height="22" var="target_it" text="E:/Projects/SmhWorld/trunk/05 源代码/网页端/Main/SmhWorld/bin/assets/role"/>
			  <Label text="图像压缩率：" x="13" y="79"/>
			  <TextInput text="80" skin="png.comp.textinput" x="85" y="78" var="imageQuality_it" restrict="0-9" width="28" height="22"/>
			  <CheckBox label="Cocos2d-x" skin="png.comp.checkbox" x="14" y="112" var="cocos2dx_cb"/>
			  <Label text="原始文件夹：" x="12" y="14"/>
			  <TextInput skin="png.comp.textinput" x="85" y="13" width="625" height="22" var="origin_it" text="E:/Projects/SmhWorld/trunk/12 交换目录/美术类/装扮类资源"/>
			  <Button label="保存" skin="png.comp.button" x="719" y="12" var="save_btn" width="75" height="55"/>
			  <Button label="处理" skin="png.comp.button" x="632" y="285" var="excute_btn" width="170" height="86"/>
			  <CheckBox label="处理全部" skin="png.comp.checkbox" x="734" y="259" var="total_cb"/>
			  <Button label="重置版本" skin="png.comp.button" x="723" y="222" var="reset_btn"/>
			</View>;
		public function AvatarBatchToolUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);
		}
	}
}