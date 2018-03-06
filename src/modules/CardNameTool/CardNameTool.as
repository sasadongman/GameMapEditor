package modules.CardNameTool
{
	import flash.filesystem.File;
	import modules.IPage;
	import morn.CardNameToolUI;
	import morn.core.handlers.Handler;
	import utils.FlashCookie;
	import utils.FlashCookieConst;
	
	/**
	 * ...
	 * @author hypo.chen
	 */
	public class CardNameTool extends CardNameToolUI implements IPage
	{
		
		public function CardNameTool()
		{
			super();
			
			if (FlashCookie.getValue(FlashCookieConst.CARD_NAME_ORIGIN) != null)
			{
				origin_it.text = FlashCookie.getValue(FlashCookieConst.CARD_NAME_ORIGIN);
			}
			else
			{
				FlashCookie.setValue(FlashCookieConst.CARD_NAME_ORIGIN, origin_it.text);
			}
			if (FlashCookie.getValue(FlashCookieConst.CARD_NAME_TARGET) != null)
			{
				target_it.text = FlashCookie.getValue(FlashCookieConst.CARD_NAME_TARGET);
			}
			else
			{
				FlashCookie.setValue(FlashCookieConst.CARD_NAME_TARGET, target_it.text);
			}
			
			save_btn.clickHandler = new Handler(save_handle);
			excute_btn.clickHandler = new Handler(excute_handle);
		}
		
		/**
		 * 日志
		 */
		public function transIn():void
		{
			Log.log("操作步骤：");
			Log.log("1.确认原始文件夹和目标文件夹路径，如有改变点击“保存”");
			Log.log("2.点击“处理”按钮等待处理完成");
		}
		
		public function transOut():void
		{
			
		}
		
		/**
		 * 保存目录
		 */
		private function save_handle():void
		{
			FlashCookie.setValue(FlashCookieConst.CARD_NAME_ORIGIN, origin_it.text);
			FlashCookie.setValue(FlashCookieConst.CARD_NAME_TARGET, target_it.text);
			Log.log("保存路径完成！");
		}
		
		/**
		 * 处理
		 */
		private var origin_folder:File;
		private var target_folder:File;
		
		private function excute_handle():void
		{
			origin_folder = new File(origin_it.text);
			if (!origin_folder.exists)
			{
				Log.log("原始文件夹不存在！");
				return;
			}
			target_folder = new File(target_it.text);
			get_target_file();
			delete_old_image();
			get_handle_bigCard();
			get_handle_smallCard();
		}
		
		/**
		 * 得到目标文件
		 */
		private var all_old_file:Array = [];
		
		private function get_target_file():void
		{
			if (!target_folder.exists)
			{
				Log.log("目标文件夹不存在！");
				return;
			}
			var files:Array = target_folder.getDirectoryListing();
			get_folder_image(files, all_old_file);
		}
		
		/**
		 * 删除所有老文件
		 */
		private function delete_old_image():void 
		{
			for each (var item:File in all_old_file) 
			{
				item.deleteFile();
			}
			Log.log("删除目标文件夹中以前的文件！");
		}
		
		/**
		 * 获取待处理的大卡牌
		 */
		private var all_bigcard_image:Array = [];
		
		private function get_handle_bigCard():void
		{
			//卡牌文件夹【E:\Projects\SmhWorld\trunk\12 交换目录\美术类\卡牌类资源\卡牌新（大）】
			var cardFolder:File = origin_folder.resolvePath("卡牌新（大）");
			var sub_files:Array = cardFolder.getDirectoryListing();
			get_folder_image(sub_files, all_bigcard_image);
			copyTo_target_folder(0);
		}
		
		/**
		 * 获取待处理的小卡牌
		 *
		 */
		private var all_smallcard_image:Array = [];
		
		private function get_handle_smallCard():void
		{
			var cardFolder:File = origin_folder.resolvePath("卡牌新（小）");
			var sub_files:Array = cardFolder.getDirectoryListing();
			get_folder_image(sub_files, all_smallcard_image);
			copyTo_target_folder(1);
		}
		
		/**
		 * 获取一个文件夹下面的所有图片
		 * @param	sub_files 文件夹下的所有图片
		 * @param	store_arr 存储图片的数组
		 */
		private function get_folder_image(sub_files:Array, store_arr:Array):void
		{
			for each (var item:File in sub_files)
			{
				if (!item.isDirectory)
				{
					//把此文件夹下面所有的图片检索出来
					if (item.extension == "png")
					{
						store_arr.push(item);
					}
				}
				else
				{
					//文件夹
					var sub_file:Array = item.getDirectoryListing();
					get_folder_image(sub_file, store_arr);
				}
			}
		}
		
		/**
		 * 将卡牌图片拷贝到目标文件夹
		 */
		private function copyTo_target_folder(type:int):void
		{
			var url:String;
			var _target_folder:File;
			var _sub_image:File;
			if (type == 0)
			{
				//大卡牌
				url = "big";
				_target_folder = target_folder.resolvePath(url);
				for each (_sub_image in all_bigcard_image)
				{
					var _bigCard_id:int = int(_sub_image.name.substr(0, 3));
					var _bigCard_name:String;
					if ((_sub_image.name.split(".png")[0] as String).indexOf("-1") == -1)
					{
						_bigCard_name = _bigCard_id + "." + _sub_image.extension;
					}
					else
					{
						_bigCard_name = _bigCard_id + "a" + "." + _sub_image.extension;
					}
					var _bigCard_targetFile:File = _target_folder.resolvePath(_bigCard_name);
					_sub_image.copyTo(_bigCard_targetFile, true);
				}
				Log.log("大卡牌处理完毕！");
			}
			else
			{
				//小卡牌
				url = "icon";
				_target_folder = target_folder.resolvePath(url);
				for each (_sub_image in all_smallcard_image)
				{
					var _smallCard_id:int = int(_sub_image.name.substr(0, 3));
					var _smallCard_name:String = _smallCard_id + "." + _sub_image.extension;
					var _smallCard_targetFile:File = _target_folder.resolvePath(_smallCard_name);
					_sub_image.copyTo(_smallCard_targetFile, true);
				}
				Log.log("小卡牌处理完毕！");
			}
			
		}
	}

}