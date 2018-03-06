/**Created by the Morn,do not modify.*/
package morn {
	import morn.core.components.*;
	public class CardViewUI extends View {
		public var card_box:Box = null;
		public var ball_box:Box = null;
		public var border_clip:Clip = null;
		public var card_up_box:Box = null;
		public var label_box:Box = null;
		public var name_im:Image = null;
		public var name_label:Label = null;
		public var introduceInfo_label:Label = null;
		public var star_box:Box = null;
		public var race_clip:Clip = null;
		protected static var uiView:XML =
			<View width="371" height="532">
			  <Box var="card_box" x="0" y="0"/>
			  <Box x="0" y="0" var="ball_box"/>
			  <Clip skin="png.comp.卡牌.clip_card_border" x="0" y="0" clipX="4" clipY="1" var="border_clip" index="2"/>
			  <Box var="card_up_box" x="0" y="0"/>
			  <Box x="57" y="394" var="label_box">
			    <Image skin="png.comp.卡牌.卡牌主界面卡牌名字" var="name_im"/>
			    <Label text="label" x="51" y="9" width="160" height="18" align="center" color="0xffcc00" var="name_label"/>
			    <Label x="15" y="32" width="226" align="center" color="0xffffff" wordWrap="true" multiline="true" text="67" stroke="0x0,1,5,5,4,2" var="introduceInfo_label"/>
			  </Box>
			  <Box y="463" var="star_box" x="125">
			    <Clip skin="png.comp.卡牌.clip_card_star" x="0" clipX="3" clipY="1" name="star1_clip"/>
			    <Clip skin="png.comp.卡牌.clip_card_star" clipX="3" clipY="1" index="0" name="star2_clip" x="24"/>
			    <Clip skin="png.comp.卡牌.clip_card_star" x="48" clipX="3" clipY="1" index="0" name="star3_clip"/>
			    <Clip skin="png.comp.卡牌.clip_card_star" x="72" clipX="3" clipY="1" index="0" name="star4_clip"/>
			    <Clip skin="png.comp.卡牌.clip_card_star" x="96" clipX="3" clipY="1" index="0" name="star5_clip"/>
			  </Box>
			  <Clip skin="png.comp.卡牌.clip_种族" x="74" y="72" clipX="8" clipY="1" var="race_clip"/>
			</View>;
		public function CardViewUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiView);
		}
	}
}