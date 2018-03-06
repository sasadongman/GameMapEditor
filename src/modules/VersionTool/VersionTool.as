package modules.VersionTool 
{
	import com.adobe.crypto.MD5;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import modules.IPage;
	import morn.core.handlers.Handler;
	import morn.VersionToolUI;
	import utils.MessageUtil;
	import utils.treeData.TreeNode;
	
	/**
	 * ...
	 * @author Alex
	 */
	public class VersionTool extends VersionToolUI implements IPage
	{
		private var item_data_arr:Array;
		
		private var origin_url:String = "";
		private var target_url:String = "";
		
		private var start_time:int = 0;
		private var pattern_vec:Vector.<RegExp>;
		private var file_version_dict:Object;
		private var origin_version_dict:Object;
		private var target_version_dict:Object;
		public function VersionTool() 
		{
			super();
			var loader:URLLoader = new URLLoader(new URLRequest("xml/version_config.xml"));
			loader.addEventListener(Event.COMPLETE, loader_complete);
		}
		
		public function transIn():void
		{
			//只有管理员才能复制文件
			copy_cb.selected = GlobalConst.permission == GlobalConst.PERMISSION_ADMIN;
			copy_cb.disabled = GlobalConst.permission != GlobalConst.PERMISSION_ADMIN;
		}
		
		public function transOut():void
		{
		}
		
		private function loader_complete(e:Event):void
		{
			var xml:XML = XML(e.target.data);
			
			ignoreExtension_arr = String(xml.ignoreExtension).split(",");
			
			pattern_vec = new Vector.<RegExp>();
			for (i = 0; i < xml.leafNodeFolder.length(); i++) 
			{
				var leafNodeFolder_xml:XML = xml.leafNodeFolder[i];
				pattern_vec.push(new RegExp(String(leafNodeFolder_xml.@pattern)));
			}
			
			item_data_arr = [];
			var items:Array = [];
			for (var i:int = 0; i < xml.item.length(); i++) 
			{
				var item_xml:XML = xml.item[i];
				var temp_label:String = String(item_xml.@label);
				var temp_origin:String = String(item_xml.@origin);
				var temp_target:String = String(item_xml.@target);
				var clearOld:Boolean = String(item_xml.@clearOld) == "1";
				item_data_arr.push( { label:temp_label, origin:temp_origin, target:temp_target, clearOld:clearOld } );
				items.push(temp_label);
			}
			item_cb.dataSource = items;
			item_cb.selectHandler = new Handler(item_cb_select);
			item_cb.selectedIndex = 0;
			
			var curDate:Date = new Date();
			_dateFilter_year_txt.text = curDate.fullYear + "";
			_dateFilter_month_txt.text = (curDate.month + 1) + "";
			_dateFilter_day_txt.text = curDate.date + "";
			
			config_btn.clickHandler = new Handler(config_btn_click);
			unite_dat_btn.clickHandler = new Handler(unite_dat_handler);
			excute_btn.clickHandler = new Handler(excute_btn_handler);
			
			open_origin_btn.clickHandler = new Handler(open_origin_handle);
			open_target_btn.clickHandler = new Handler(open_target_handle);
		}
		
		private function config_btn_click():void 
		{
			var file:File = File.applicationDirectory.resolvePath("xml");
			file.openWithDefaultApplication();
		}
		
		private function open_origin_handle():void
		{
			var folder:File = new File(origin_url);
			if (folder.exists) 
			{
				folder.openWithDefaultApplication();
				Log.log("打开原始目录：" + origin_url);
			}
			else 
			{
				Log.log("原始目录不存在！");
			}
		}
		
		private function open_target_handle():void
		{
			var folder:File = new File(target_url);
			if (folder.exists && folder.parent && folder.parent.exists) 
			{
				folder.parent.openWithDefaultApplication();
				Log.log("打开目标目录：" + target_url);
			}
			else 
			{
				Log.log("目标目录不存在！");
			}
		}
		
		private function item_cb_select(index:int):void 
		{
			var item_data:Object = item_data_arr[index];
			origin_ti.text = origin_url = item_data.origin;
			target_ti.text = target_url = item_data.target;
			clear_old_cb.selected = item_data.clearOld;
			clear_old_cb.disabled = !item_data.clearOld;
		}
		
		//打包unite.dat文件
		private function unite_dat_handler():void 
		{
			UniteDataUtil.packageUniteData(origin_url + "assets\\staticConfig");
			Log.log("unite.dat文件打包完毕!");
		}
		
		private function excute_btn_handler():void 
		{
			UniteDataUtil.packageUniteData(origin_url + "assets\\staticConfig");
			Log.log("unite.dat文件打包完毕!");
			excuteContinueHandle();
		}
		
		private function excuteContinueHandle():void
		{
			//trace("excute_btn_handler()");
			initVersionXml();
			//
			var nativeFile:File = new File(origin_url);
			if (!nativeFile.exists)
			{
				Log.log("原始路径不存在!");
				Log.log("更新失败！");
				return;
			}
			if (!nativeFile.isDirectory)
			{
				Log.log("原始路径不是文件夹!");
				Log.log("更新失败！");
				return;
			}
			//
			start_time = getTimer();
			//
			Log.log("原始路径:" + origin_url);
			Log.log("目标路径:" + target_url);
			//
			file_version_dict = {};
			origin_version_dict = {};
			target_version_dict = {};
			//
			var version_file:File;
			//读取原始version.dat文件
			var origin_version_dat_url:String = target_url + "version.dat";
			version_file = new File(origin_version_dat_url);
			if (!version_file.exists)
			{
				Log.log("origin版本文件缺失:" + origin_version_dat_url);
			}
			else 
			{
				Log.log("origin版本文件存在:" + origin_version_dat_url);
				var ba:ByteArray = new ByteArray();
				var fs:FileStream = new FileStream();
				try
				{
					fs.open(version_file, FileMode.READ);
					fs.readBytes(ba);
					fs.close();
					//
					ba.uncompress();
					var str:String = ba.readUTFBytes(ba.length);
					ba.clear();
					if (str.indexOf("<?xml") != -1)
					{
						var xml:XML = new XML(str);
						for (var i:int = 0; i < xml.item.length(); i++) 
						{
							var temp_xml:XML = xml.item[i];
							origin_version_dict[String(temp_xml.@key)] = { ver:String(temp_xml.@ver), md5:String(temp_xml.@md5) };
						}
					}
					else 
					{
						origin_version_dict = JSON.parse(str);
					}
					Log.log("origin版本文件加载成功！");
				}
				catch (e:Error)
				{
					Log.log(e.message);
					Log.log("origin版本文件加载失败！");
				}
			}
			//读取目标version.dat文件
			var target_version_dat_url:String = target_url + "version.dat";
			version_file = new File(target_version_dat_url);
			if (!version_file.exists)
			{
				Log.log("target版本文件缺失:" + target_version_dat_url);
			}
			else 
			{
				Log.log("target版本文件存在:" + target_version_dat_url);
				ba = new ByteArray();
				fs = new FileStream();
				try
				{
					fs.open(version_file, FileMode.READ);
					fs.readBytes(ba);
					fs.close();
					//
					ba.uncompress();
					str = ba.readUTFBytes(ba.length);
					ba.clear();
					if (str.indexOf("<?xml") != -1) 
					{
						xml = new XML(str);
						for (i = 0; i < xml.item.length(); i++) 
						{
							temp_xml = xml.item[i];
							target_version_dict[String(temp_xml.@key)] = { ver:String(temp_xml.@ver), md5:String(temp_xml.@md5) };
						}
					}
					else 
					{
						target_version_dict = JSON.parse(str);
					}
					Log.log("target版本文件加载成功！");
				}
				catch (e:Error)
				{
					Log.log(e.message);
					Log.log("target版本文件加载失败！");
				}
			}
			//
			if (clear_old_cb.selected)
			{
				//清除目标路径
				clearFolderByUrl(target_url);
			}
			//
			Log.log("处理更新文件！");
			initTreeRoot();
		}
		
		/**
		 * 获取版本
		 * @param	key			文件相对路径
		 * @param	storage		存储类型	VersionConst.FILE VersionConst.ORIGIN VersionConst.TARGET
		 * @param	type		数据类型	VersionConst.TIME VersionConst.MD5
		 * @return
		 */
		private function getVersion(key:String, storage:int, type:int):String
		{
			var version_dict:Object;
			switch (storage) 
			{
				//case VersionConst.FILE:
					//直接读取文件
				//break;
				case VersionConst.ORIGIN:
					version_dict = origin_version_dict;
				break;
				case VersionConst.TARGET:
					version_dict = target_version_dict;
				break;
			}
			if (storage == VersionConst.ORIGIN || storage == VersionConst.TARGET)
			{
				if (version_dict == null) 
				{
					return "";
				}
				var version_data:Object = version_dict[key];
				if (version_data)
				{
					if (type == VersionConst.TIME) 
					{
						return version_data.ver;
					}
					else 
					{
						return version_data.md5;
					}
				}
				else 
				{
					return "";
				}
			}
			else 
			{
				var file:File = new File(origin_url + key);
				if (file.exists) 
				{
					if (type == VersionConst.TIME) 
					{
						return "" + file.modificationDate.time;
					}
					else 
					{
						var ba:ByteArray = new ByteArray();
						//Log.timerStart();
						var fileStream:FileStream = new FileStream();
						fileStream.open(file, FileMode.READ);
						fileStream.readBytes(ba);
						fileStream.close();
						//Log.timerEnd("读取文件");
						//
						//Log.timerStart();
						var md5:String = MD5.hashBinary(ba);
						//Log.timerEnd(key + " " + md5);
						return md5;
					}
				}
				else 
				{
					return "";
				}
			}
		}
		
		/**
		 * 设置版本号
		 * @param	key		文件相对路径
		 * @param	time	时间
		 * @param	md5		md5
		 * @return
		 */
		private function setVersion(key:String, time:String, md5:String):void
		{
			file_version_dict[key] = { ver:time, md5:md5 };
		}
		
		//清除目标路径
		private function clearFolderByUrl(url:String):void
		{
			var file:File = new File(url);
			if (!file.exists)
			{
				return;
			}
			if (!file.isDirectory)
			{
				return;
			}
			file.deleteDirectory(true);
		}
		
		private var treeRoot:TreeNode;
		private var curNode:TreeNode;
		private var curFolderName:String = "";
		private function initTreeRoot():void
		{
			treeRoot = new TreeNode(origin_url, false, false, true);
			curNode = treeRoot;
			iterationProcessLeaf();
		}
		
		//裁剪图片加载
		private function iterationProcessLeaf():void
		{
			//trace("iterationProcessLeaf()");
			//trace(curNode.getPath());
			var folderFile:File = new File(curNode.getPath());
			//trace("folderFile:" + folderFile);
			curFolderName = folderFile.name;
			//trace("curFolderName:" + curFolderName);
			
			var folderList:Array = folderFile.getDirectoryListing();
			//trace("folderList.length:" + folderList.length);
			var swfList:Vector.<String> = new Vector.<String>();
			
			//var time:String = file.modificationDate.time + "";
			var file_time:String = "";
			var origin_time:String = "";
			var target_time:String = "";
			var file_md5:String = "";
			var origin_md5:String = "";
			var target_md5:String = "";
			for (var i:int = 0; i < folderList.length; i++)
			{
				var file:File = folderList[i] as File;
				var path:String = curNode.getPathPro("/", false);
				var key:String;
				if (path == "")
				{
					key = file.name;
				}
				else 
				{
					key = path + "/" + file.name;
				}
				//trace("file.nativePath:" + file.nativePath);
				//trace("file.extension:" + file.extension);
				//trace("key:" + key);
				if (file.isDirectory) 
				{
					//@开头的文件夹为忽略文件夹----Alex 0715
					if (file.name.charAt(0) == "@") 
					{
						continue;
					}
					if (checkLeafNodeFolder(file.name))
					{
						file_time = getVersion(key, VersionConst.FILE, VersionConst.TIME);
						if (file_time == target_time)
						{
							//文件时间和目标时间一致
							//无需更新文件
							if (whole_cb.selected) 
							{
								copyFileToTarget(file);
							}
						}
						else 
						{
							//复制文件
							copyFileToTarget(file);
						}
						//写入文件版本号
						writeVersion(key, true, file_time);
					}
					else
					{
						curNode.addChildByAttribute(file.name);
					}
				}
				else 
				{
					if (checkFileExtension(file))
					{
						continue;
					}
					file_time = getVersion(key, VersionConst.FILE, VersionConst.TIME);
					origin_time = getVersion(key, VersionConst.ORIGIN, VersionConst.TIME);
					target_time = getVersion(key, VersionConst.TARGET, VersionConst.TIME);
					//file_md5 = getVersion(key, VersionConst.FILE, VersionConst.MD5);
					origin_md5 = getVersion(key, VersionConst.ORIGIN, VersionConst.MD5);
					target_md5 = getVersion(key, VersionConst.TARGET, VersionConst.MD5);
					if (file_time == target_time)
					{
						//文件时间和目标时间一致
						if (origin_md5 != "") 
						{
							//有原始md5
							file_md5 = origin_md5;
						}
						else 
						{
							//无原始md5，需要重新获取md5码
							file_md5 = getVersion(key, VersionConst.FILE, VersionConst.MD5);
						}
						//无需更新文件
						if (whole_cb.selected) 
						{
							copyFileToTarget(file);
						}
					}
					else
					{
						//文件时间和目标时间不一致
						if (file_time == origin_time) 
						{
							//文件时间和原始时间一致
							if (origin_md5 != "") 
							{
								//有原始md5
								file_md5 = origin_md5;
							}
							else 
							{
								//无原始md5，需要重新获取md5码
								file_md5 = getVersion(key, VersionConst.FILE, VersionConst.MD5);
							}
							//无需更新文件
							if (whole_cb.selected) 
							{
								copyFileToTarget(file);
							}
						}
						else 
						{
							//文件时间和原始时间不一致
							file_md5 = getVersion(key, VersionConst.FILE, VersionConst.MD5);
							if (file_md5 == target_md5) 
							{
								//文件md5和目标md5一致
								//无需更新文件
								if (whole_cb.selected) 
								{
									copyFileToTarget(file);
								}
							}
							else 
							{
								//文件md5和目标md5不一致
								//需要更新文件
								copyFileToTarget(file);
							}
						}
					}
					//写入文件版本号
					writeVersion(key, false, file_time, file_md5);
				}
			}
			curNode.isLeafFinished = true;
			iterationProcessBranch();
		}
		
		//判断是否 叶节点文件夹，此类文件夹有版本号，作为文件夹内的所有文件统一的版本号
		private function checkLeafNodeFolder(fileName:String):Boolean
		{
			var temp_url:String = curNode.getPathPro("/", false) + "/" + fileName;
			//trace("temp_url:" + temp_url);
			for (var i:int = 0; i < pattern_vec.length; i++) 
			{
				var pattern:RegExp = pattern_vec[i];
				if (pattern.test(temp_url)) 
				{
					return true;
				}
			}
			return false;
		}
		
		//处理分支
		private function iterationProcessBranch():void
		{
			var branchNode:TreeNode = curNode.getBranchUnfinishedNode();
			if (branchNode == null) 
			{
				//当前子目录裁剪完毕
				curNode.isBranchFinished = true;
				if (curNode.parent != null) 
				{
					//有父节点时处理父节点分支
					curNode = curNode.parent;
					iterationProcessBranch();
				}
				else 
				{
					createVersionXml();
				}
				return;
			}
			else 
			{
				//分支节点未处理完毕，处理分支节点
				curNode = branchNode;
				iterationProcessLeaf();
			}
		}
		
		//忽略的后缀名
		private var ignoreExtension_arr:Array;
		//
		//检测文件后缀名
		private function checkFileExtension(file:File):Boolean
		{
			if (ignoreExtension_arr == null || ignoreExtension_arr.length == 0) 
			{
				return false;
			}
			for each(var ignoreExtension:String in ignoreExtension_arr) 
			{
				if (file.extension == ignoreExtension)
				{
					return true;
				}
			}
			return false;
		}
		/*
		//检测是否新的文件
		private function checkNewAssertFile(file:File):Boolean
		{
			if (file == null)
			{
				return false;
			}
			if (whole_cb.selected) 
			{
				return true;
			}
			var modificationDate:Date = file.modificationDate;
			if (dateFilter_cb.selected) 
			{
				return checkFileAfterDate(file);
			}
			else
			{
				var path:String = curNode.getPathPro("/", false);
				var key:String;
				if (path == "")
				{
					key = file.name;
				}
				else 
				{
					key = path + "/" + file.name;
				}
				//
				if (target_version_dict[key] && target_version_dict[key].ver == String(modificationDate.time))
				{
					return false;
				}
				else
				{
					return true;
				}
			}
		}
		*/
		//检测文件是否在指定时间后修改
		private function checkFileAfterDate(file:File):Boolean
		{
			var modificationDate:Date = file.modificationDate;
			//trace("modificationDate.fullYear:" + modificationDate.fullYear);
			//trace("modificationDate.month:" + modificationDate.month);
			//trace("modificationDate.day:" + modificationDate.day);
			//trace("_dateFilter_year:" + _dateFilter_year);
			//trace("_dateFilter_month:" + _dateFilter_month);
			//trace("_dateFilter_day:" + _dateFilter_day);
			if (modificationDate.fullYear < int(_dateFilter_year_txt.text)) 
			{
				return false;
			}
			if (modificationDate.month + 1 < int(_dateFilter_month_txt.text)) 
			{
				return false;
			}
			if (modificationDate.date < int(_dateFilter_day_txt.text)) 
			{
				return false;
			}
			if (modificationDate.hours < int(_dateFilter_hour_txt.text)) 
			{
				return false;
			}
			if (modificationDate.minutes < int(_dateFilter_minute_txt.text)) 
			{
				return false;
			}
			return true;
		}
		
		private var version_xml:XML;
		private var version_json:Object;
		private function initVersionXml():void
		{
			var date:Date = new Date;
			var UTCString:String = date.time + "";
			//version_xml = 
			//<data ver={UTCString}>
			//</data>
			version_json = { ver:UTCString };
		}
		
		//写入版本号
		private function writeVersion(key:String, isFolder:Boolean, time:String, md5:String = null):void
		{
			//var item_xml:XML;
			//if (isFolder) 
			//{
				//item_xml =
				//<item key={key} ver={time} md5="" isFolder="true">
				//</item>
			//}
			//else
			//{
				//item_xml =
				//<item key={key} ver={time} md5={md5}>
				//</item>
			//}
			//version_xml[0].appendChild(item_xml);
			version_json[key] = { ver:time };
			if (isFolder) 
			{
				version_json[key].isFolder = true;
			}
			else 
			{
				version_json[key].md5 = md5;
			}
		}
		
		//复制文件
		private function copyFileToTarget(file:File):void
		{
			if (GlobalConst.permission != GlobalConst.PERMISSION_ADMIN) 
			{
				//只有admin权限才能复制文件
				return;
			}
			if (!copy_cb.selected)
			{
				//未勾选 复制文件
				return;
			}
			//if (!checkNewAssertFile(file)) 
			//{
				//return;
			//}
			var path:String = curNode.getPathPro("/", false);
			var temp_url:String;
			if (path == "") 
			{
				temp_url = target_url + file.name;
			}
			else
			{
				temp_url = target_url + path + "/" + file.name;
			}
			Log.log("复制文件:" + temp_url);
			var targetFile:File = new File(temp_url);
			file.copyTo(targetFile, true);
		}
		
		//生成版本xml文件
		private function createVersionXml():void
		{
			//初始化二进制数据
			var version_xml_ba:ByteArray = new ByteArray();
			/*
			//构造一个UTF8的BOM，即3个字节分别是EF BB BF的二进制文件
			version_xml_ba.writeByte(0xEF);
			version_xml_ba.writeByte(0xBB);
			version_xml_ba.writeByte(0xBF);
			//
			version_xml_ba.writeUTFBytes("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
			version_xml_ba.writeUTFBytes(version_xml.toXMLString());
			*/
			version_xml_ba.writeUTFBytes(JSON.stringify(version_json));
			//
			var version_xml_url:String;
			var file:File;
			var fs:FileStream;
			//
			if (version_xml_cb.selected) 
			{
				//version_xml_url = origin_url + "version.xml";
				version_xml_url = origin_url + "version.json";
				Log.log("版本xml路径:" + version_xml_url);
				file = new File(version_xml_url);
				fs = new FileStream();
				try
				{
					fs.open(file, FileMode.WRITE);
					fs.writeBytes(version_xml_ba);
					fs.close();
				}
				catch (e:Error)
				{
					trace(e.message);
				}
			}
			//
			var version_ver_str:String = "";
			//var main_swf_url:String = origin_url + "Main.swf";
			//file = new File(main_swf_url);
			//version_ver_str = file.exists ? "" + file.modificationDate.time : "0";
			version_ver_str = getVersion("Main.swf", VersionConst.ORIGIN, VersionConst.MD5);
			
			//
			//var version_dat_url:String = target_url + "version.dat";
			var version_dat_url:String = origin_url + "version.dat";
			Log.log("版本dat路径:" + version_dat_url);
			file = new File(version_dat_url);
			fs = new FileStream();
			version_xml_ba.compress();
			version_xml_ba.position = 0;
			try
			{
				fs.open(file, FileMode.WRITE);
				fs.writeBytes(version_xml_ba);
				fs.close();
			}
			catch (e:Error)
			{
				trace(e.message);
			}
			//version_ver_str += "," + file.modificationDate.time;
			version_ver_str += "," + getVersion("version.dat", VersionConst.ORIGIN, VersionConst.MD5);
			if (GlobalConst.permission == GlobalConst.PERMISSION_ADMIN) 
			{
				if (copy_cb.selected)
				{
					version_dat_url = target_url + "version.dat";
					Log.log("覆盖目标版本dat路径:" + version_dat_url);
					file.copyTo(new File(version_dat_url), true);
				}
			}
			
			//version_ver_str += "," + getVersion("Login.flv", VersionConst.ORIGIN, VersionConst.MD5);
			
			var version_ver_url:String = origin_url + "version.ver";
			Log.log("版本ver路径:" + version_ver_url);
			file = new File(version_ver_url);
			fs = new FileStream();
			try
			{
				fs.open(file, FileMode.WRITE);
				fs.writeUTFBytes(version_ver_str);
				fs.close();
			}
			catch (e:Error)
			{
				trace(e.message);
			}
			if (GlobalConst.permission == GlobalConst.PERMISSION_ADMIN) 
			{
				if (copy_cb.selected) 
				{
					version_ver_url = target_url + "version.ver";
					Log.log("覆盖目标版本ver路径:" + version_ver_url);
					file.copyTo(new File(version_ver_url), true);
				}
			}
			allFinish();
		}
		
		//处理完成
		private function allFinish():void
		{
			//Log.log("所有素材处理完成！");
			Log.log("处理更新文件 完成！");
			/*
			Log.log("打开更新目录：" + target_url);
			var targetFolder:File = new File(target_url);
			targetFolder.openWithDefaultApplication();
			targetFolder = null;
			
			Log.log("打开上传工具：" + uploadTool_url);
			NativeApplication.nativeApplication.autoExit = true;
			var uploadTool:File = new File();
			uploadTool = uploadTool.resolvePath(uploadTool_url);
			uploadTool.openWithDefaultApplication();
			uploadTool = null;
			
			var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();//AIR2.0中的新类, 创建进程的信息对象
            nativeProcessStartupInfo.executable = uploadTool;// 将你指定的MyFile对象指定为可执行文件
            var uploadToolProcess:NativeProcess = new NativeProcess();// 创建一个本地进程
            uploadToolProcess.start(nativeProcessStartupInfo);// 运行本地进程
			uploadTool = null;
			*/
			
			Log.log("总共耗时:" + ((getTimer() - start_time) / 1000) + "s");
			MessageUtil.dialog("处理更新文件完成！是否打开目标文件夹？", new Handler(open_target_handle_dialog));
		}
		
		private function open_target_handle_dialog(value:Boolean):void
		{
			if (value) 
			{
				open_target_handle();
			}
		}
	}
}