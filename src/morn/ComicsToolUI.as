/**Created by the Morn,do not modify.*/
package morn {
	import morn.core.components.*;
	public class ComicsToolUI extends View {
		public var left_x_it:TextInput = null;
		public var left_y_it:TextInput = null;
		public var left_w_it:TextInput = null;
		public var left_h_it:TextInput = null;
		public var right_x_it:TextInput = null;
		public var right_y_it:TextInput = null;
		public var right_w_it:TextInput = null;
		public var right_h_it:TextInput = null;
		public var limit_w_it:TextInput = null;
		public var limit_h_it:TextInput = null;
		public var quantization_it:TextInput = null;
		public var mode_cb:ComboBox = null;
		public var delete_cb:CheckBox = null;
		protected static var uiView:XML =
			<View width="810" height="380">
			  <Image skin="png.comp.blank" x="0" y="0" width="810" height="380"/>
			  <Label text="漫画裁剪工具" color="0x0" bold="true" size="14" centerX="0" top="10" x="0" y="0"/>
			  <Box x="16" y="74">
			    <Label text="起始X：" x="75"/>
			    <TextInput skin="png.comp.textinput" x="116" y="1" width="35" height="22" var="left_x_it" text="678" restrict="0-9" maxChars="4"/>
			    <Label text="左页" y="1" bold="true"/>
			    <Label text="起始Y：" x="161" y="0"/>
			    <TextInput skin="png.comp.textinput" x="202" y="1" width="35" height="22" var="left_y_it" text="184" restrict="0-9" maxChars="4"/>
			    <Label text="宽度：" x="251" y="0"/>
			    <TextInput skin="png.comp.textinput" x="285" y="1" width="35" height="22" var="left_w_it" text="2512" restrict="0-9" maxChars="4"/>
			    <Label text="高度：" x="337" y="0"/>
			    <TextInput skin="png.comp.textinput" x="369" y="1" width="35" height="22" var="left_h_it" text="4184" restrict="0-9" maxChars="4"/>
			  </Box>
			  <Box x="16" y="107">
			    <Label text="起始X：" x="75"/>
			    <TextInput skin="png.comp.textinput" x="116" y="1" width="35" height="22" var="right_x_it" text="165" restrict="0-9" maxChars="4"/>
			    <Label text="右页" y="1" bold="true"/>
			    <Label text="起始Y：" x="161" y="0"/>
			    <TextInput skin="png.comp.textinput" x="202" y="1" width="35" height="22" var="right_y_it" text="180" restrict="0-9" maxChars="4"/>
			    <Label text="宽度：" x="251" y="0"/>
			    <TextInput skin="png.comp.textinput" x="285" y="1" width="35" height="22" var="right_w_it" text="2512" restrict="0-9" maxChars="4"/>
			    <Label text="高度：" x="337" y="0"/>
			    <TextInput skin="png.comp.textinput" x="369" y="1" width="35" height="22" var="right_h_it" text="4184" restrict="0-9" maxChars="4"/>
			  </Box>
			  <Box x="16" y="139">
			    <Label text="切图限制" y="1" bold="true"/>
			    <Label text="宽度：" x="76" y="0"/>
			    <TextInput skin="png.comp.textinput" x="110" y="1" width="35" height="22" var="limit_w_it" text="0" restrict="0-9" maxChars="4"/>
			    <Label text="高度：" x="162" y="0"/>
			    <TextInput skin="png.comp.textinput" x="194" y="1" width="35" height="22" var="limit_h_it" text="0" restrict="0-9" maxChars="4"/>
			    <Label text="压缩率：" x="248" y="0"/>
			    <TextInput skin="png.comp.textinput" x="294" y="1" width="35" height="22" var="quantization_it" text="100" restrict="0-9" maxChars="4"/>
			  </Box>
			  <Box x="16" y="44">
			    <ComboBox labels="4格,6格" skin="png.comp.combobox" x="73" selectedIndex="0" width="42" height="23" var="mode_cb"/>
			    <Label text="模式" bold="true" y="1"/>
			    <CheckBox label="删除原图" skin="png.comp.checkbox" x="138" y="0" var="delete_cb" selected="true"/>
			  </Box>
			</View>;
		public function ComicsToolUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);
		}
	}
}