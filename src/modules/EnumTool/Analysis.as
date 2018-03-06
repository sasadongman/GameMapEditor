package modules.EnumTool
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import utils.TxtGenerator;

	public class Analysis
	{
		private static var _instance:Analysis;
		
		private var _urlLrd:URLLoader;
		private var _urlReq:URLRequest;
		
		private var _loadString:String;
		private var _currentClass:Number;
		
		public function Analysis(s:S)
		{
			
		}
		
		public static function getInstance():Analysis
		{
			if(_instance == null)
			{
				_instance = new Analysis(new S());
			}
			return _instance;
		}
		
		public function loadH($URL:String):void
		{
			clearData();
			_urlLrd = new URLLoader();
			//_urlLrd.dataFormat = URLLoaderDataFormat.VARIABLES;
			_urlReq = new URLRequest($URL);
			_urlLrd.addEventListener(Event.COMPLETE, onLoaded);
			_urlLrd.dataFormat = URLLoaderDataFormat.BINARY;
			_urlLrd.load(_urlReq);
		}

		protected function onLoaded(event:Event):void
		{
			var data_ba:ByteArray = event.target.data as ByteArray;
			_loadString = data_ba.readMultiByte(data_ba.length, "gb2312");
			//Log.log(_loadString);
			cutOutEnum(_loadString);
			_urlLrd.removeEventListener(Event.COMPLETE,onLoaded);
			_urlLrd = null;
			_urlReq = null;
		}
		/**
		 * 执行
		 * @param	_url 文本文件路径
		 */
		public function execute(_url:String):void 
		{
			clearData();
			var _data:String = TxtGenerator.read(_url, "gb2312");
			cutOutEnum(_data);
		}
		
		//private var regData:RegExp = /enum\s+(\S+)\r\n\{([\s\S]+)\};/g//一个类的正则表达式
		private var regData:RegExp = /enum\s+(\S+)\r\n\{([^;]+)\};/g//一个类的正则表达式
		
		private function cutOutEnum($data:String):void 
		{
			//截取enum
			//Log.log("$data:" + $data);
			var _result:Object = regData.exec($data);
			//Log.log("_result:" + _result[0]);
			while (_result != null)
			{
				//Log.log("_result:" + _result[0]);
				AppConfig.classNameArr.push(_result[1]);
				AppConfig.varGroup.push(_result[2]);
				_result = regData.exec($data);
			}
			//Log.log("className:" + AppConfig.classNameArr.length);
			//Log.log("varData:" + AppConfig.varGroup.length);
			//
			for (var i:int = 0; i < AppConfig.varGroup.length; i++) 
			{
				_currentClass = i;
				curClassName = AppConfig.classNameArr[i];
				cutOutVar(AppConfig.varGroup[i]);
			}
			
		}
		
		private var curClassName:String;
		
		//private var regVar:RegExp = /(\w+)(.*),(.*)\r\n/g//一个变量的正则表达式
		//解决注释里包含,出问题的bug----Alex 20151204
		private var regVar:RegExp = /(\w+)([^,]*),(.*)\r\n/g//一个变量的正则表达式
		private function cutOutVar($varData:String):void 
		{
			//截取变量
			//Log.log("$varData:" + $varData);
			//if (curClassName == "interactivePrivateType")
			//{
				//trace(curClassName);
			//}
				
			clearArr(AppConfig.varName);
			clearArr(AppConfig.varDataGroup);
			clearArr(AppConfig.noteGroup);
			
			var _result:Object = regVar.exec($varData);
			while (_result != null)
			{
				AppConfig.varName.push(_result[1]);
				AppConfig.varDataGroup.push(_result[2]);
				AppConfig.noteGroup.push(_result[3]);
				_result = regVar.exec($varData);
			}
			
			//Log.log("65h5eh:"+AppConfig.varDataGroup);
			setVarVaule();
		}
		/**
		 * 设置变量值
		 */
		private function setVarVaule():void
		{
			clearArr(AppConfig.varVaule);
			for (var i:int = 0; i < AppConfig.varDataGroup.length; i++) 
			{
				cutOutVaule(AppConfig.varDataGroup[i]);
			}
			
			//Log.log (AppConfig.varVaule);
			getVaule();
		}
		
		/**
		 * 截取变量的具体值
		 * @param	$str
		 * @return
		 */
		
		private var regVaule:RegExp = /=(.*)/g;
		private function cutOutVaule($str:String):void
		{
			if ($str.match("="))
			{
				var _result:Object = regVaule.exec($str);
				//Log.log(_result)
				while (_result != null)
				{
					AppConfig.varVaule.push((_result[1] as String).replace(" ",""));
					_result = regVaule.exec($str);
				}
			}
			//if ($str == "")
			//str有可能==" "，此处无需判断----Alex 20160203
			else
			{
				AppConfig.varVaule.push("");
			}

		}
		/**
		 * 
		 */
		private function getVaule():void 
		{
			clearArr(AppConfig.varItemGroup);
			
			for (var i:int = 0; i < AppConfig.varVaule.length; i++) 
			{
				var itemVar:String;
				if (i == 0)
				{
					//第一项
					if (AppConfig.varVaule[i] == "")
					{
						AppConfig.varVaule[i] = "0";
					}
				}
				
				if (AppConfig.varVaule[i] == "")
				{
					AppConfig.varVaule[i] = String(Number(AppConfig.varVaule[i - 1]) +1);
				}
				else if (!Number(AppConfig.varVaule[i]) && AppConfig.varVaule[i] != "0")
				{
					//Log.log("h4h5r:" + getIndex(AppConfig.varVaule[i]));
					AppConfig.varVaule[i] = AppConfig.varVaule[getIndex(AppConfig.varVaule[i])];//相应索引位置的值赋给该变量
				}
				itemVar = AppConfig.VAR_SIGN + AppConfig.varName[i] + ":" + AppConfig.VAR_TYPE+ "=" + AppConfig.varVaule[i];
				
				AppConfig.varItemGroup.push(itemVar);
			}
			
			//Log.log(AppConfig.varItemGroup);
			getClass();
			
		}
		
		
		private function getClass():void 
		{
			//Log.log("_currentClass:" + _currentClass);
			
			var _result:String;
			
			var _resultItem1:String = AppConfig.PACKAGE + " " + AppConfig.packageName + "\r" + "{" + "\r\t" + "public " + "class ";
			var _resultItem2:String = "";
			var _resultItem3:String = "\t\t" + "public " + "function ";
			
			
			_resultItem1 += AppConfig.classNameArr[_currentClass];
			_resultItem1 += "\r\t" + "{" + "\r";
				
			AppConfig.constructorName = AppConfig.classNameArr[_currentClass];
				
			_resultItem3 += AppConfig.classNameArr[_currentClass];
			_resultItem3 += "()" + "\r\t\t" + "{" +"\r\t\t" + "}" + "\r\t" + "}" + "\r" + "}" + "\r";
				
			for (var j:int = 0; j < AppConfig.varItemGroup.length; j++) 
			{
				_resultItem2 += "\t\t" + AppConfig.varItemGroup[j] + ";" + AppConfig.noteGroup[j] + "\n";
			}
				
			_result = _resultItem1 + _resultItem2 + _resultItem3;
				
			SaveToAS.getInstance().getAS(_result);
		}
		
		/**
		 * 获取某个字段在varName中的索引
		 * @param	$str
		 * @return
		 */
		private function getIndex($str:String):Number 
		{
			var _index:Number;
			for (var i:int = 0; i < AppConfig.varName.length; i++) 
			{
				if ($str == AppConfig.varName[i]) 
				{
					_index = i;
					return _index;
				}
			}
			return _index;
		}
		/**
		 * 清除数据
		 * @param	$arr
		 */
		private function clearArr($arr:Array):void
		{
			while($arr.length)
			{
				$arr.splice(0,1);
			}
		}
		
		private function clearData():void
		{
			clearArr(AppConfig.varDataGroup);
			clearArr(AppConfig.varGroup);
			clearArr(AppConfig.varName);
			clearArr(AppConfig.varVaule);
			clearArr(AppConfig.varItemGroup);
			clearArr(AppConfig.noteGroup);
			clearArr(AppConfig.classNameArr);
		}
	}
}

class S
{
	
}


