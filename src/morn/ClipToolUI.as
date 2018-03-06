/**Created by the Morn,do not modify.*/
package morn {
	import morn.core.components.*;
	public class ClipToolUI extends View {
		public var vertical_cb:CheckBox = null;
		public var limit_ti:TextInput = null;
		public var clipX_ti:TextInput = null;
		public var clipY_ti:TextInput = null;
		public var align_rg:RadioGroup = null;
		protected static var uiView:XML =
			<View width="810" height="380">
			  <Image skin="png.comp.blank" x="0" y="0" width="810" height="380"/>
			  <CheckBox label="是否竖排" skin="png.comp.checkbox" x="181" y="18" var="vertical_cb"/>
			  <Label text="单排限制：" x="74" y="15"/>
			  <TextInput skin="png.comp.textinput" x="131" y="16" restrict="0-9" var="limit_ti" width="37" height="20" toolTip="不填或0表示不限制"/>
			  <Label text="合图模式：" x="10" y="15" color="0x0" bold="true"/>
			  <Label text="切图模式：" x="568" y="14" color="0x0" bold="true"/>
			  <Label text="clipX：" x="633" y="15"/>
			  <TextInput skin="png.comp.textinput" x="668" y="15" restrict="0-9" var="clipX_ti" width="37" height="20" toolTip="不填或0表示不限制" text="1"/>
			  <Label text="clipY：" x="718" y="15" width="42" height="19"/>
			  <TextInput skin="png.comp.textinput" x="753" y="15" restrict="0-9" var="clipY_ti" width="37" height="20" toolTip="不填或0表示不限制" text="1"/>
			  <RadioGroup x="136" y="46" var="align_rg">
			    <RadioButton skin="png.comp.radio" x="0" name="item0"/>
			    <RadioButton skin="png.comp.radio" x="30" name="item1"/>
			    <RadioButton skin="png.comp.radio" x="60" y="0" name="item2"/>
			    <RadioButton skin="png.comp.radio" y="30" name="item3" x="0"/>
			    <RadioButton skin="png.comp.radio" x="30" y="30" name="item4"/>
			    <RadioButton skin="png.comp.radio" x="60" y="30" name="item5"/>
			    <RadioButton skin="png.comp.radio" x="0" y="60" name="item6"/>
			    <RadioButton skin="png.comp.radio" x="30" y="60" name="item7"/>
			    <RadioButton skin="png.comp.radio" x="60" y="60" name="item8"/>
			  </RadioGroup>
			  <Label text="对齐方式：" x="76" y="43"/>
			</View>;
		public function ClipToolUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);
		}
	}
}