/**Created by the Morn,do not modify.*/
package morn {
	import morn.core.components.*;
	public class DataBaseToolUI extends View {
		public var host_ti:TextInput = null;
		public var flash_txt_ti:TextInput = null;
		public var port_ti:TextInput = null;
		public var username_ti:TextInput = null;
		public var password_ti:TextInput = null;
		public var database_ti:TextInput = null;
		public var laya_txt_ti:TextInput = null;
		public var laya_txt_cb:CheckBox = null;
		public var excute_btn:Button = null;
		public var as3_txt_cb:CheckBox = null;
		public var check_folder_ti:TextInput = null;
		protected static var uiView:XML =
			<View width="810" height="380">
			  <Label text="HOST：" x="16" y="16"/>
			  <Label text="txt文件夹(Flash)：" x="16" y="178"/>
			  <TextInput skin="png.comp.textinput" x="90" y="15" width="172" height="22" var="host_ti" text="192.168.0.231" restrict=".0-9"/>
			  <TextInput skin="png.comp.textinput" x="110" y="177" width="675" height="22" var="flash_txt_ti" text="E:/Publish/发布工程/bin/assets/staticConfig"/>
			  <Label text="PORT：" x="16" y="42"/>
			  <TextInput skin="png.comp.textinput" x="90" y="41" width="172" height="22" var="port_ti" text="3306" restrict="0-9"/>
			  <Label text="账号：" x="16" y="94"/>
			  <TextInput skin="png.comp.textinput" x="90" y="93" width="172" height="22" var="username_ti" text="guest"/>
			  <Label text="密码：" x="16" y="120"/>
			  <TextInput skin="png.comp.textinput" x="90" y="119" width="172" height="22" var="password_ti" text="123456"/>
			  <Label text="database：" x="16" y="68"/>
			  <TextInput skin="png.comp.textinput" x="90" y="67" width="172" height="22" var="database_ti" text="smh_type_yf"/>
			  <Label text="txt文件夹(Laya)：" x="16" y="203"/>
			  <TextInput skin="png.comp.textinput" x="110" y="202" width="675" height="22" var="laya_txt_ti" text="E:/Projects/SmhWorld/trunk/05 源代码/网页端/Main/LayaAirProject/bin/h5/staticConfig"/>
			  <CheckBox skin="png.comp.checkbox" x="790" y="205" var="laya_txt_cb"/>
			  <Button label="处理" skin="png.comp.button" x="642" y="273" var="excute_btn" width="157" height="95"/>
			  <CheckBox skin="png.comp.checkbox" x="790" y="181" var="as3_txt_cb" selected="true"/>
			  <Label text="比对as文件夹：" x="16" y="150"/>
			  <TextInput skin="png.comp.textinput" x="110" y="149" width="675" height="22" var="check_folder_ti" text="E:/Publish/发布工程/src/smh/model/resource/staticConfig/txt"/>
			</View>;
		public function DataBaseToolUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);
		}
	}
}