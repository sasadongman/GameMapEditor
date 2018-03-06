/**Created by the Morn,do not modify.*/
package morn.mapEditor {
	import morn.core.components.*;
	public class MapEditorNewUI extends Dialog {
		public var width_ti:TextInput = null;
		public var height_ti:TextInput = null;
		public var tileWidth_ti:TextInput = null;
		public var tileHeight_ti:TextInput = null;
		public var total_lb:Label = null;
		public var ok_btn:Button = null;
		public var name_lb:Label = null;
		public var cross_cb:CheckBox = null;
		protected static var uiView:XML =
			<Dialog width="400" height="200">
			  <Image skin="png.comp.bg" left="0" right="0" top="0" bottom="0" sizeGrid="5,30,5,5"/>
			  <Label text="地图大小" x="19" y="44" bold="true"/>
			  <Label text="块大小" x="209" y="44" bold="true"/>
			  <Label text="宽度：" x="19" y="75"/>
			  <Label text="高度：" x="19" y="104"/>
			  <Label text="宽度：" x="209" y="73"/>
			  <Label text="高度：" x="209" y="102"/>
			  <TextInput text="20" skin="png.comp.textinput" x="59" y="75" restrict="0-9" var="width_ti"/>
			  <TextInput text="20" skin="png.comp.textinput" x="59" y="105" restrict="0-9" var="height_ti"/>
			  <TextInput text="88" skin="png.comp.textinput" x="249" y="74" restrict="0-9" var="tileWidth_ti"/>
			  <TextInput text="44" skin="png.comp.textinput" x="249" y="104" restrict="0-9" var="tileHeight_ti"/>
			  <Label text="1800 x 900 像素点" x="20" y="137" var="total_lb"/>
			  <Button label="确定" skin="png.comp.button" x="160" y="161" name="ok" var="ok_btn"/>
			  <Button skin="png.comp.btn_close" x="369" y="3" name="close"/>
			  <Label text="新地图" x="9" y="4" bold="true" var="name_lb"/>
			  <CheckBox label="交错" skin="png.comp.checkbox" x="334" y="137" var="cross_cb"/>
			</Dialog>;
		public function MapEditorNewUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);
		}
	}
}