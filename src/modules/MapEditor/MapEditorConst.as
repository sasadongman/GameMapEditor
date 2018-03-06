package modules.MapEditor 
{
	import flash.geom.Point;
	/**
	 * ...
	 * @author Alex
	 */
	public class MapEditorConst 
	{
		/**
		 * 交错
		 */
		public static const DEFAULT_CROSS:Boolean = false;
		public static var CROSS:Boolean = false;
		
		/**
		 * 列数
		 */
		public static const DEFAULT_WIDTH:int = 20;
		public static var WIDTH:int;
		/**
		 * 行数
		 */
		public static const DEFAULT_HEIGHT:int = 20;
		public static var HEIGHT:int;
		/**
		 * 砖块宽度
		 */
		public static const DEFAULT_TILE_WIDTH:int = 88;
		public static var TILE_WIDTH:int;
		/**
		 * 砖块高度
		 */
		public static const DEFAULT_TILE_HEIGHT:int = 44;
		public static var TILE_HEIGHT:int;
		
		/**
		 * 图层-路点
		 */
		public static const LAYER_POINT:int = 0;
		/**
		 * 图层-地上
		 */
		public static const LAYER_UP:int = 1;
		/**
		 * 图层-地表
		 */
		public static const LAYER_GROUND:int = 2;
		/**
		 * 图层-地下
		 */
		public static const LAYER_DOWN:int = 3;
		
		public function MapEditorConst() 
		{
		}
		
		/**
		 * 总宽度
		 */
		public static function get TOTAL_WIDTH():int
		{
			if (CROSS) 
			{
				return TILE_WIDTH * (WIDTH + 0.5);
			}
			else 
			{
				return TILE_WIDTH * (WIDTH + HEIGHT) * 0.5;
			}
		}
		
		/**
		 * 总高度
		 */
		public static function get TOTAL_HEIGHT():int
		{
			if (CROSS) 
			{
				return TILE_HEIGHT * (HEIGHT + 1) * 0.5;
			}
			else 
			{
				return TILE_HEIGHT * (WIDTH + HEIGHT) * 0.5;
			}
		}
		
		/**
		 * 根据屏幕象素坐标取得网格的坐标
		 * @param	px
		 * @param	py
		 * @return
		 */
		public static function getCellPoint(px:int, py:int):Point
		{
			if (CROSS) 
			{
				var xtile:int = 0;	//网格的x坐标
				var ytile:int = 0;	//网格的y坐标
				
				var cx:int, cy:int, rx:int, ry:int;
				cx = Math.floor(px / TILE_WIDTH) * TILE_WIDTH + TILE_WIDTH/2;	//计算出当前X所在的以TILE_WIDTH为宽的矩形的中心的X坐标
				cy = Math.floor(py / TILE_HEIGHT) * TILE_HEIGHT + TILE_HEIGHT / 2;//计算出当前Y所在的以TILE_HEIGHT为高的矩形的中心的Y坐标
				
				rx = (px - cx) * TILE_HEIGHT/2;
				ry = (py - cy) * TILE_WIDTH / 2;
				
				if (Math.abs(rx)+Math.abs(ry) <= TILE_WIDTH * TILE_HEIGHT/4)
				{
					//xtile = Math.floor(pixelPoint.x / TILE_WIDTH) * 2;
					xtile = Math.floor(px / TILE_WIDTH);
					ytile = Math.floor(py / TILE_HEIGHT) * 2;
				}
				else
				{
					px = px - TILE_WIDTH/2;
					//xtile = Math.floor(pixelPoint.x / TILE_WIDTH) * 2 + 1;
					xtile = Math.floor(px / TILE_WIDTH) + 1;
					
					py = py - TILE_HEIGHT/2;
					ytile = Math.floor(py / TILE_HEIGHT) * 2 + 1;
				}
				return new Point(xtile - (ytile&1), ytile);
			}
			else 
			{
				px -= HEIGHT * TILE_WIDTH * 0.5;
				var tx:int = Math.floor(py / TILE_HEIGHT + px / TILE_WIDTH);
				var ty:int = Math.floor(py / TILE_HEIGHT - px / TILE_WIDTH);
				return new Point(tx, ty);
			}
		}
		
		/**
		 * 根据网格坐标取得象素坐标
		 * @param	tx
		 * @param	ty
		 * @return
		 */
		public static function getPixelPoint(tx:int, ty:int):Point
		{
			if (CROSS)
			{
				//偶数行tile中心
				var tileCenter:int = (tx * TILE_WIDTH) + TILE_WIDTH/2;
				// x象素  如果为奇数行加半个宽
				var xPixel:int = tileCenter + (ty&1) * TILE_WIDTH/2;
				// y象素
				var yPixel:int = (ty + 1) * TILE_HEIGHT/2;
				return new Point(xPixel, yPixel);
			}
			else 
			{
				//var px:int = Math.floor((tx - ty + HEIGHT - 1) * TILE_WIDTH * 0.5);
				//var py:int = Math.floor((tx + ty) * TILE_HEIGHT * 0.5);
				var px:int = Math.floor((tx - ty + HEIGHT) * TILE_WIDTH * 0.5);
				var py:int = Math.floor((tx + ty + 1) * TILE_HEIGHT * 0.5);
				return new Point(px, py);
			}
		}
		
		/**
		 * 得到网格坐标的索引值
		 * @param	x
		 * @param	y
		 * @return
		 */
		public static function getPointIndex(x:int, y:int):int
		{
			if (CROSS)
			{
				return WIDTH * y + WIDTH - x;
			}
			else 
			{
				return WIDTH * y + x;
			}
		}
	}
}