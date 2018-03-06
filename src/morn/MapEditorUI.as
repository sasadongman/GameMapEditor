/**Created by the Morn,do not modify.*/
package morn {
	import morn.core.components.*;
	public class MapEditorUI extends View {
		public var layer_box:Box = null;
		public var interactive_im:Image = null;
		public var px_lb:TextInput = null;
		public var py_lb:TextInput = null;
		public var tx_lb:TextInput = null;
		public var ty_lb:TextInput = null;
		public var cut_width_lb:TextInput = null;
		public var cut_height_lb:TextInput = null;
		public var res_btn:Button = null;
		public var res_lb:TextInput = null;
		public var mapConf_btn:Button = null;
		public var mapConf_lb:TextInput = null;
		public var publish_res_btn:Button = null;
		public var publish_lb:TextInput = null;
		public var publish_btn:Button = null;
		public var tree:Tree = null;
		public var res_list:List = null;
		public var preview_box:Box = null;
		public var preview_line_box:Box = null;
		public var preview_im:Image = null;
		public var preview_tile_im:Image = null;
		public var pos_x_lb:TextInput = null;
		public var pos_y_lb:TextInput = null;
		public var pos_btn:Button = null;
		public var pos_layer_cb:ComboBox = null;
		public var new_btn:Button = null;
		public var save_btn:Button = null;
		public var up_cb:CheckBox = null;
		public var grid_cb:CheckBox = null;
		public var point_cb:CheckBox = null;
		public var open_btn:Button = null;
		public var ground_cb:CheckBox = null;
		public var down_cb:CheckBox = null;
		public var layer_type_tab:Tab = null;
		public var clear_btn:Button = null;
		public var fill_btn:Button = null;
		public var modify_btn:Button = null;
		public var undo_btn:Button = null;
		public var redo_btn:Button = null;
		public var cut_btn:Button = null;
		protected static var uiView:XML =
			<View width="1000" height="600" left="0" right="0" top="0" bottom="0">
			  <Box var="layer_box" y="40" x="416"/>
			  <Image skin="png.comp.纯色_透明" left="416" right="0" top="0" bottom="0" var="interactive_im"/>
			  <Box bottom="0" left="416" right="0" height="25">
			    <Image skin="jpg.comp.纯色_黑" right="0" left="0" bottom="0" top="0"/>
			    <Label text="坐标：" y="1" stroke="0x0" color="0xffffff" x="4"/>
			    <TextInput text="0" skin="png.comp.textinput" x="39" y="1" var="px_lb" restrict="-0123456789" width="35" height="22" editable="false"/>
			    <TextInput text="0" skin="png.comp.textinput" x="76" y="1" var="py_lb" restrict="-0123456789" width="35" height="22" editable="false"/>
			    <Label text="位置：" y="1" stroke="0x0" color="0xffffff" x="126"/>
			    <TextInput text="0" skin="png.comp.textinput" x="161" y="1" var="tx_lb" restrict="-0123456789" width="35" height="22" editable="false"/>
			    <TextInput text="0" skin="png.comp.textinput" x="198" y="1" var="ty_lb" restrict="-0123456789" width="35" height="22" editable="false"/>
			    <Label text="裁剪：" y="1" stroke="0x0" color="0xffffff" x="255"/>
			    <TextInput text="0" skin="png.comp.textinput" x="290" y="1" var="cut_width_lb" restrict="-0123456789" width="35" height="22" editable="false"/>
			    <TextInput text="0" skin="png.comp.textinput" x="327" y="1" var="cut_height_lb" restrict="-0123456789" width="35" height="22" editable="false"/>
			  </Box>
			  <Box top="23" width="416" bottom="0" left="0">
			    <Image skin="png.comp.bg" left="0" right="0" top="0" bottom="0" sizeGrid="5,30,5,5"/>
			    <Button label="编辑资源" skin="png.comp.button" x="2" y="2" width="50" height="23" var="res_btn"/>
			    <TextInput skin="png.comp.textinput" y="2" height="22" var="res_lb" editable="false" right="3" left="53" x="0"/>
			    <Button label="地图配置" skin="png.comp.button" x="2" y="26" width="50" height="23" var="mapConf_btn"/>
			    <TextInput skin="png.comp.textinput" y="26" height="22" var="mapConf_lb" right="3" left="53" x="53" editable="false"/>
			    <Button label="发布资源" skin="png.comp.button" x="2" y="48" width="50" height="23" var="publish_res_btn"/>
			    <TextInput skin="png.comp.textinput" y="49" height="22" var="publish_lb" editable="false" right="53" left="53" x="53" width="360"/>
			    <Button label="发布" skin="png.comp.button" x="365" y="48" width="50" height="23" var="publish_btn" right="3"/>
			    <Tree spaceLeft="10" spaceBottom="2" var="tree" scrollBarSkin="png.comp.vscroll" bottom="303" top="78" x="0" y="0" width="150">
			      <Box name="render" width="200">
			        <Clip skin="png.comp.clip_selectBox" clipY="2" name="selectBox" x="15" width="135" alpha="0.7" y="0" height="20"/>
			        <Clip skin="png.comp.clip_tree_arrow" y="2" clipY="2" name="arrow"/>
			        <Clip skin="png.comp.clip_tree_folder" x="16" clipY="3" name="folder"/>
			        <Label x="36" y="0" name="label"/>
			      </Box>
			    </Tree>
			    <List x="150" repeatX="2" vScrollBarSkin="png.comp.vscroll" width="263" spaceY="5" top="78" bottom="303" var="res_list" y="26" spaceX="5">
			      <Box name="render" width="120" height="100" mouseChildren="false">
			        <Clip skin="png.comp.clip_selectBox" x="0" y="0" name="selectBox" width="120" height="100" clipY="2"/>
			        <Image width="120" height="100" name="im" x="0" y="0"/>
			        <Label x="0" y="0" name="url_lb" width="120" multiline="true" wordWrap="true" text="label" height="100"/>
			      </Box>
			    </List>
			    <Box var="preview_box" height="300" x="3" width="410" bottom="3" y="183">
			      <Image skin="png.comp.blank" left="0" right="0" top="0" bottom="0"/>
			      <Box x="205" y="150" var="preview_line_box">
			        <Image x="0" y="0" var="preview_im"/>
			        <Image x="0" y="0" var="preview_tile_im" mouseEnabled="false"/>
			      </Box>
			      <Label text="注册点：" y="270" stroke="0x0" color="0xffffff" x="125"/>
			      <TextInput text="0" skin="png.comp.textinput" x="172" y="270" var="pos_x_lb" restrict="-0123456789" width="33" height="22" editable="false"/>
			      <TextInput text="0" skin="png.comp.textinput" x="208" y="270" var="pos_y_lb" restrict="-0123456789" width="33" height="22" editable="false"/>
			      <Button label="保存" skin="png.comp.button" x="252" y="269" width="50" height="23" var="pos_btn"/>
			      <ComboBox labels="层级,地上,地面,地下" skin="png.comp.combobox" x="50" y="269" selectedIndex="0" width="62" height="23" var="pos_layer_cb"/>
			    </Box>
			  </Box>
			  <Button label="新建" skin="png.comp.button" x="0" y="0" width="50" height="23" var="new_btn" toolTip="Ctrl+N"/>
			  <Button label="保存" skin="png.comp.button" x="100" y="0" width="50" height="23" var="save_btn" toolTip="Ctrl+S"/>
			  <CheckBox label="地上" skin="png.comp.checkbox" x="287" y="4" var="up_cb" selected="true"/>
			  <CheckBox label="网格" skin="png.comp.checkbox" x="244" y="4" var="grid_cb" selected="true"/>
			  <CheckBox label="路点" skin="png.comp.checkbox" x="201" y="4" var="point_cb" selected="true"/>
			  <Button label="打开" skin="png.comp.button" x="50" y="0" width="50" height="23" var="open_btn" toolTip="Ctrl+O"/>
			  <CheckBox label="地面" skin="png.comp.checkbox" x="330" y="4" var="ground_cb" selected="true"/>
			  <CheckBox label="地下" skin="png.comp.checkbox" x="373" y="4" var="down_cb" selected="true"/>
			  <Tab labels="路点(F1),地上(F2),地面(F3),地下(F4)" skin="png.comp.tab" direction="horizontal" buttonMode="true" labelColors="0x000000,0x000000,0xff0000" labelBold="true" scaleX="1.2" scaleY="1.5" var="layer_type_tab" left="416" top="0"/>
			  <Button label="擦除(Ctrl+Q)" skin="png.comp.button" width="120" height="40" labelBold="true" buttonMode="true" labelSize="20" toggle="true" labelColors="0x000000,0x000000,0xff0000" var="clear_btn" x="755" y="0"/>
			  <Button label="填充(Ctrl+A)" skin="png.comp.button" width="120" height="40" labelBold="true" labelSize="20" labelColors="0x000000,0x000000,0xff0000" var="fill_btn" x="875" y="0" buttonMode="true"/>
			  <Button label="属性" skin="png.comp.button" x="150" y="0" width="50" height="23" var="modify_btn"/>
			  <Button label="撤销(Ctrl+Z)" skin="png.comp.button" width="120" height="40" labelBold="true" labelSize="20" labelColors="0x000000,0x000000,0xff0000" var="undo_btn" x="995" y="0" buttonMode="true"/>
			  <Button label="重做(Ctrl+Y)" skin="png.comp.button" width="120" height="40" labelBold="true" labelSize="20" labelColors="0x000000,0x000000,0xff0000" var="redo_btn" x="1115" y="0" buttonMode="true"/>
			  <Button label="裁剪" skin="png.comp.button" width="60" height="40" labelBold="true" labelSize="20" labelColors="0x000000,0x000000,0xff0000" var="cut_btn" x="1240" y="0" buttonMode="true" toggle="true"/>
			</View>;
		public function MapEditorUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);
		}
	}
}