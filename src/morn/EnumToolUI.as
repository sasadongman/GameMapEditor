/**Created by the Morn,do not modify.*/
package morn {
	import morn.core.components.*;
	public class EnumToolUI extends View {
		public var selectList:ComboBox = null;
		public var public_ti:TextInput = null;
		public var socket_ti:TextInput = null;
		public var record_btn:Button = null;
		public var sure_btn:Button = null;
		public var laya_socket_ti:TextInput = null;
		public var laya_socket_cb:CheckBox = null;
		public var as3_socket_cb:CheckBox = null;
		public var fileName_lb:TextArea = null;
		protected static var uiView:XML =
			<View width="810" height="380">
			  <ComboBox labels="label1,label2" skin="png.comp.combobox" x="-1" y="408" sizeGrid="5,5,20,5" width="206" height="23" var="selectList" scrollBarSkin="png.comp.vscroll" visibleNum="5" visible="false"/>
			  <Label text="转换的文件列表：" x="15" y="108" font="Microsoft YaHei"/>
			  <Label text="public文件夹：" x="16" y="16"/>
			  <Label text="socket文件夹(Flash)：" x="16" y="46"/>
			  <TextInput skin="png.comp.textinput" x="139" y="14" width="550" height="22" var="public_ti" text="E:/Projects/SmhWorld/trunk/05 源代码/ServerPublic"/>
			  <TextInput skin="png.comp.textinput" x="139" y="45" width="550" height="22" var="socket_ti" text="E:/Projects/SmhWorld/trunk/05 源代码/网页端/Main/SmhWorld/src/smh/service/socket"/>
			  <Button label="保存" skin="png.comp.button" x="722" y="13" var="record_btn" width="75" height="86"/>
			  <Button label="处理" skin="png.comp.button" x="675" y="287" var="sure_btn" width="120" height="82"/>
			  <Label text="socket文件夹(Laya)：" x="16" y="77"/>
			  <TextInput skin="png.comp.textinput" x="139" y="76" width="550" height="22" var="laya_socket_ti" text="E:/Projects/SmhWorld/trunk/05 源代码/网页端/Main/LayaAirProject/src/smh/service/socket"/>
			  <CheckBox skin="png.comp.checkbox" x="694" y="79" var="laya_socket_cb"/>
			  <CheckBox skin="png.comp.checkbox" x="694" y="49" var="as3_socket_cb" selected="true"/>
			  <TextArea skin="png.comp.textarea" x="138" y="109" width="214" height="237" var="fileName_lb"/>
			</View>;
		public function EnumToolUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);
		}
	}
}