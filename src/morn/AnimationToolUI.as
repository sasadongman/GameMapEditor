/**Created by the Morn,do not modify.*/
package morn {
	import morn.core.components.*;
	public class AnimationToolUI extends View {
		public var bg_im:Image = null;
		public var animation_box:Box = null;
		public var imageQuality_it:TextInput = null;
		public var play_btn:Button = null;
		public var stop_btn:Button = null;
		public var loop_cb:CheckBox = null;
		public var frameRate_it:TextInput = null;
		public var clear_btn:Button = null;
		public var addMode_cb:CheckBox = null;
		public var package_btn:Button = null;
		public var clear_bg_btn:Button = null;
		public var animation_x_lb:TextInput = null;
		public var animation_y_lb:TextInput = null;
		public var speedScale_it:TextInput = null;
		public var ani_btn:Button = null;
		public var info_box:Box = null;
		public var info_list:List = null;
		protected static var uiView:XML =
			<View height="380" width="830" left="0" right="0" top="0" bottom="0">
			  <Image skin="jpg.comp.灰色" left="0" right="0" top="0" bottom="0"/>
			  <Image var="bg_im" x="0" y="0"/>
			  <Box var="animation_box"/>
			  <Box top="10" right="10" x="-25" y="0">
			    <Label text="图像压缩率：" color="0xffffff" stroke="0x0" x="25"/>
			    <TextInput text="80" skin="png.comp.textinput" x="97" var="imageQuality_it" restrict="0-9" width="33" height="22"/>
			    <Button label="播放" skin="png.comp.button" x="55" y="148" var="play_btn"/>
			    <Button label="停止" skin="png.comp.button" x="55" y="180" var="stop_btn"/>
			    <CheckBox label="循环播放" skin="png.comp.checkbox" x="65" y="126" var="loop_cb"/>
			    <Label text="动画帧频：" x="36" y="25" stroke="0x0" color="0xffffff"/>
			    <TextInput text="25" skin="png.comp.textinput" x="97" y="24" var="frameRate_it" restrict="0-9" width="33" height="22"/>
			    <Button label="清除动画" skin="png.comp.button" x="55" y="211" var="clear_btn"/>
			    <CheckBox skin="png.comp.checkbox" x="65" y="77" var="addMode_cb" label="添加模式"/>
			    <Button label="打包swf" skin="png.comp.button" x="56" y="298" var="package_btn" width="75" height="34"/>
			    <Button label="清除背景" skin="png.comp.button" x="56" y="254" var="clear_bg_btn"/>
			    <Label text="动画位置：" y="100" stroke="0x0" color="0xffffff"/>
			    <TextInput text="0" skin="png.comp.textinput" x="61" y="99" var="animation_x_lb" restrict="-0123456789" width="33" height="22"/>
			    <TextInput text="0" skin="png.comp.textinput" x="97" y="99" var="animation_y_lb" restrict="-0123456789" width="33" height="22"/>
			    <Label text="播放速度：" x="36" y="49" stroke="0x0" color="0xffffff"/>
			    <TextInput text="1" skin="png.comp.textinput" x="97" y="48" var="speedScale_it" restrict=".0-9" width="33" height="22" toolTip="只影响显示"/>
			    <Button label="生成ani" skin="png.comp.button" x="56" y="336" var="ani_btn" width="75" height="34"/>
			  </Box>
			  <Box left="0" right="0" top="0" bottom="0" var="info_box">
			    <Image skin="jpg.comp.灰色" left="0" right="0" top="0" bottom="0" x="0" y="0"/>
			    <List centerX="0" bottom="10" top="10" repeatX="1" spaceY="2" vScrollBarSkin="png.comp.vscroll" var="info_list">
			      <Box name="render">
			        <Image skin="jpg.comp.纯色_白" x="0" y="0" width="150" height="20"/>
			        <Clip skin="png.comp.clip_selectBox" x="0" y="0" name="selectBox" width="150" height="20" clipY="2"/>
			        <Label text="label" x="3" y="1" width="146" name="name_lb"/>
			      </Box>
			    </List>
			  </Box>
			</View>;
		public function AnimationToolUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);
		}
	}
}