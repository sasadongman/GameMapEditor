package
{
	import com.riaspace.nativeUpdater.NativeUpdater;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import modules.MainPage.MainPage;
	import morn.core.handlers.Handler;
	import utils.MessageUtil;
	
	/**
	 * ...
	 * @author Alex
	 */
	public class Main extends Sprite 
	{
		private var _uiContainer:Sprite;
		private var _mainPage:MainPage;
		private var _nativeUpdater:NativeUpdater;
		public function Main() 
		{
			NativeUpdater.UPDATE_DESCRIPTOR_URL = "http://192.168.0.107:8889/SmhTools/update.xml";
			_nativeUpdater = new NativeUpdater();
			_nativeUpdater.addEventListener(NativeUpdater.UPDATE, nativeUpdater_update);
			_nativeUpdater.updateApplication();
			
			_uiContainer = new Sprite();
			this.addChild(_uiContainer);
			//
			App.init(_uiContainer);
			App.loader.loadAssets(["comp.swf"], new Handler(loadComplete));
		}
		
		private function nativeUpdater_update(e:Event):void 
		{
			MessageUtil.alert("检测到更新文件，请在打开的文件夹中双击“SmhTools.air”进行更新！");
		}
		
		private function loadComplete():void
		{
			stage.quality = StageQuality.HIGH_8X8;
			
			_mainPage = new MainPage();
			Log.log_ta = _mainPage.log_ta;
			_uiContainer.addChild(_mainPage);
			
			stage.addEventListener(Event.RESIZE, stage_resize);
		}
		
		private function stage_resize(e:Event):void
		{
			_mainPage.setSize(stage.stageWidth, stage.stageHeight);
		}
	}
	
}