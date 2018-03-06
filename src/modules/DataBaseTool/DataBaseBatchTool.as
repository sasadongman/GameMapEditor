package modules.DataBaseTool 
{
	import com.easily.ds.DataBaseData;
	import com.easily.util.DataBase;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import modules.IPage;
	import morn.DataBaseBatchToolUI;
	import morn.core.handlers.Handler;
	import utils.*;
	/**
	 * ...
	 * @author Alex
	 */
	public class DataBaseBatchTool extends DataBaseBatchToolUI implements IPage
	{
		private var serverList_arr:Array = [];
		private var loader:URLLoader;
		public function DataBaseBatchTool() 
		{
			super();
			var server_list_url:String = FlashCookie.getValue(FlashCookieConst.SERVER_LIST_URL);
			if (server_list_url)
			{
				this.serverList_ti.text = server_list_url;
			}
			record_btn.clickHandler = new Handler(recordHandle);
			excute_btn.clickHandler = new Handler(excuteHandle);
		}
		
		public function transIn():void
		{
			Log.log("若要同时导出到Laya，勾选Laya。");
			Log.log("点击“处理”按钮，等待处理完成！");
			//
			getServerList();
		}
		
		public function transOut():void
		{
			
		}
		
		private function recordHandle():void
		{
			FlashCookie.setValue(FlashCookieConst.SERVER_LIST_URL, this.serverList_ti.text);
		}
		
		private function getServerList():void
		{
			loader = new URLLoader();
			var url:String = serverList_ti.text;
			var req:URLRequest = new URLRequest(url);
			loader.dataFormat = URLLoaderDataFormat.TEXT;
            loader.addEventListener(Event.COMPLETE, complete_handle);
            loader.addEventListener(IOErrorEvent.IO_ERROR, ioError_handle);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityError_handle);
			loader.load(req);
		}
		
		//数据回调
		private function complete_handle(e:Event):void
		{
			var json_str:String = loader.data as String;
			var result:Object = JSON.parse(json_str);
			serverList_arr = result.data.list;
			disposeServerList();
		}
		
		//IO错误回调
		private function ioError_handle(e:IOErrorEvent):void
		{
			disposeServerList();
		}
		
		//安全错误回调
		private function securityError_handle(e:SecurityErrorEvent):void 
		{
			disposeServerList();
		}
		
		private function disposeServerList():void
		{
			loader.removeEventListener(Event.COMPLETE, complete_handle);
            loader.removeEventListener(IOErrorEvent.IO_ERROR, ioError_handle);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityError_handle);
			loader = null;
		}
		
		private function excuteHandle():void 
		{
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
			curIndex = 0;
			iterationHandle();
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
		
		private var curIndex:int = 0;
		private var curServerData:Object;
		private function iterationHandle():void
		{
			if (curIndex <= serverList_arr.length - 1) 
			{
				curServerData = serverList_arr[curIndex];
				curIndex ++;
				unite_dat_ba = new ByteArray();
				//连接数据库
				connectDatabase();
			}
			else 
			{
				//结束
				Log.log("所有数据库导表成功！");
			}
		}
		
		private var dataBase:DataBase;
		private function connectDatabase():void
		{
			Log.log("----------------------------------------------------");
			Log.log("开始连接数据库:" + curServerData.databaseHost + ":" + curServerData.databasePort);
			var databaseData:DataBaseData = new DataBaseData();     
			databaseData.host = curServerData.databaseHost;
			databaseData.port = curServerData.databasePort;
			databaseData.username = curServerData.databaseUsername;
			databaseData.password = curServerData.databasePassword;
			databaseData.database = curServerData.databaseDbname;
			
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
			dataBase.select("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '" + curServerData.databaseDbname + "'", getAllTableComplete, getAllTableError);
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
		private var unite_dat_ba:ByteArray;
		private function getTableColumnNames():void
		{
			if (_file_index == tableName_arr.length)
			{
				dataBase.disconnect();
				dataBase = null;
				tableName_arr = null;
				Log.log("所有表导出成功！");
				unite_dat_ba.compress();
				unite_dat_ba.position = 0;
				var fs:FileStream = new FileStream();
				var dat_path:String = flash_txt_ti.text + "/type_" + curServerData.id + ".dat";
				fs.open(new File(dat_path), FileMode.WRITE);
				fs.writeBytes(unite_dat_ba);
				fs.close();
				Log.log("生成配置压缩文件成功:" + dat_path);
				Log.log("----------------------------------------------------");
				iterationHandle();
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
			//TxtGenerator.generate(flash_txt_ti.text + "/" + cur_table_name + ".txt", file_str, false);
			
			var relativePath:String = cur_table_name + ".txt";
			unite_dat_ba.writeByte(relativePath.length);
			unite_dat_ba.writeUTFBytes(relativePath);
			
			var ba:ByteArray = new ByteArray();
			ba.writeUTFBytes(file_str);
			ba.position = 0;
			unite_dat_ba.writeInt(ba.length);
			unite_dat_ba.writeBytes(ba);
			
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