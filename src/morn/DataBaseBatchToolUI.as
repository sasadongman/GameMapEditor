/**Created by the Morn,do not modify.*/
package morn {
	import morn.core.components.*;
	public class DataBaseBatchToolUI extends View {
		public var flash_txt_ti:TextInput = null;
		public var excute_btn:Button = null;
		public var check_folder_ti:TextInput = null;
		public var record_btn:Button = null;
		public var serverList_ti:TextInput = null;
		protected static var uiView:XML =
			<View width="810" height="380">
			  <Label text="txt文件夹(Flash)：" x="16" y="79"/>
			  <TextInput skin="png.comp.textinput" x="110" y="78" width="675" height="22" var="flash_txt_ti" text="E:/Publish/发布工程/bin/assets/staticConfig"/>
			  <Button label="处理" skin="png.comp.button" x="642" y="273" var="excute_btn" width="157" height="95"/>
			  <Label text="比对as文件夹：" x="16" y="51"/>
			  <TextInput skin="png.comp.textinput" x="110" y="50" width="675" height="22" var="check_folder_ti" text="E:/Publish/发布工程/src/smh/model/resource/staticConfig/txt"/>
			  <Button label="保存" skin="png.comp.button" x="708" y="10" var="record_btn" width="89" height="31"/>
			  <Label text="服务器列表：" x="16" y="16"/>
			  <TextInput skin="png.comp.textinput" x="95" y="14" width="595" height="22" var="serverList_ti" text="http://192.168.0.161:52000/fmy-game-service/config/server/list"/>
			</View>;
		public function DataBaseBatchToolUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);
		}
	}
}