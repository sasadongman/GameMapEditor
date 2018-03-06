package 
{
	import smh.model.resource.staticConfig.StaticConfigDataBase;
	/**
	 * ...
	 * @author Alex
	 */
	public class GlobalConst 
	{
		public static const AvatarTool:int = 0;
		public static const AvatarNameTool:int = 1;
		public static const AnimationTool:int = 2;
		public static const ClipTool:int = 3;
		public static const ProtoTool:int = 4;
		public static const EnumTool:int = 5;
		public static const VersionTool:int = 6;
		public static const AvatarBatchTool:int = 7;
		public static const CardNameTool:int = 8;
		public static const CutTool:int = 9;
		public static const ComicsTool:int = 10;
		public static const CardBatchTool:int = 11;
		public static const DataBaseTool:int = 12;
		public static const MapEditor:int = 13;
		public static const ImageCompress:int = 14;
		public static const ImageAddSpace:int = 15;
		public static const DataBaseBatchTool:int = 16;
		
		public static var TAB_NAMES:Array = ["装扮打包", "顺序命名", "动画工具", "Clip工具", "Proto生成", "Enum转换", "版本更新", "装扮打包", "卡牌命名", "png裁剪", "漫画裁剪", "卡牌截图", "type表导出", "地图编辑", "图片压缩", "NPC图片处理", "type批处理"];
		
		public static var TAB_LIST:Array = [
											[AvatarBatchTool, CardNameTool, CardBatchTool, AnimationTool, ComicsTool, ClipTool, CutTool, ImageCompress, ImageAddSpace, MapEditor, ProtoTool, EnumTool, DataBaseBatchTool, VersionTool],
											[AvatarBatchTool, CardNameTool, AnimationTool, ComicsTool, ClipTool, CutTool, ImageCompress, ImageAddSpace, MapEditor, ProtoTool, EnumTool, VersionTool],
											[AvatarBatchTool, AnimationTool, MapEditor],
											[AnimationTool, ComicsTool, MapEditor],
											[MapEditor]
											];
		
		//权限控制
		public static const PERMISSION_ADMIN:int = 0;
		public static const PERMISSION_FLASH:int = 1;
		public static const PERMISSION_COCOS:int = 2;
		public static const PERMISSION_ART:int = 3;
		public static const PERMISSION_DESIGN:int = 4;
		
		//当前权限
		public static var permission:int;
		
		public static var permission_arr:Array = ["管理员", "Flash", "Cocos", "美术", "策划"];
		
		private static var _staticConfigDataBase:StaticConfigDataBase;
		/**
		 * 静态配置数据库
		 */
		public static function get staticConfigDataBase():StaticConfigDataBase
		{
			if (!_staticConfigDataBase) 
			{
				_staticConfigDataBase = new StaticConfigDataBase();
			}
			return _staticConfigDataBase;
		}
		
		public function GlobalConst() 
		{
		}
	}
}