/**Created by the Morn,do not modify.*/
package morn {
	import morn.core.components.*;
	import modules.AnimationTool.AnimationTool;
	import modules.AvatarNameTool.AvatarNameTool;
	import modules.AvatarTool.AvatarBatchTool;
	import modules.AvatarTool.AvatarTool;
	import modules.CardBatchTool.CardBatchTool;
	import modules.CardNameTool.CardNameTool;
	import modules.ClipTool.ClipTool;
	import modules.ComicsTool.ComicsTool;
	import modules.CutTool.CutTool;
	import modules.DataBaseTool.DataBaseBatchTool;
	import modules.DataBaseTool.DataBaseTool;
	import modules.EnumTool.EnumTool;
	import modules.ImageAddSpace.ImageAddSpace;
	import modules.ImageCompress.ImageCompress;
	import modules.MapEditor.MapEditor;
	import modules.ProtoTool.ProtoTool;
	import modules.VersionTool.VersionTool;
	public class MainPageUI extends View {
		public var page_vs:ViewStack = null;
		public var page_tab:Tab = null;
		public var applicationDirectory_bt:Button = null;
		public var applicationStorageDirectory_bt:Button = null;
		public var ver_lb:Label = null;
		public var permission_cb:ComboBox = null;
		public var log_ta:TextArea = null;
		public var log_btn:Button = null;
		public var clear_log_btn:Button = null;
		protected static var uiView:XML =
			<View width="900" height="600">
			  <ViewStack var="page_vs" left="80" top="5" right="10" bottom="210" x="0" y="0">
			    <AvatarTool runtime="modules.AvatarTool.AvatarTool" name="item0"/>
			    <AvatarNameTool x="0" y="0" name="item1" runtime="modules.AvatarNameTool.AvatarNameTool"/>
			    <AnimationTool x="0" y="0" name="item2" runtime="modules.AnimationTool.AnimationTool"/>
			    <ClipTool x="0" y="0" name="item3" runtime="modules.ClipTool.ClipTool"/>
			    <ProtoTool x="0" y="0" runtime="modules.ProtoTool.ProtoTool" name="item4"/>
			    <EnumTool x="0" y="0" name="item5" runtime="modules.EnumTool.EnumTool"/>
			    <VersionTool x="0" y="0" name="item6" runtime="modules.VersionTool.VersionTool"/>
			    <AvatarBatchTool x="0" y="0" runtime="modules.AvatarTool.AvatarBatchTool" name="item7"/>
			    <CardNameTool x="0" y="0" name="item8" runtime="modules.CardNameTool.CardNameTool"/>
			    <CutTool x="0" y="0" name="item9" runtime="modules.CutTool.CutTool"/>
			    <ComicsTool x="0" y="0" name="item10" runtime="modules.ComicsTool.ComicsTool"/>
			    <CardBatchTool x="0" y="0" runtime="modules.CardBatchTool.CardBatchTool" name="item11"/>
			    <DataBaseTool x="0" y="0" runtime="modules.DataBaseTool.DataBaseTool" name="item12"/>
			    <MapEditor x="0" y="0" name="item13" runtime="modules.MapEditor.MapEditor" width="810" height="380"/>
			    <ImageCompress x="0" y="0" runtime="modules.ImageCompress.ImageCompress" name="item14"/>
			    <ImageAddSpace x="0" y="0" name="item15" runtime="modules.ImageAddSpace.ImageAddSpace"/>
			    <DataBaseBatchTool x="0" y="0" name="item16" runtime="modules.DataBaseTool.DataBaseBatchTool"/>
			  </ViewStack>
			  <Tab skin="png.comp.tab" x="0" y="30" direction="vertical" var="page_tab" labelBold="true" space="2"/>
			  <Button label="应用目录" skin="png.comp.button" left="2" bottom="70" var="applicationDirectory_bt"/>
			  <Button label="存储目录" skin="png.comp.button" left="2" bottom="40" var="applicationStorageDirectory_bt"/>
			  <Label text="ADMIN 1.33" left="5" bottom="10" var="ver_lb" x="1" y="-565"/>
			  <ComboBox labels="label1,label2" skin="png.comp.combobox" x="1" y="5" width="78" height="23" var="permission_cb"/>
			  <TextArea skin="png.comp.textarea" width="810" height="200" var="log_ta" vScrollBarSkin="png.comp.vscroll" bottom="10" right="10" left="80" editable="false" x="0" y="0"/>
			  <Button label="隐藏日志" skin="png.comp.button" var="log_btn" right="30" bottom="10" x="0" y="0"/>
			  <Button label="清除日志" skin="png.comp.button" bottom="10" right="110" var="clear_log_btn"/>
			</View>;
		public function MainPageUI(){}
		override protected function createChildren():void {
			viewClassMap["modules.AnimationTool.AnimationTool"] = AnimationTool;
			viewClassMap["modules.AvatarNameTool.AvatarNameTool"] = AvatarNameTool;
			viewClassMap["modules.AvatarTool.AvatarBatchTool"] = AvatarBatchTool;
			viewClassMap["modules.AvatarTool.AvatarTool"] = AvatarTool;
			viewClassMap["modules.CardBatchTool.CardBatchTool"] = CardBatchTool;
			viewClassMap["modules.CardNameTool.CardNameTool"] = CardNameTool;
			viewClassMap["modules.ClipTool.ClipTool"] = ClipTool;
			viewClassMap["modules.ComicsTool.ComicsTool"] = ComicsTool;
			viewClassMap["modules.CutTool.CutTool"] = CutTool;
			viewClassMap["modules.DataBaseTool.DataBaseBatchTool"] = DataBaseBatchTool;
			viewClassMap["modules.DataBaseTool.DataBaseTool"] = DataBaseTool;
			viewClassMap["modules.EnumTool.EnumTool"] = EnumTool;
			viewClassMap["modules.ImageAddSpace.ImageAddSpace"] = ImageAddSpace;
			viewClassMap["modules.ImageCompress.ImageCompress"] = ImageCompress;
			viewClassMap["modules.MapEditor.MapEditor"] = MapEditor;
			viewClassMap["modules.ProtoTool.ProtoTool"] = ProtoTool;
			viewClassMap["modules.VersionTool.VersionTool"] = VersionTool;
			super.createChildren();
			createView(uiView);
		}
	}
}