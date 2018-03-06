package modules.CardBatchTool 
{
	import com.easily.ds.DataBaseData;
	import com.easily.util.DataBase;
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import modules.IPage;
	import morn.CardBatchToolUI;
	import morn.core.handlers.Handler;
	import smh.model.resource.staticConfig.txt.type_card;
	import utils.ImageCreator;
	
	/**
	 * ...
	 * @author Alex
	 */
	public class CardBatchTool extends CardBatchToolUI implements IPage
	{
		private var resource_folder:File;
		private var output_folder:File;
		
		private var cardView:CardView;
		private var cardViewSpr:Sprite;
		
		private var card_arr:Array;
		private var total_len:int;
		private var temp_index:int;
		public function CardBatchTool() 
		{
			super();
		}
		
		public function transIn():void
		{
			init();
			Log.log("1.填入资源文件夹");
			Log.log("2.填入目标文件夹");
			Log.log("3.点击执行");
			Log.log("4.等待完成");
		}
		
		public function transOut():void
		{
			
		}
		
		private var isInit:Boolean = false;
		private function init():void
		{
			if (isInit) 
			{
				return;
			}
			isInit = true;
			
			output_it.text = File.desktopDirectory.nativePath + "\\卡牌输出";
			connectDatabase();
		}
		
		//数据库
		private var dataBase:DataBase;
		private var _file_index:int = 0;
		private function connectDatabase():void
		{
			Log.log("开始连接数据库...");
			var databaseData:DataBaseData = new DataBaseData();     
			databaseData.host = "192.168.0.231";
			databaseData.port = 3306;
			databaseData.username = "guest";
			databaseData.password = "123456";
			databaseData.database = "smh_type_yf";
			
			dataBase = new DataBase(databaseData);
			dataBase.addEventListener(Event.CONNECT, onDataBaseConnected);
			dataBase.connect();
		}
		
		private function onDataBaseConnected(event:Event):void
		{
			//trace("BattleDateBaseProxy/onConnected()");
			dataBase.removeEventListener(Event.CONNECT, onDataBaseConnected);
			
			getAllTable(null, false);
		}
		
		private var tableName_arr:Array;
		private function getAllTable(arr:Array = null, isError:Boolean = true):void
		{
			if (arr == null && !isError)
			{
				dataBase.select("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'smh_type_yf'", getAllTable, getAllTable);
			}
			else 
			{
				if (arr) 
				{
					Log.log("数据库读取所有表名成功！");
					tableName_arr = arr;
					_file_index = 0;
					getTableData();
				}
				else
				{
					Log.log("数据库读取所有表名失败！");
					dataBase.disconnect();
					dataBase = null;
					finishDataBase();
				}
			}
		}
		
		/**
		 * 转换类名
		 * @param	name
		 * @return
		 */
		private static function transNameToClassName(name:String):String
		{
			switch (name) 
			{
				case "type_jiaju":
					return "type_dress";
				default:
					return name;
			}
		}
		
		/**
		 * 检测是否清空表
		 * @param	name
		 * @return
		 */
		private static function checkClearTable(name:String):Boolean
		{
			switch (name) 
			{
				case "type_jiaju":
					return false;
				default:
					return true;
			}
		}
		
		private var cur_table_name:String;
		private function getTableData(arr:Array = null):void
		{
			if (arr)
			{
				Log.log(cur_table_name + " 表读取成功！");
				GlobalConst.staticConfigDataBase.addDataBaseTable(transNameToClassName(cur_table_name), arr, checkClearTable(cur_table_name));
			}
			if (_file_index == tableName_arr.length)
			{
				dataBase.disconnect();
				dataBase = null;
				finishDataBase();
				return;
			}
			cur_table_name = tableName_arr[_file_index].TABLE_NAME;
			_file_index++;
			
			var className:String = transNameToClassName(cur_table_name);
			var typeClass:Class;
			try 
			{
				//根据类完整路径得到类
				typeClass = getDefinitionByName("smh.model.resource.staticConfig.txt." + className) as Class;
			}
			catch (err:Error)
			{
				//整个工程代码中如果未使用此类申明变量会报错----->ReferenceError: Error #1065: 变量 *** 未定义。
				//trace(err);
				//Log.log(className + " 表未定义，不读取！");
				getTableData();
				return;
			}
			var sqlStr:String = "SELECT * FROM `" + cur_table_name + "`;";
			dataBase.select(sqlStr, getTableData, getTableData);
		}
		
		private function finishDataBase():void
		{
			excute_btn.clickHandler = new Handler(excute_handle);
			
			cardView = new CardView();
			cardView.handler = new Handler(card_load_handle);
			
			cardViewSpr = new Sprite();
			cardViewSpr.addChild(cardView);
			
			card_arr = [];
			var _type_card_dict:Dictionary = GlobalConst.staticConfigDataBase.getDataDict(type_card);
			for each (var _type_card:type_card in _type_card_dict)
			{
				card_arr.push(_type_card.id);
			}
			total_len = card_arr.length;
			Log.log("卡牌数量：" + total_len);
		}
		
		private function excute_handle():void
		{
			resource_folder = new File(resource_it.text);
			output_folder = new File(output_it.text);
			if (!resource_folder.exists) 
			{
				Log.log("资源文件夹不存在");
				return;
			}
			temp_index = 0;
			excute_one();
		}
		
		private function excute_one():void
		{
			//测试1个
			//if (temp_index >= 1)
			if (temp_index >= total_len)
			{
				excute_finish();
				return;
			}
			var id:int = card_arr[temp_index];
			Log.log("处理卡牌：" + id);
			cardView.setData(id, resource_folder.nativePath);
		}
		
		//private static const SMALL_WIDTH:int = 161;
		//private static const SMALL_HEIGHT:int = 231;
		private function card_load_handle(id:int):void
		{
			var draw_bmd:BitmapData;
			//处理大卡牌
			cardView.label_box.visible = true;
			draw_bmd = new BitmapData(cardView.width, cardView.height, false, 0xFFFFFFFF);
			draw_bmd.draw(cardView, null, null, null, null, false);
			ImageCreator.createImage(output_folder.resolvePath("大\\" + id + "_2.jpg").nativePath, draw_bmd, new JPEGEncoderOptions());
			draw_bmd.dispose();
			
			cardView.label_box.visible = false;
			//cardView.scaleX = SMALL_WIDTH / cardView.width;
			//cardView.scaleY = SMALL_HEIGHT / cardView.height;
			//draw_bmd = new BitmapData(SMALL_WIDTH, SMALL_HEIGHT, false, 0xFFFFFFFF);
			//draw_bmd.draw(cardViewSpr, null, null, null, null, true);
			draw_bmd = new BitmapData(cardView.width, cardView.height, false, 0xFFFFFFFF);
			draw_bmd.draw(cardView, null, null, null, null, false);
			ImageCreator.createImage(output_folder.resolvePath("小\\" + id + ".jpg").nativePath, draw_bmd, new JPEGEncoderOptions());
			draw_bmd.dispose();
			
			//处理下一张
			temp_index++;
			excute_one();
		}
		
		private function excute_finish():void
		{
			Log.log("全部处理完成！");
		}
	}
}