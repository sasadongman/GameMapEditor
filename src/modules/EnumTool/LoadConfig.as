package modules.EnumTool
{
	import flash.utils.Dictionary;
	
	import morn.core.handlers.Handler;

	/**
	 * @author: hypo.chen
	 * @E-mail: 645338868@qq.com
	 * @create: 2015-10-26 上午10:46:49
	 *
	 */
	public class LoadConfig
	{
		private static var _instance:LoadConfig;
		private var file_index:Number = 0;
		private var data_dict:Dictionary;
		public function LoadConfig(s:S)
		{
		}
		
		public static function getInstatnce():LoadConfig
		{
			if(_instance == null)
			{
				_instance = new LoadConfig(new S());
			}
			return _instance;
		}
		
		public function loadXML():void
		{
			if(file_index == AppConfig.FILES.length)
			{
				//Log.log("xml加载完成");
				parseXML();
				return;
			}
			if(!data_dict)
			{
				data_dict = new Dictionary();
			}
			var file:String = AppConfig.FILES[file_index];
			var url:String = AppConfig.STATIC_CONFIG_ROOT + file;
			App.loader.loadTXT(url,new Handler(onComplete,[file]));
			file_index++;
		}
		
		private function onComplete(file:String,content:String):void
		{
			if(file.indexOf(".xml") != -1)
			{
				var xml:XML = new XML(content);
				data_dict[file] = xml;
			}
			loadXML();
		}
		
		private function parseXML():void
		{
			var _xml:XML = getXML("enum_config.xml");
			//Log.log(_xml.@root);
			AppConfig.ROOT_URL = _xml.@root;
			for(var i:Number = 0;i < _xml.fileInfo.length();i++)
			{
				var fileName:String = _xml.fileInfo[i].@name;
				var fileURL:String = _xml.fileInfo[i].@url;
				var packageURL:String = _xml.fileInfo[i].@packageURL;
				var saveURL:String = _xml.fileInfo[i].@saveURL;
				
				AppConfig.fileName.push(fileName);
				AppConfig.packageURL.push(packageURL);
				AppConfig.fileURL.push(fileURL);
				AppConfig.saveURL.push(saveURL);
			}
			
			var _eventDispatch:AllEvent = new AllEvent(AllEvent.LOAD_COMPLETE);
			_eventDispatch.dispatchEvent();
		}
		
		public function getXML(file:String):XML
		{
			return data_dict[file] as XML;
		}
	}
}

class S{}