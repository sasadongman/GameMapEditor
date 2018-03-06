/**Created by the Morn,do not modify.*/
package morn {
	import morn.core.components.*;
	public class VersionToolUI extends View {
		public var unite_dat_btn:Button = null;
		public var excute_btn:Button = null;
		public var config_btn:Button = null;
		public var open_origin_btn:Button = null;
		public var open_target_btn:Button = null;
		public var _dateFilter_year_txt:TextInput = null;
		public var _dateFilter_month_txt:TextInput = null;
		public var _dateFilter_day_txt:TextInput = null;
		public var _dateFilter_hour_txt:TextInput = null;
		public var _dateFilter_minute_txt:TextInput = null;
		public var dateFilter_cb:CheckBox = null;
		public var whole_cb:CheckBox = null;
		public var copy_cb:CheckBox = null;
		public var version_xml_cb:CheckBox = null;
		public var clear_old_cb:CheckBox = null;
		public var item_cb:ComboBox = null;
		public var origin_ti:TextInput = null;
		public var target_ti:TextInput = null;
		protected static var uiView:XML =
			<View width="810" height="380">
			  <Label text="原始路径：" x="12" y="44"/>
			  <Label text="目标路径：" x="12" y="74"/>
			  <Button label="打包unite.dat" skin="png.comp.button" x="12" y="162" var="unite_dat_btn"/>
			  <Button label="处理更新" skin="png.comp.button" x="633" y="285" var="excute_btn" width="170" height="88"/>
			  <Button label="修改安装路径下的xml/avatar_config.xml改变下拉列表选项" skin="png.comp.button" x="12" y="103" var="config_btn" width="321" height="23" disabled="true"/>
			  <Button label="打开" skin="png.comp.button" x="720" y="43" var="open_origin_btn"/>
			  <Button label="打开" skin="png.comp.button" x="720" y="74" var="open_target_btn"/>
			  <Box x="5" y="351" visible="false">
			    <Label text="更新起始日期："/>
			    <TextInput text="2015" skin="png.comp.textinput" x="89" y="1" width="35" height="22" var="_dateFilter_year_txt" restrict="0-9"/>
			    <TextInput text="12" skin="png.comp.textinput" x="128" y="1" width="21" height="22" var="_dateFilter_month_txt" restrict="0-9"/>
			    <TextInput text="30" skin="png.comp.textinput" x="153" y="1" width="21" height="22" var="_dateFilter_day_txt" restrict="0-9"/>
			    <Label text="时间：" x="184"/>
			    <TextInput text="0" skin="png.comp.textinput" x="220" width="21" height="22" var="_dateFilter_hour_txt" restrict="0-9"/>
			    <TextInput text="0" skin="png.comp.textinput" x="246" width="21" height="22" var="_dateFilter_minute_txt" restrict="0-9"/>
			    <CheckBox label="强制时间过滤" skin="png.comp.checkbox" x="278" y="2" var="dateFilter_cb"/>
			  </Box>
			  <Box x="12" y="137">
			    <CheckBox label="提取所有" skin="png.comp.checkbox" x="296" var="whole_cb"/>
			    <CheckBox label="复制文件" skin="png.comp.checkbox" var="copy_cb" selected="true"/>
			    <CheckBox label="生成version.xml" skin="png.comp.checkbox" x="83" var="version_xml_cb"/>
			    <CheckBox label="删除旧文件" skin="png.comp.checkbox" x="204" var="clear_old_cb"/>
			  </Box>
			  <Label text="更新项目：" x="12" y="11"/>
			  <ComboBox labels="label1,label2" skin="png.comp.combobox" x="74" y="10" width="300" height="23" sizeGrid="5,5,18,5" var="item_cb"/>
			  <TextInput skin="png.comp.textinput" x="74" y="44" width="639" height="22" var="origin_ti" editable="false"/>
			  <TextInput skin="png.comp.textinput" x="74" y="75" width="639" height="22" var="target_ti" editable="false"/>
			</View>;
		public function VersionToolUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);
		}
	}
}