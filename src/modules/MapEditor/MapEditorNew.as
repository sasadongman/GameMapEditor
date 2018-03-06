package modules.MapEditor 
{
	import flash.events.Event;
	import morn.mapEditor.MapEditorNewUI;
	
	/**
	 * ...
	 * @author Alex
	 */
	public class MapEditorNew extends MapEditorNewUI 
	{
		private var _isNew:Boolean;
		public function MapEditorNew() 
		{
			super();
			cross_cb.addEventListener(Event.SELECT, updateTotal);
			width_ti.addEventListener(Event.CHANGE, updateTotal);
			height_ti.addEventListener(Event.CHANGE, updateTotal);
			tileWidth_ti.addEventListener(Event.CHANGE, updateTotal);
			tileHeight_ti.addEventListener(Event.CHANGE, updateTotal);
		}
		
		/**
		 * 设置数据
		 * @param	isNew
		 * @param	fileName
		 */
		public function setData(isNew:Boolean, fileName:String = null):void
		{
			_isNew = isNew;
			cross_cb.disabled = !_isNew;
			if (_isNew) 
			{
				name_lb.text = "新地图";
				cross_cb.selected = MapEditorConst.DEFAULT_CROSS;
				width_ti.text = "" + MapEditorConst.DEFAULT_WIDTH;
				height_ti.text = "" + MapEditorConst.DEFAULT_HEIGHT;
				tileWidth_ti.text = "" + MapEditorConst.DEFAULT_TILE_WIDTH;
				tileHeight_ti.text = "" + MapEditorConst.DEFAULT_TILE_HEIGHT;
			}
			else 
			{
				name_lb.text = fileName;
				cross_cb.selected = MapEditorConst.CROSS;
				width_ti.text = "" + MapEditorConst.WIDTH;
				height_ti.text = "" + MapEditorConst.HEIGHT;
				tileWidth_ti.text = "" + MapEditorConst.TILE_WIDTH;
				tileHeight_ti.text = "" + MapEditorConst.TILE_HEIGHT;
			}
			updateTotal();
		}
		
		public function get isNew():Boolean 
		{
			return _isNew;
		}
		
		private function updateTotal(e:Event = null):void
		{
			if (cross_cb.selected) 
			{
				total_lb.text = int(int(tileWidth_ti.text) * (int(width_ti.text) + 0.5)) + " x " + int(int(height_ti.text) * (int(tileHeight_ti.text) + 1) * 0.5) + " 像素点";
			}
			else 
			{
				total_lb.text = int(int(tileWidth_ti.text) * (int(width_ti.text) + int(height_ti.text)) * 0.5) + " x " + int(int(tileHeight_ti.text) * (int(width_ti.text) + int(height_ti.text)) * 0.5) + " 像素点";
			}
		}
	}
}