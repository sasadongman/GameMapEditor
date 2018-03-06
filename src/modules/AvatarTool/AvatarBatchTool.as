package modules.AvatarTool 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	import modules.IPage;
	import morn.AvatarBatchToolUI;
	import morn.core.handlers.Handler;
	import utils.FlashCookie;
	import utils.FlashCookieConst;
	import utils.ImageCreator;
	import utils.MessageUtil;
	
	/**
	 * ...
	 * @author Alex
	 */
	public class AvatarBatchTool extends AvatarBatchToolUI implements IPage
	{
		
		public function AvatarBatchTool() 
		{
			super();
			if (FlashCookie.getValue(FlashCookieConst.AVATAR_BATCH_ORIGIN) != null)
			{
				origin_it.text = FlashCookie.getValue(FlashCookieConst.AVATAR_BATCH_ORIGIN);
			}
			else 
			{
				FlashCookie.setValue(FlashCookieConst.AVATAR_BATCH_ORIGIN, origin_it.text);
			}
			if (FlashCookie.getValue(FlashCookieConst.AVATAR_BATCH_TARGET) != null)
			{
				target_it.text = FlashCookie.getValue(FlashCookieConst.AVATAR_BATCH_TARGET);
			}
			else 
			{
				FlashCookie.setValue(FlashCookieConst.AVATAR_BATCH_TARGET, target_it.text);
			}
			cocos2dx_cb.selected = Boolean(FlashCookie.getValue(FlashCookieConst.AVATAR_COCOS2DX));
			cocos2dx_cb.addEventListener(Event.SELECT, cocos2dx_cb_select);
			save_btn.clickHandler = new Handler(save_handle);
			reset_btn.clickHandler = new Handler(reset_handle);
			excute_btn.clickHandler = new Handler(excute_handle);
		}
		
		public function transIn():void
		{
			Log.log("操作步骤：");
			Log.log("1.确认原始文件夹和目标文件夹路径，如有改变点击“保存”");
			Log.log("2.确认模式，不勾选表示Flash模式，勾选表示Cocos2d-x模式");
			Log.log("3.点击“处理”按钮等待处理完成");
		}
		
		public function transOut():void
		{
			
		}
		
		private function cocos2dx_cb_select(e:Event):void 
		{
			FlashCookie.setValue(FlashCookieConst.AVATAR_COCOS2DX, cocos2dx_cb.selected);
		}
		
		private function save_handle():void 
		{
			FlashCookie.setValue(FlashCookieConst.AVATAR_BATCH_ORIGIN, origin_it.text);
			FlashCookie.setValue(FlashCookieConst.AVATAR_BATCH_TARGET, target_it.text);
			Log.log("保存路径完成！");
		}
		
		private function reset_handle():void 
		{
			version_file = File.applicationStorageDirectory.resolvePath(VERSION_URL);
			if (version_file.exists)
			{
				version_file.deleteFile();
			}
			Log.log("重置版本完成！");
		}
		
		private static const VERSION_URL:String = "avatar/version.json";
		private var version_file:File;
		private var version_obj:Object;
		private var new_version_obj:Object;
		private static const DRESS_URL:String = "dress.json";
		private var dress_file:File;
		private var dress_obj:Object;
		private function readJson():void
		{
			version_obj = {};
			new_version_obj = {};
			version_file = File.applicationStorageDirectory.resolvePath(VERSION_URL);
			if (!version_file.exists)
			{
				Log.log("版本信息文件不存在！");
				return;
			}
			var fs:FileStream = new FileStream();
			fs.open(version_file, FileMode.READ);
			var fileStr:String = fs.readUTFBytes(fs.bytesAvailable);
			fs.close();
			version_obj = JSON.parse(fileStr);
			Log.log("读取版本信息成功！");
		}
		
		private function writeJson():void
		{
			//var fileStr:String = JSON.stringify(version_obj);
			var fileStr:String = JSON.stringify(new_version_obj);
			var fs:FileStream = new FileStream();
			fs.open(version_file, FileMode.WRITE);
			fs.writeUTFBytes(fileStr);
			fs.close();
			Log.log("写入版本信息成功！");
			//Log.log(fileStr);
		}
		
		private function readDressJson():void
		{
			dress_obj = {};
			dress_file = target_folder.resolvePath(DRESS_URL);
			if (!dress_file.exists)
			{
				Log.log("dress.json文件不存在！");
				return;
			}
			var fs:FileStream = new FileStream();
			fs.open(dress_file, FileMode.READ);
			var fileStr:String = fs.readUTFBytes(fs.bytesAvailable);
			fs.close();
			dress_obj = JSON.parse(fileStr);
			Log.log("读取dress.json成功！");
		}
		
		private function writeDressJson():void
		{
			var fileStr:String = JSON.stringify(dress_obj);
			var fs:FileStream = new FileStream();
			fs.open(dress_file, FileMode.WRITE);
			fs.writeUTFBytes(fileStr);
			fs.close();
			Log.log("写入dress.json成功！");
			//Log.log(fileStr);
		}
		
		private var origin_folder:File;
		private var target_folder:File;
		private var folder_re:RegExp = /(\d+)/;
		private var num_re:RegExp = /(\d+)/;
		private var loading_files:Array;
		private var loaded_files:Array;
		private function excute_handle():void
		{
			origin_folder = new File(origin_it.text);
			if (!origin_folder.exists)
			{
				Log.log("原始文件夹不存在！");
				MessageUtil.alert("原始文件夹不存在！");
				return;
			}
			target_folder = new File(target_it.text);
			readJson();
			if (cocos2dx_cb.selected) 
			{
				//手机端读取坐标记录json文件
				readDressJson();
			}
			getTargetFiles();
			getLoadingFiles();
			var hasDelete:Boolean = deleteOldTargetFiles();
			if (loading_files.length == 0)
			{
				if (hasDelete)
				{
					writeJson();
					if (cocos2dx_cb.selected) 
					{
						writeDressJson();
					}
				}
				Log.log("无新增或修改文件！");
				MessageUtil.alert("无新增或修改文件！");
				return;
			}
			loaded_files = [];
			imageInfoArr = [];
			loadNext();
		}
		
		private var target_file_dict:Dictionary = new Dictionary();
		//得到目标文件
		private function getTargetFiles():void
		{
			if (target_folder.exists == false)
			{
				Log.log("目标文件夹不存在，无需查找需删除文件！");
				return;
			}
			var files:Array = target_folder.getDirectoryListing();
			for each (var file:File in files)
			{
				if (file.extension == "png" || file.extension == "swf")
				{
					var fileName:String = file.name.substr(0, file.name.length - 4);
					var part:int = int(fileName.substr(2, 2));
					//012部位不处理
					//if (part != 0 && part != 1 && part != 2)
					//{
						target_file_dict[fileName] = file;
					//}
				}
			}
		}
		
		//删除旧的多余的目标文件
		private function deleteOldTargetFiles():Boolean
		{
			var has:Boolean = false;
			var isCocos2dx:Boolean = cocos2dx_cb.selected;
			var extension:String = cocos2dx_cb.selected ? "png" : "swf";
			for (var fileName:String in target_file_dict)
			{
				var file:File = target_file_dict[fileName];
				if (fileName.indexOf("default") != -1) 
				{
					//默认素材
					continue;
				}
				if (isCocos2dx && (fileName.indexOf("2000") == 0 || fileName.indexOf("2001") == 0 || fileName.indexOf("2002") == 0))
				{
					//手机端默认素材 前景特效，背景特效，背景图片
					continue;
				}
				if (!new_version_obj[fileName])
				{
					has = true;
					Log.log("删除多余文件：" + file.name);
					file.deleteFile();
					if (isCocos2dx)
					{
						delete dress_obj[file.name.substr(0, file.url.length - 4)];
						/*file = new File(file.url.substr(0, file.url.length - 3) + "json");
						if (file.exists)
						{
							Log.log("删除多余文件：" + file.name);
							file.deleteFile();
						}*/
					}
				}
			}
			if (!has)
			{
				Log.log("无多余文件可删除！");
			}
			target_file_dict = new Dictionary();
			return has;
		}
		
		//得到需要加载的文件
		private function getLoadingFiles():void
		{
			loading_files = [];
			//Svn\SmhWorld\trunk\12 交换目录\美术类\装扮类资源
			getDressLoadingFiles(origin_folder);
			//Svn\SmhWorld\trunk\12 交换目录\美术类\装扮类资源\房间装扮
			getDressLoadingFiles(origin_folder.resolvePath("房间装扮"));
			if (cocos2dx_cb.selected) 
			{
				return;
			}
			var sub_files:Array;
			var sub_file:File;
			var subName:String;
			var sub_re_obj:Object;
			var sub_id:String;
			var targetFile:File;
			//Svn\SmhWorld\trunk\12 交换目录\美术类\装扮场景
			var sceneFolder:File = origin_folder.resolvePath("装扮场景");
			sub_files = sceneFolder.getDirectoryListing();
			for each (sub_file in sub_files)
			{
				subName = sub_file.name;
				sub_re_obj = num_re.exec(subName);
				if (sub_re_obj)
				{
					//png为icon，jpg为主文件
					if (sub_file.extension == "png" || sub_file.extension == "jpg")
					{
						sub_id = subName.substr(0, subName.length - 4);
						if (filterFile(sub_file, sub_id))
						{
							Log.log("处理文件：" + "装扮场景" + "/" + subName);
							if (sub_file.extension == "jpg")
							{
								loading_files.push({url:sub_file.url, name:subName, id:sub_id, extention:sub_file.extension, part:"2", folder:sceneFolder.url});
							}
							else
							{
								targetFile = target_folder.resolvePath(subName);
								sub_file.copyTo(targetFile, true);
							}
						}
					}
				}
			}
			//Svn\SmhWorld\trunk\12 交换目录\美术类\装扮特效
			var effectFolder:File = origin_folder.resolvePath("装扮特效");
			sub_files = effectFolder.getDirectoryListing();
			for each (sub_file in sub_files)
			{
				subName = sub_file.name;
				sub_re_obj = num_re.exec(subName);
				if (sub_re_obj)
				{
					//png为icon，swf为主文件
					if (sub_file.extension == "png" || sub_file.extension == "swf")
					{
						sub_id = subName.substr(0, subName.length - 4);
						if (filterFile(sub_file, sub_id))
						{
							Log.log("处理文件：" + "装扮特效" + "/" + subName);
							targetFile = target_folder.resolvePath(subName);
							sub_file.copyTo(targetFile, true);
						}
					}
				}
			}
		}
		
		private function getDressLoadingFiles(folder:File):void
		{
			if (folder == null || !folder.isDirectory || !folder.exists) 
			{
				return;
			}
			var files:Array = folder.getDirectoryListing();
			for each (var file:File in files)
			{
				if (!file.isDirectory) 
				{
					continue;
				}
				var folderName:String = file.name;
				var re_obj:Object = folder_re.exec(folderName);
				if (re_obj == null)
				{
					continue;
				}
				var folderNum:int = int(re_obj[1]);
				var item_id:int = 200000000 + folderNum;
				var sub_files:Array = file.getDirectoryListing();
				for each (var sub_file:File in sub_files)
				{
					if (sub_file.extension == "png" || sub_file.extension == "jpg")
					{
						var subName:String = sub_file.name;
						var sub_re_obj:Object = num_re.exec(subName);
						if (sub_re_obj)
						{
							var part_str:String = sub_re_obj[0];
							var next:String = subName.charAt(part_str.length);
							var sub_id:String = (item_id + int(part_str) * 100000) + "";
							if (next == "a" || next == "b")
							{
								sub_id += next;
							}
							if (filterFile(sub_file, sub_id))
							{
								//Log.log("处理文件：" + file.name + "/" + subName);
								if (next == "a" || next == "b")
								{
									loading_files.push({url:sub_file.url, name:subName, id:sub_id, extention:sub_file.extension, part:part_str, folder:file.url});
								}
								else 
								{
									Log.log("处理文件：" + file.name + "/" + subName);
									var targetFile:File = target_folder.resolvePath(sub_id + "." + sub_file.extension);
									sub_file.copyTo(targetFile, true);
								}
							}
						}
					}
				}
			}
		}
		
		/**
		 * 过滤文件
		 * @param	file
		 * @param	id
		 * @return	true：要更新，false：不需要更新
		 */
		private function filterFile(file:File, id:String):Boolean
		{
			var ver:String = "" + file.modificationDate.time;
			new_version_obj[id] = ver;
			if (version_obj[id] == ver)
			{
				if (total_cb.selected)
				{
					return true;
				}
				return false;
			}
			//version_obj[id] = ver;
			return true;
		}
		
		private var cur_file_obj:Object;
		private var imageInfoArr:Array;
		private function loadNext():void
		{
			if (loading_files.length == 0) 
			{
				writeJson();
				if (cocos2dx_cb.selected) 
				{
					loadFinishCocos2dx();
				}
				else 
				{
					loadFinish();
				}
				return;
			}
			cur_file_obj = loading_files.shift();
			
			var loader:Loader = new Loader();
			loader.load(new URLRequest(cur_file_obj.url));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_complete);
		}
		
		private function loader_complete(e:Event):void 
		{
			var loaderInfo:LoaderInfo = e.target as LoaderInfo;
			var loader:Loader = loaderInfo.loader;
			var loader_bm:Bitmap = loader.content as Bitmap;
			//
			cur_file_obj.bmd = loader_bm.bitmapData;
			var file_obj:Object = cur_file_obj;
			Log.log("处理文件：" + file_obj.id + "." + file_obj.extention);
			//loaded_files.push(cur_file_obj);
			if (cocos2dx_cb.selected)
			{
				var extention:String = file_obj.extention;
				if (extention == "png")
				{
					var bmd:BitmapData = file_obj.bmd;
					var minRect:Rectangle = bmd.getColorBoundsRect(0xffffffff, 0x00000000, false);
					var minBmd:BitmapData = new BitmapData(minRect.width, minRect.height, true, 0);
					minBmd.copyPixels(bmd, minRect, destPoint, null, null, true);
					var url:String = target_folder.url + "/" + file_obj.id + "." + extention;
					ImageCreator.createImage(url, minBmd);
					generatorJson(file_obj.id, minRect.x, minRect.y);
				}
				else if (extention == "jpg")
				{
					var file:File = new File(file_obj.url);
					var targetFile:File = target_folder.resolvePath(file_obj.id + "." + extention);
					file.copyTo(targetFile, true);
					generatorJson(file_obj.id, 0, 0);
				}
			}
			else 
			{
				if (file_obj.extention == "png")
				{
					bmd = file_obj.bmd;
					minRect = bmd.getColorBoundsRect(0xffffffff, 0x00000000, false);
					minBmd = new BitmapData(minRect.width, minRect.height, true, 0);
					minBmd.copyPixels(bmd, minRect, destPoint, null, null, true);
					ImageCreator.createImage(file_obj.folder + "/" + file_obj.id, minBmd);
					var imageInfo:String = "{name:\"" + file_obj.id + "\",folder:\"" + file_obj.folder + "\",x:" + minRect.x + ",y:" + minRect.y + ",quality:" + int(imageQuality_it.text) + "}";
				}
				else 
				{
					file = new File(file_obj.url);
					var copy_file:File = new File(file_obj.folder + "/" + file_obj.id);
					file.copyTo(copy_file, true);
					imageInfo = "{name:\"" + file_obj.id + "\",folder:\"" + file_obj.folder + "\",x:" + 0 + ",y:" + 0 + ",quality:" + int(imageQuality_it.text) + "}";
				}
				imageInfoArr.push(imageInfo);
			}
			file_obj.bmd.dispose();
			file_obj.bmd = null;
			loaderInfo.removeEventListener(Event.COMPLETE, loader_complete);
			loader.unload();
			//
			//loadNext();
			setTimeout(loadNext, 30);
		}
		
		private var destPoint:Point = new Point();
		//文件夹内图片全部加载完成
		private function loadFinish():void
		{
			var targetFolder:String = target_folder.url;
			var imagesInfo:String = "[" + imageInfoArr.join(",") + "]";
			ExternalManager.callAvatarJsfl( { targetFolder:targetFolder, imagesInfo:imagesInfo } );
			Log.log("处理完成，等待Flash打包资源完毕！");
			MessageUtil.alert("处理完成，等待Flash打包资源完毕！");
		}
		
		//==============================Cocos2d-x功能=================================
		private function loadFinishCocos2dx():void
		{
			writeDressJson();
			Log.log("处理完成！");
			MessageUtil.alert("处理完成！");
		}
		
		private function generatorJson(name:String, x:int, y:int):void
		{
			dress_obj[name] = { x:x, y:y };
			/*var url:String = target_folder.url + "/" + name + ".json";
			var str:String = "[{\"x\":" + x + ",\"y\":" + y + "}]";
			var fs:FileStream = new FileStream();
			var file:File = new File(url);
			fs.open(file, FileMode.WRITE);
			fs.writeUTFBytes(str);
			fs.close();*/
		}
	}
}