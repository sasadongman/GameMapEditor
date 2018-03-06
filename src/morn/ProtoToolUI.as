/**Created by the Morn,do not modify.*/
package morn {
	import morn.core.components.*;
	public class ProtoToolUI extends View {
		public var server_it:TextInput = null;
		public var record_btn:Button = null;
		public var as3_it:TextInput = null;
		public var cmd_btn:Button = null;
		public var as_btn:Button = null;
		public var excute_btn:Button = null;
		public var laya_it:TextInput = null;
		public var laya_socket_cb:CheckBox = null;
		public var as3_socket_cb:CheckBox = null;
		protected static var uiView:XML =
			<View width="810" height="380">
			  <Label text="服务端propto文件夹：" x="12" y="11"/>
			  <Label text="Flash proto文件夹：" x="13" y="39"/>
			  <TextInput skin="png.comp.textinput" x="134" y="10" width="560" height="22" var="server_it" text="E:/Projects/SmhWorld/trunk/05 源代码/ServerPublic/proto"/>
			  <Button label="保存" skin="png.comp.button" x="723" y="9" width="75" height="77" var="record_btn"/>
			  <TextInput skin="png.comp.textinput" x="134" y="39" width="560" height="22" text="E:/Projects/SmhWorld/trunk/05 源代码/网页端/Main/SmhWorld/src_proto" var="as3_it"/>
			  <Button label="生成_gen_as3.cmd" skin="png.comp.button" x="16" y="278" var="cmd_btn" width="123" height="88"/>
			  <Button label="转移.as" skin="png.comp.button" x="152" y="278" var="as_btn" width="129" height="88"/>
			  <Button label="处理" skin="png.comp.button" x="628" y="279" var="excute_btn" width="170" height="88"/>
			  <Label text="Laya proto文件夹：" x="13" y="67"/>
			  <TextInput skin="png.comp.textinput" x="134" y="67" width="560" height="22" text="E:/Projects/SmhWorld/trunk/05 源代码/网页端/Main/LayaAirProject/src_proto" var="laya_it"/>
			  <CheckBox skin="png.comp.checkbox" x="698" y="71" var="laya_socket_cb"/>
			  <CheckBox skin="png.comp.checkbox" x="698" y="42" var="as3_socket_cb" selected="true"/>
			</View>;
		public function ProtoToolUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);
		}
	}
}