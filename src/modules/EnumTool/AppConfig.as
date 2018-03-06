package modules.EnumTool
{
	/**
	 * @author: hypo.chen
	 * @E-mail: 645338868@qq.com
	 * @create: 2015-10-26 上午10:43:08
	 *
	 */
	public class AppConfig
	{
		public static const STATIC_CONFIG_ROOT:String = "xml/";
		public static const PACKAGE:String = "package";
		public static const VAR_SIGN:String = "public static const ";
		public static const VAR_TYPE:String = "int";
		
		public static var constructorName:String;
		public static var packageName:String;
		public static var ROOT_URL:String;
		public static var SAVE_URL:String;

		public static var varDataGroup:Array = new Array();
		public static var varGroup:Array = new Array();
		public static var varName:Array = new Array();
		public static var varVaule:Array = new Array();
		public static var varItemGroup:Array = new Array();
		public static var noteGroup:Array = new Array();
		public static var classNameArr:Array = new Array();
		public static var FILES:Array = ["enum_config.xml"];
		
		public static var className:String;
		
		public static var fileName:Array = new Array();
		public static var packageURL:Array = new Array();
		public static var fileURL:Array = new Array();
		public static var saveURL:Array = new Array();

		public function AppConfig()
		{
		}
	}
}