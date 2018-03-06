package modules.DataBaseTool 
{
	import com.easily.ds.DataBaseData;
	import com.easily.util.DataBase;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	import modules.IPage;
	import morn.DataBaseToolUI;
	import morn.core.handlers.Handler;
	import utils.MessageUtil;
	import utils.TxtGenerator;
	
	/**
	 * ...
	 * @author Alex
	 */
	public class DataBaseTool extends DataBaseToolUI implements IPage
	{
		
		public function DataBaseTool() 
		{
			super();
			excute_btn.clickHandler = new Handler(excuteHandle);
		}
		
		public function transIn():void
		{
			Log.log("若要同时导出到Laya，勾选Laya。");
			Log.log("点击“处理”按钮，等待处理完成！");
		}
		
		public function transOut():void
		{
			
		}
		
		private function excuteHandle():void 
		{
			if (!as3_txt_cb.selected && !laya_txt_cb.selected) 
			{
				Log.log("未勾选导出txt文件夹！");
				return;
			}
			initNeed();
		}
		
		private var need_dict:Dictionary;
		private function initNeed():void
		{
			var folder:File = new File(check_folder_ti.text);
			if (!folder.exists || !folder.isDirectory) 
			{
				MessageUtil.alert("比对as文件夹错误！");
				return;
			}
			need_dict = new Dictionary();
			var file_arr:Array = folder.getDirectoryListing();
			for each (var file:File in file_arr) 
			{
				if (file.extension == "as") 
				{
					need_dict[file.name.substr(0, file.name.length - 3)] = true;
				}
			}
			//连接数据库
			connectDatabase();
		}
		
		private function checkNeed(tableName:String):Boolean
		{
			switch (tableName) 
			{
				case "type_jiaju":
					return true;
				default:
					return need_dict[tableName] == true;
			}
		}
		
		private var dataBase:DataBase;
		private function connectDatabase():void
		{
			Log.log("开始连接数据库...");
			var databaseData:DataBaseData = new DataBaseData();     
			databaseData.host = host_ti.text;
			databaseData.port = int(port_ti.text);
			databaseData.username = username_ti.text;
			databaseData.password = password_ti.text;
			databaseData.database = database_ti.text;
			
			dataBase = new DataBase(databaseData);
			dataBase.addEventListener(Event.CONNECT, onDataBaseConnected);
			dataBase.connect();
		}
		
		private function onDataBaseConnected(event:Event):void
		{
			Log.log("数据库连接成功！");
			dataBase.removeEventListener(Event.CONNECT, onDataBaseConnected);
			getAllTable();
		}
		
		private var _file_index:int = 0;
		private var tableName_arr:Array;
		private function getAllTable():void
		{
			dataBase.select("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '" + database_ti.text + "'", getAllTableComplete, getAllTableError);
		}
		private function getAllTableComplete(arr:Array):void
		{
			Log.log("读取所有表名成功！");
			tableName_arr = arr;
			_file_index = 0;
			//getTableData();
			getTableColumnNames();
		}
		private function getAllTableError():void
		{
			Log.log("读取所有表名失败！");
			dataBase.disconnect();
			dataBase = null;
			tableName_arr = null;
		}
		
		private var cur_table_name:String;
		private var cur_table_columns_names:Array = [];
		private var file_str:String = "";
		private function getTableColumnNames():void
		{
			if (_file_index == tableName_arr.length)
			{
				dataBase.disconnect();
				dataBase = null;
				tableName_arr = null;
				Log.log("所有表导出成功！");
				return;
			}
			cur_table_name = tableName_arr[_file_index].TABLE_NAME;
			_file_index++;
			if (checkNeed(cur_table_name)) 
			{
				var sqlStr:String = "SHOW COLUMNS FROM " + cur_table_name;
				dataBase.select(sqlStr, getTableColumnNamesComplete, getTableColumnNamesError);
			}
			else 
			{
				Log.log("取消导出表:" + cur_table_name);
				getTableColumnNames();
			}
		}
		private function getTableColumnNamesComplete(arr:Array):void
		{
			cur_table_columns_names.length = 0;
			file_str = "";
			for (var i:int = 0; i < arr.length; i++)
			{
				var data:Object = arr[i];
				cur_table_columns_names.push(data.Field);
				file_str += data.Field;
				if (i == arr.length - 1) 
				{
					file_str += "\r\n";
				}
				else 
				{
					file_str += "\t";
				}
			}
			getTableData();
		}
		private function getTableColumnNamesError():void
		{
			getTableColumnNames();
		}
		
		private function getTableData():void
		{
			var sqlStr:String = "SELECT * FROM `" + cur_table_name + "`;";
			dataBase.select(sqlStr, getTableDataComplete, getTableDataNamesError);
		}
		private function getTableDataComplete(arr:Array):void
		{
			addDataBaseTable(cur_table_name, arr);
			if (as3_txt_cb.selected) 
			{
				TxtGenerator.generate(flash_txt_ti.text + "/" + cur_table_name + ".txt", file_str, false);
			}
			if (laya_txt_cb.selected) 
			{
				TxtGenerator.generate(laya_txt_ti.text + "/" + cur_table_name + ".txt", file_str, false);
			}
			Log.log("成功导出表:" + cur_table_name);
			getTableColumnNames();
		}
		private function getTableDataNamesError():void
		{
			getTableColumnNames();
		}
		
		private function addDataBaseTable(cur_table_name:String, arr:Array):void
		{
			for each (var lineData:Object in arr) 
			{
				for (var i:int = 0; i < cur_table_columns_names.length; i++)
				{
					var param_name:String = cur_table_columns_names[i];
					var param_value:* = lineData[param_name];
					if (param_value) 
					{
						file_str += param_value;
					}
					if (i == cur_table_columns_names.length - 1)
					{
						file_str += "\r\n";
					}
					else 
					{
						file_str += "\t";
					}
				}
			}
		}
	}
}