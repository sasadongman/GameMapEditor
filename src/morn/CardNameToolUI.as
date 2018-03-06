/**Created by the Morn,do not modify.*/
package morn {
	import morn.core.components.*;
	public class CardNameToolUI extends View {
		public var target_it:TextInput = null;
		public var origin_it:TextInput = null;
		public var save_btn:Button = null;
		public var excute_btn:Button = null;
		protected static var uiView:XML =
			<View width="810" height="380">
			  <Label text="目标文件夹：" x="12" y="47"/>
			  <TextInput skin="png.comp.textinput" x="85" y="46" width="625" height="22" var="target_it" text="E:/Projects/SmhWorld/trunk/05 源代码/网页端/Main/SmhWorld/bin/assets/role"/>
			  <Label text="原始文件夹：" x="12" y="14"/>
			  <TextInput skin="png.comp.textinput" x="85" y="13" width="625" height="22" var="origin_it" text="E:/Projects/SmhWorld/trunk/12 交换目录/美术类/装扮类资源"/>
			  <Button label="保存" skin="png.comp.button" x="719" y="12" var="save_btn" width="75" height="55"/>
			  <Button label="处理" skin="png.comp.button" x="632" y="285" var="excute_btn" width="170" height="86"/>
			</View>;
		public function CardNameToolUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);
		}
	}
}