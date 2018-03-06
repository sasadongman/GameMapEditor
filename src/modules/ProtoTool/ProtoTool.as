package modules.ProtoTool 
{
	import adobe.utils.CustomActions;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import modules.IPage;
	import morn.core.handlers.Handler;
	import morn.ProtoToolUI;
	import utils.FlashCookie;
	import utils.FlashCookieConst;
	
	/**
	 * ...
	 * @author Alex
	 */
	public class ProtoTool extends ProtoToolUI implements IPage
	{
		//public static var PACKAGE_NAME:String = "smh.service.socket.proto";
		public static var AS3_OUT_FOLDER:String = "as3_out";
		//public static var PLUGIN_URL:String = "\\as_plugin\\protoc-gen-as3.bat";
		public static var AS_PLUGIN_FOLDER:String = "as_plugin";
		public static var PROTOC_EXE_FILE:String = "protoc.exe";
		public static var GEN_CMD_URL:String = "_gen_as3.cmd";
		
		private var proto_server_folder:File;
		private var proto_as3_folder:File;
		private var proto_laya_folder:File;
		
		public function ProtoTool() 
		{
			super();
			if (FlashCookie.getValue(FlashCookieConst.PROTO_SERVER) != null)
			{
				server_it.text = FlashCookie.getValue(FlashCookieConst.PROTO_SERVER);
			}
			else 
			{
				FlashCookie.setValue(FlashCookieConst.PROTO_SERVER, server_it.text);
			}
			if (FlashCookie.getValue(FlashCookieConst.PROTO_AS3) != null)
			{
				as3_it.text = FlashCookie.getValue(FlashCookieConst.PROTO_AS3);
			}
			else 
			{
				FlashCookie.setValue(FlashCookieConst.PROTO_AS3, as3_it.text);
			}
			if (FlashCookie.getValue(FlashCookieConst.PROTO_LAYA) != null)
			{
				laya_it.text = FlashCookie.getValue(FlashCookieConst.PROTO_LAYA);
			}
			else 
			{
				FlashCookie.setValue(FlashCookieConst.PROTO_LAYA, laya_it.text);
			}
			proto_server_folder = new File(server_it.text);
			proto_as3_folder = new File(as3_it.text);
			proto_laya_folder = new File(laya_it.text);
			
			//checkProtoFolder();
			
			record_btn.clickHandler = new Handler(record_btn_click);
			//
			if (NativeProcess.isSupported) 
			{
				cmd_btn.visible = false;
				as_btn.visible = false;
				excute_btn.clickHandler = new Handler(excute_handle);
			}
			else 
			{
				excute_btn.visible = false;
				cmd_btn.clickHandler = new Handler(cmd_btn_click);
				as_btn.clickHandler = new Handler(as_btn_click);
			}
		}
		
		public function transIn():void
		{
			checkProtoFolder();
			Log.log("是否支持本地应用程序:" + NativeProcess.isSupported);
			if (NativeProcess.isSupported) 
			{
				Log.log("点击“执行”按钮等待完成！");
			}
			else 
			{
				Log.log("1.点击“生成_gen_as3.cmd”按钮");
				Log.log("2.双击“_gen_as3.cmd”");
				Log.log("3.点击“转移.as”按钮");
			}
		}
		
		public function transOut():void
		{
			
		}
		
		private function record_btn_click():void
		{
			FlashCookie.setValue(FlashCookieConst.PROTO_SERVER, server_it.text);
			FlashCookie.setValue(FlashCookieConst.PROTO_AS3, as3_it.text);
			FlashCookie.setValue(FlashCookieConst.PROTO_LAYA, laya_it.text);
			proto_server_folder = new File(server_it.text);
			proto_as3_folder = new File(as3_it.text);
			proto_laya_folder = new File(laya_it.text);
		}
		
		//private var as_plugin_folder:File;
		private var protoc_exe_file:File;
		private function checkProtoFolder():void
		{
			var as_plugin_folder:File = proto_server_folder.resolvePath(AS_PLUGIN_FOLDER);
			if (!as_plugin_folder.exists)
			{
				var app_as_plugin_folder:File = File.applicationDirectory.resolvePath("proto/" + AS_PLUGIN_FOLDER);
				app_as_plugin_folder.copyTo(as_plugin_folder);
			}
			protoc_exe_file = proto_server_folder.resolvePath(PROTOC_EXE_FILE);
			if (!protoc_exe_file.exists) 
			{
				var app_protoc_exe_file:File = File.applicationDirectory.resolvePath("proto/" + PROTOC_EXE_FILE);
				app_protoc_exe_file.copyTo(protoc_exe_file);
			}
		}
		
		private var as3_out_folder:File;
		private var gen_str:String;
		//-----------------------------------------生成.cmd文件并使用默认打开的方式-------------------------------------------
		private function cmd_btn_click():void 
		{
			as3_out_folder = proto_server_folder.resolvePath(AS3_OUT_FOLDER);
			if (as3_out_folder.exists) 
			{
				as3_out_folder.deleteDirectory(true);
			}
			as3_out_folder.createDirectory();
			
			gen_str = "";
			gen_str += server_it.text.charAt(0) + ":";
			gen_str += "\ncd \"" + server_it.text + "\"";
			gen_str += "\nprotoc.exe --plugin=protoc-gen-as3=as_plugin\\protoc-gen-as3.bat --as3_out=as3_out";
			//var gen_str:String = EXE_URL + " --plugin=protoc-gen-as3=" + PLUGIN_URL + " --as3_out=" + AS3_OUT_FOLDER;
			
			var files:Array = proto_server_folder.getDirectoryListing();
			for each (var file:File in files)
			{
				if (file.extension == "txt")
				{
					gen_str += " " + file.name;
				}
			}
			//gen_str += "\n pause";
			
			var cmd_file:File = proto_server_folder.resolvePath(GEN_CMD_URL);
			var fs:FileStream = new FileStream();
			var data:ByteArray = new ByteArray();
			//构造一个UTF8的BOM，即3个字节分别是EF BB BF的二进制文件
			//data.writeByte(0xEF);
			//data.writeByte(0xBB);
			//data.writeByte(0xBF);
			
			data.writeMultiByte(gen_str, "gb2312");
			
			fs.open(cmd_file, FileMode.WRITE);
			fs.writeBytes(data);
			fs.close();
			
			Log.log("生成_gen_as3.cmd成功！");
			
			try 
			{
				Log.log("尝试自动打开_gen_as3.cmd");
				cmd_file.openWithDefaultApplication();
			}
			catch (e:*)
			{
				Log.log(e);
				Log.log("打开失败，打开文件夹双击执行！");
				proto_server_folder.openWithDefaultApplication();
			}
		}
		//-----------------------------------------使用程序直接调用cmd.exe并传入参数的方式-------------------------------------------
		private var gen_arr:Array;
		private function excute_handle():void
		{
			as3_out_folder = proto_server_folder.resolvePath(AS3_OUT_FOLDER);
			if (as3_out_folder.exists) 
			{
				as3_out_folder.deleteDirectory(true);
			}
			as3_out_folder.createDirectory();
			
			var last_str:String = "protoc.exe --plugin=protoc-gen-as3=as_plugin\\protoc-gen-as3.bat --as3_out=as3_out";
			var files:Array = proto_server_folder.getDirectoryListing();
			for each (var file:File in files)
			{
				if (file.extension == "txt")
				{
					last_str += " " + file.name;
				}
			}
			gen_arr = [];
			gen_arr.push(server_it.text.charAt(0) + ":");
			gen_arr.push("cd \"" + server_it.text + "\"");
			gen_arr.push(last_str);
			
			//var args:Vector.<String> = new Vector.<String>();
			//args.push("--plugin=protoc-gen-as3=as_plugin\\protoc-gen-as3.bat");
			//args.push("--as3_out=as3_out");
			//args.push("--proto_path=txt");
			//args.push("album.txt");
			
			var npsi:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			//npsi.executable = protoc_exe_file;
			//npsi.arguments = args;
			npsi.executable = new File("C:\\Windows\\System32\\cmd.exe");
			
			Log.log("是否支持本地应用程序:" + NativeProcess.isSupported);
			var nativeProcess:NativeProcess = new NativeProcess();
			addProcessEventListeners(nativeProcess);
			standardOutputTimes = 0;
			Log.log("调用cmd.exe处理proto文件转换！");
			nativeProcess.start(npsi);
		}
		
		private function addProcessEventListeners(nativeProcess:NativeProcess):void
		{
			nativeProcess.addEventListener(NativeProcessExitEvent.EXIT, nativeProcess_exit);
			nativeProcess.addEventListener(Event.STANDARD_ERROR_CLOSE, nativeProcess_standardErrorClose);
			nativeProcess.addEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, nativeProcess_standardErrorIoError);
			nativeProcess.addEventListener(ProgressEvent.STANDARD_ERROR_DATA, nativeProcess_standardErrorData);
			nativeProcess.addEventListener(Event.STANDARD_INPUT_CLOSE, nativeProcess_standardInputClose);
			nativeProcess.addEventListener(IOErrorEvent.STANDARD_INPUT_IO_ERROR, nativeProcess_standardInputIoError);
			nativeProcess.addEventListener(ProgressEvent.STANDARD_INPUT_PROGRESS, nativeProcess_standardInputProgress);
			nativeProcess.addEventListener(Event.STANDARD_OUTPUT_CLOSE, nativeProcess_standardOutputClose);
			nativeProcess.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, nativeProcess_standardOutputData);
			nativeProcess.addEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, nativeProcess_standardOutputIoError);
		}
		
		private function removeProcessEventListeners(nativeProcess:NativeProcess):void
		{
			nativeProcess.removeEventListener(NativeProcessExitEvent.EXIT, nativeProcess_exit);
			nativeProcess.removeEventListener(Event.STANDARD_ERROR_CLOSE, nativeProcess_standardErrorClose);
			nativeProcess.removeEventListener(IOErrorEvent.STANDARD_ERROR_IO_ERROR, nativeProcess_standardErrorIoError);
			nativeProcess.removeEventListener(ProgressEvent.STANDARD_ERROR_DATA, nativeProcess_standardErrorData);
			nativeProcess.removeEventListener(Event.STANDARD_INPUT_CLOSE, nativeProcess_standardInputClose);
			nativeProcess.removeEventListener(IOErrorEvent.STANDARD_INPUT_IO_ERROR, nativeProcess_standardInputIoError);
			nativeProcess.removeEventListener(ProgressEvent.STANDARD_INPUT_PROGRESS, nativeProcess_standardInputProgress);
			nativeProcess.removeEventListener(Event.STANDARD_OUTPUT_CLOSE, nativeProcess_standardOutputClose);
			nativeProcess.removeEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, nativeProcess_standardOutputData);
			nativeProcess.removeEventListener(IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, nativeProcess_standardOutputIoError);
		}
		
		private function nativeProcess_exit(e:NativeProcessExitEvent):void 
		{
			//Log.log(e);
			removeProcessEventListeners(e.target as NativeProcess);
			as_btn_click();
		}
		private function nativeProcess_standardErrorClose(e:Event):void 
		{
			//Log.log(e);
		}
		private function nativeProcess_standardErrorIoError(e:IOErrorEvent):void 
		{
			//Log.log(e);
		}
		private function nativeProcess_standardErrorData(e:ProgressEvent):void 
		{
			//Log.log(e);
			var nativeProcess:NativeProcess = e.target as NativeProcess;
			//var data:String = nativeProcess.standardError.readUTFBytes(nativeProcess.standardError.bytesAvailable);
			var data:String = nativeProcess.standardError.readMultiByte(nativeProcess.standardError.bytesAvailable, "gb2312");
			//Log.log(data);
		}
		private function nativeProcess_standardInputClose(e:Event):void 
		{
			//Log.log(e);
		}
		private function nativeProcess_standardInputIoError(e:IOErrorEvent):void 
		{
			//Log.log(e);
		}
		private function nativeProcess_standardInputProgress(e:ProgressEvent):void 
		{
			//Log.log(e);
		}
		private function nativeProcess_standardOutputClose(e:Event):void 
		{
			//Log.log(e);
		}
		private var standardOutputTimes:int = 0;
		private function nativeProcess_standardOutputData(e:ProgressEvent):void 
		{
			//Log.log(e);
			var nativeProcess:NativeProcess = e.target as NativeProcess;
			//var data:String = nativeProcess.standardOutput.readUTFBytes(nativeProcess.standardOutput.bytesAvailable);
			var data:String = nativeProcess.standardOutput.readMultiByte(nativeProcess.standardOutput.bytesAvailable, "gb2312");
			Log.log(data);
			//
			if (++standardOutputTimes == 7)
			{
				Log.log("proto文件转换完成，关闭cmd.exe！");
				nativeProcess.exit();
				return;
			}
			//
			if (gen_arr == null) 
			{
				return;
			}
			var str:String = gen_arr.shift();
			nativeProcess.standardInput.writeMultiByte(str + "\n", "gb2312");
			if (gen_arr.length == 0) 
			{
				gen_arr = null;
			}
		}
		private function nativeProcess_standardOutputIoError(e:IOErrorEvent):void 
		{
			//Log.log(e);
		}
		
		private function as_btn_click():void 
		{
			var asFileCount:int;
			var files:Array = as3_out_folder.getDirectoryListing();
			var file:File;
			var as3_socket_cb_selected:Boolean = as3_socket_cb.selected;
			if (laya_socket_cb.selected)
			{
				for each (file in files)
				{
					if (file.extension == "as")
					{
						var fs:FileStream = new FileStream();
						fs.open(file, FileMode.READ);
						var fileStr:String = fs.readUTFBytes(fs.bytesAvailable)
						fs.close();
						
						fileStr = transToLaya(fileStr);
						
						fs = new FileStream();
						var laya_file:File = proto_laya_folder.resolvePath(file.name);
						fs.open(laya_file, FileMode.WRITE);
						fs.writeUTFBytes(fileStr);
						fs.close();
						
						if (!as3_socket_cb_selected) 
						{
							file.deleteFile();
						}
						
						asFileCount++;
					}
				}
				Log.log("生成Laya.as文件完成！总共转移文件数：" + asFileCount);
			}
			if (as3_socket_cb.selected) 
			{
				asFileCount = 0;
				for each (file in files)
				{
					if (file.extension == "as")
					{
						var move_file:File = proto_as3_folder.resolvePath(file.name);
						file.moveTo(move_file, true);
						
						asFileCount++;
						
						/*var fs:FileStream = new FileStream();
						fs.open(file, FileMode.READ);
						var fileStr:String = fs.readUTFBytes(fs.bytesAvailable)
						fileStr = fileStr.replace("package", "package " + PACKAGE_NAME);
						
						var data:ByteArray = new ByteArray();
						//构造一个UTF8的BOM，即3个字节分别是EF BB BF的二进制文件
						//data.writeByte(0xEF);
						//data.writeByte(0xBB);
						//data.writeByte(0xBF);
						
						data.writeUTFBytes(fileStr);
						fs.close();
						
						var move_file:File = new File(AS3_MOVE_FOLDER + "\\" + file.name);
						fs.open(move_file, FileMode.WRITE);
						//fs.truncate();
						fs.writeBytes(data);
						fs.close();*/
					}
				}
				Log.log("转移Flash.as文件完成！总共转移文件数：" + asFileCount);
			}
		}
		
		//文本替换数组
		private static var TRANS_ARR:Array = 
		[
			{ p:/import com.netease.protobuf.*;/, repl:"/*[IF-FLASH]*/import flash.utils.ByteArray;\n\timport com.netease.protobuf.*;" },
			{ p:/use namespace com.netease.protobuf.used_by_generated_code;\n\t/, repl:"" },
			{ p:/import flash.utils.Endian;\n\t/, repl:"" },
			{ p:/import flash.utils.IDataInput;\n\t/, repl:"" },
			{ p:/import flash.utils.IDataOutput;\n\t/, repl:"" },
			{ p:/import flash.utils.IExternalizable;\n\t/, repl:"" },
			{ p:/import flash.errors.IOError;\n\t/, repl:"" },
			{ p:/com.netease.protobuf.used_by_generated_code/g, repl:"public" },
			{ p:/flash.utils.IDataInput/g, repl:"ByteArray" },
			{ p:/flash.utils.IDataOutput/g, repl:"ByteArray" },
			{ p:/flash.errors.IOError/g, repl:"Error" },
			{ p:/\[ArrayElementType/g, repl:"/*[IF-FLASH]*/[ArrayElementType" }
		]
		
		//转换成Laya代码
		private function transToLaya(str:String):String
		{
			for each (var tran_data:Object in TRANS_ARR) 
			{
				str = str.replace(tran_data.p, tran_data.repl);
			}
			return str;
		}
	}
}