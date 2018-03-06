/**Created by the Morn,do not modify.*/
package morn {
	import morn.core.components.*;
	public class AvatarToolUI extends View {
		public var swfFolder_it:TextInput = null;
		public var record_btn:Button = null;
		public var animation_cb:CheckBox = null;
		public var frameRate_it:TextInput = null;
		public var imageQuality_it:TextInput = null;
		public var cocos2dx_cb:CheckBox = null;
		protected static var uiView:XML =
			<View width="810" height="380">
			  <Image skin="png.comp.blank" x="0" y="0" width="810" height="380"/>
			  <Label text="目标文件夹：" x="12" y="11"/>
			  <TextInput skin="png.comp.textinput" x="85" y="10" width="625" height="22" var="swfFolder_it" text="E:/Projects/SmhWorld/trunk/05 源代码/网页端/Main/SmhWorld/bin/assets/role"/>
			  <Button label="保存" skin="png.comp.button" x="719" y="9" var="record_btn"/>
			  <CheckBox label="是否动画" skin="png.comp.checkbox" x="14" y="51" var="animation_cb"/>
			  <Label text="动画帧频：" x="99" y="48"/>
			  <TextInput text="0" skin="png.comp.textinput" x="160" y="47" var="frameRate_it" restrict="0-9" width="36" height="22"/>
			  <Label text="图像压缩率：" x="212" y="48"/>
			  <TextInput text="80" skin="png.comp.textinput" x="284" y="47" var="imageQuality_it" restrict="0-9" width="32" height="22"/>
			  <CheckBox label="Cocos2d-x" skin="png.comp.checkbox" x="14" y="352" var="cocos2dx_cb"/>
			</View>;
		public function AvatarToolUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);
		}
	}
}