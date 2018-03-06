package modules.MapEditor 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.net.FileFilter;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import modules.IKeyboardPage;
	import morn.MapEditorUI;
	import morn.core.components.Box;
	import morn.core.components.Image;
	import morn.core.components.Label;
	import morn.core.handlers.Handler;
	import utils.FlashCookie;
	import utils.FlashCookieConst;
	import utils.MessageUtil;
	import utils.TxtGenerator;
	
	/**
	 * ...
	 * @author Alex
	 */
	public class MapEditor extends MapEditorUI implements IKeyboardPage
	{
		private var newPage:MapEditorNew;
		//
		private var cut_box:Sprite;		//裁剪层
		private var point_box:Sprite;	//路点层
		private var grid_bm:Bitmap;		//网格层
		private var up_box:Sprite;		//地上层
		private var ground_box:Sprite;	//地面层
		private var down_box:Sprite;	//地下层
		
		private var mouse_box:Sprite;
		private var mouse_im:Image;
		private var point_bmd:BitmapData;
		private var clear_bmd:BitmapData;
		
		private var res_folder:File;
		private var mapConf_folder:File;
		private var publish_folder:File;
		
		private var config_file:File;
		private var res_config_dict:Object;
		private var res_bmd_dict:Object;
		
		private var data_file:File;
		private var tile_data_dict:Object;
		private var tile_im_dict:Object;
		public function MapEditor() 
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		
		private function addedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			initSubPage();
			initLayer();
			initToolbar();
			initTree();
			initResList();
			initPreview();
		}
		
		private function initSubPage():void
		{
			newPage = new MapEditorNew();
			newPage.ok_btn.clickHandler = new Handler(newPageHandle);
		}
		
		public function transIn():void
		{
			Log.log("首次打开编辑器点击“资源”按钮，设置资源总目录，设置之后会出现资源目录结构");
			Log.log("对选定的资源设定默认层级和注册点(鼠标拖动和方向键移动)，点击“保存”按钮保存资源设置");
			Log.log("“新建(Ctrl+N)”或“打开(Ctrl+O)”地图文件进行编辑");
			Log.log("“保存(Ctrl+S)”按钮保存地图文件");
			Log.log("“属性”按钮可以改变地图属性");
			Log.log("“路点”,“网格”,“地上”,“地面”,“地下”5个勾选框显示/隐藏对应的图层");
			Log.log("“路点(F1)”,“地上(F2)”,“地面(F3)”,“地下(F4)”4个切换按钮选定当前编辑的图层");
			Log.log("“擦除(Ctrl+Q)”切换涂抹/擦除状态");
			Log.log("“填充(Ctrl+A)”对当前层全部格子进行填充/擦除");
			Log.log("“撤销(Ctrl+Z)”");
			Log.log("“重做(Ctrl+Y)”");
			Log.log("右键按下后在地图区域上移动，可以拖动地图");
			Log.log("左键按下后在地图区域上移动，可以涂抹/擦除当前图层");
			Log.log("Ctrl+左键点击任意格子，即可选定该格子最上层的资源");
			
			interactive_im.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, stage_rightMouseDown);
			stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, stage_rightMouseUp);
			
			interactive_im.addEventListener(MouseEvent.MOUSE_DOWN, tile_mouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, tile_mouseUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, tile_mouseMove);
			
			preview_box.addEventListener(MouseEvent.MOUSE_DOWN, preview_im_mouseDown);
		}
		
		public function transOut():void
		{
			interactive_im.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, stage_rightMouseDown);
			stage.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, stage_rightMouseUp);
			
			interactive_im.removeEventListener(MouseEvent.MOUSE_DOWN, tile_mouseDown);
			stage.removeEventListener(MouseEvent.MOUSE_UP, tile_mouseUp);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, tile_mouseMove);
			
			preview_box.removeEventListener(MouseEvent.MOUSE_DOWN, preview_im_mouseDown);
		}
		
		private function newPageHandle():void 
		{
			if (newPage.isNew) 
			{
				data_file = null;
			}
			setMapData( newPage.isNew, { "cross":newPage.cross_cb.selected, "width":int(newPage.width_ti.text), "height":int(newPage.height_ti.text), "tileWidth":int(newPage.tileWidth_ti.text), "tileHeight":int(newPage.tileHeight_ti.text) } );
		}
		
		private function setMapData(isNew:Boolean, obj:Object):void
		{
			refreshStep();
			
			var modify_update:Boolean = false;
			var modify_delete:Boolean = false;
			if (!isNew)
			{
				if (MapEditorConst.WIDTH == int(obj.width) && MapEditorConst.HEIGHT == int(obj.height) && MapEditorConst.TILE_WIDTH == int(obj.tileWidth) && MapEditorConst.TILE_HEIGHT == int(obj.tileHeight))
				{
					return;
				}
				if (!Boolean(obj.cross) || (MapEditorConst.TILE_WIDTH != int(obj.tileWidth) || MapEditorConst.TILE_HEIGHT != int(obj.tileHeight))) 
				{
					modify_update = true;
				}
				if ((MapEditorConst.WIDTH > int(obj.width) || MapEditorConst.HEIGHT > int(obj.height))) 
				{
					modify_delete = true;
				}
			}
			
			var lastWidth:int = MapEditorConst.WIDTH;
			var lastHeight:int = MapEditorConst.HEIGHT;
			MapEditorConst.CROSS = Boolean(obj.cross);
			MapEditorConst.WIDTH = int(obj.width);
			MapEditorConst.HEIGHT = int(obj.height);
			MapEditorConst.TILE_WIDTH = int(obj.tileWidth);
			MapEditorConst.TILE_HEIGHT = int(obj.tileHeight);
			//
			drawGridLayer();
			
			var shape:Shape;
			if (point_bmd && point_bmd.width == MapEditorConst.TILE_WIDTH && point_bmd.height == MapEditorConst.TILE_HEIGHT) 
			{
				//不需要重绘
			}
			else 
			{
				shape = new Shape();
				shape.graphics.beginFill(0x00ff00, 1);
				shape.graphics.moveTo(0, MapEditorConst.TILE_HEIGHT * 0.5);
				shape.graphics.lineTo(MapEditorConst.TILE_WIDTH * 0.5, 0);
				shape.graphics.lineTo(MapEditorConst.TILE_WIDTH, MapEditorConst.TILE_HEIGHT * 0.5);
				shape.graphics.lineTo(MapEditorConst.TILE_WIDTH * 0.5, MapEditorConst.TILE_HEIGHT);
				shape.graphics.lineTo(0, MapEditorConst.TILE_HEIGHT * 0.5);
				shape.graphics.endFill();
				
				if (point_bmd) 
				{
					point_bmd.dispose();
				}
				point_bmd = new BitmapData(MapEditorConst.TILE_WIDTH, MapEditorConst.TILE_HEIGHT, true, 0x0);
				point_bmd.draw(shape);
			}
			
			if (clear_bmd && clear_bmd.width == MapEditorConst.TILE_WIDTH && clear_bmd.height == MapEditorConst.TILE_HEIGHT) 
			{
				//不需要重绘
			}
			else 
			{
				shape = new Shape();
				shape.graphics.beginFill(0xff0000, 1);
				shape.graphics.moveTo(0, MapEditorConst.TILE_HEIGHT * 0.5);
				shape.graphics.lineTo(MapEditorConst.TILE_WIDTH * 0.5, 0);
				shape.graphics.lineTo(MapEditorConst.TILE_WIDTH, MapEditorConst.TILE_HEIGHT * 0.5);
				shape.graphics.lineTo(MapEditorConst.TILE_WIDTH * 0.5, MapEditorConst.TILE_HEIGHT);
				shape.graphics.lineTo(0, MapEditorConst.TILE_HEIGHT * 0.5);
				shape.graphics.endFill();
				
				if (clear_bmd) 
				{
					clear_bmd.dispose();
				}
				clear_bmd = new BitmapData(MapEditorConst.TILE_WIDTH, MapEditorConst.TILE_HEIGHT, true, 0x0);
				clear_bmd.draw(shape);
			}
			
			if (isNew) 
			{
				//设定地图数据
				for (var layer:int = MapEditorConst.LAYER_POINT; layer <= MapEditorConst.LAYER_DOWN; layer++)
				{
					//清除旧数据
					for (var x:int = 0; x < lastWidth; x++) 
					{
						for (var y:int = 0; y < lastHeight; y++) 
						{
							setTileData(x, y, layer, 0);
						}
					}
					//设置新数据
					for each (var tileData:Object in obj["" + layer]) 
					{
						var offsetX:int;
						var offsetY:int;
						var url:String = null;
						if (layer != MapEditorConst.LAYER_POINT) 
						{
							var config:Object = getResConfig(tileData.url);
							offsetX = config.x;
							offsetY = config.y;
							url = tileData.url;
						}
						else 
						{
							offsetX = MapEditorConst.TILE_WIDTH * 0.5;
							offsetY = MapEditorConst.TILE_HEIGHT * 0.5;
						}
						setTileData(tileData.x, tileData.y, layer, 1, offsetX, offsetY, url);
					}
				}
			}
			else 
			{
				if (modify_delete || modify_update) 
				{
					var delete_arr:Array = modify_delete ? [] : null;
					var update_arr:Array = modify_update ? [] : null;
					for (var key:String in tile_data_dict)
					{
						var temp_arr:Array = key.split(",");
						layer = int(temp_arr[0]);
						x = int(temp_arr[1]);
						y = int(temp_arr[2]);
						url = tile_data_dict[key];
						if (layer != MapEditorConst.LAYER_POINT) 
						{
							config = getResConfig(url);
							offsetX = config.x;
							offsetY = config.y;
						}
						else 
						{
							offsetX = MapEditorConst.TILE_WIDTH * 0.5;
							offsetY = MapEditorConst.TILE_HEIGHT * 0.5;
						}
						if (x < MapEditorConst.WIDTH && y < MapEditorConst.HEIGHT)
						{
							if (modify_update)
							{
								update_arr.push( { x:x, y:y, layer:layer, offsetX:offsetX, offsetY:offsetY, url:url } );
							}
						}
						else 
						{
							if (modify_delete)
							{
								delete_arr.push( { x:x, y:y, layer:layer, offsetX:offsetX, offsetY:offsetY, url:url } );
							}
						}
					}
					//剔除边界外的数据
					for each (tileData in delete_arr)
					{
						setTileData(tileData.x, tileData.y, tileData.layer, 0);
					}
					//更新地图数据
					for each (tileData in update_arr)
					{
						setTileData(tileData.x, tileData.y, tileData.layer, 1, tileData.offsetX, tileData.offsetY, tileData.url);
					}
				}
			}
			//
			layer_type_handle(layer_type_tab.selectedIndex);
		}
		private function drawGridLayer():void
		{
			var shape:Shape = new Shape();
			shape.graphics.lineStyle(1, 0x000000, 1);
			shape.graphics.moveTo(0, MapEditorConst.TILE_HEIGHT * 0.5);
			shape.graphics.lineTo(MapEditorConst.TILE_WIDTH * 0.5, 0);
			shape.graphics.lineTo(MapEditorConst.TILE_WIDTH, MapEditorConst.TILE_HEIGHT * 0.5);
			shape.graphics.lineTo(MapEditorConst.TILE_WIDTH * 0.5, MapEditorConst.TILE_HEIGHT);
			shape.graphics.lineTo(0, MapEditorConst.TILE_HEIGHT * 0.5);
			
			var tile_bmd:BitmapData = new BitmapData(MapEditorConst.TILE_WIDTH, MapEditorConst.TILE_HEIGHT, true, 0x0);
			tile_bmd.draw(shape);
			
			//preview_tile_im.bitmapData = tile_bmd;
			//preview_tile_im.x = -MapEditorConst.TILE_WIDTH * 0.5;
			//preview_tile_im.y = -MapEditorConst.TILE_HEIGHT * 0.5;
			
			var destPoint:Point = new Point();
			var x:int;
			var y:int;
			
			var preview_width:int = Math.round((preview_box.width - MapEditorConst.TILE_WIDTH) / MapEditorConst.TILE_WIDTH * 0.5);
			var preview_height:int = Math.round((preview_box.height - MapEditorConst.TILE_HEIGHT) / MapEditorConst.TILE_HEIGHT * 0.5);
			preview_width = preview_width * 2 + 1;
			preview_height = preview_height * 4 + 1;
			var preview_grid_bmd:BitmapData = new BitmapData(MapEditorConst.TILE_WIDTH * preview_width, MapEditorConst.TILE_HEIGHT * (preview_height + 1) * 0.5, true, 0x0);
			for (x = 0; x < preview_height; x++) 
			{
				for (y = 0; y < preview_width; y++) 
				{
					if (x % 2 == 1 && y == preview_width - 1)
					{
						continue;
					}
					destPoint.x = y * MapEditorConst.TILE_WIDTH;
					if (x % 2 == 1) 
					{
						destPoint.x += MapEditorConst.TILE_WIDTH * 0.5;
					}
					destPoint.y = x * MapEditorConst.TILE_HEIGHT * 0.5;
					preview_grid_bmd.copyPixels(tile_bmd, tile_bmd.rect, destPoint, null, null, true);
				}
			}
			if (preview_tile_im.bitmapData) 
			{
				preview_tile_im.bitmapData.dispose();
			}
			preview_tile_im.alpha = 0.5;
			preview_tile_im.bitmapData = preview_grid_bmd;
			preview_tile_im.x = -preview_grid_bmd.width * 0.5;
			preview_tile_im.y = -preview_grid_bmd.height * 0.5;
			
			//var grid_bmd:BitmapData = new BitmapData(MapEditorConst.TILE_WIDTH * (MapEditorConst.WIDTH + 0.5), MapEditorConst.TILE_HEIGHT * (MapEditorConst.HEIGHT + 1) * 0.5, true, 0x0);
			var grid_bmd:BitmapData = new BitmapData(MapEditorConst.TOTAL_WIDTH, MapEditorConst.TOTAL_HEIGHT, true, 0x0);
			for (y = 0; y < MapEditorConst.HEIGHT; y++) 
			{
				for (x = 0; x < MapEditorConst.WIDTH; x++) 
				{
					//destPoint.x = y * MapEditorConst.TILE_WIDTH;
					//if (x % 2 == 1) 
					//{
						//destPoint.x += MapEditorConst.TILE_WIDTH * 0.5;
					//}
					//destPoint.y = x * MapEditorConst.TILE_HEIGHT * 0.5;
					destPoint = MapEditorConst.getPixelPoint(x, y);
					destPoint.x -= MapEditorConst.TILE_WIDTH * 0.5;
					destPoint.y -= MapEditorConst.TILE_HEIGHT * 0.5;
					grid_bmd.copyPixels(tile_bmd, tile_bmd.rect, destPoint, null, null, true);
				}
			}
			if (grid_bm.bitmapData) 
			{
				grid_bm.bitmapData.dispose();
			}
			grid_bm.bitmapData = grid_bmd;
		}
		
		private function initLayer():void
		{
			down_box = new Sprite();
			layer_box.addChild(down_box);
			
			ground_box = new Sprite();
			layer_box.addChild(ground_box);
			
			up_box = new Sprite();
			layer_box.addChild(up_box);
			
			mouse_box = new Sprite();
			layer_box.addChild(mouse_box);
			mouse_im = new Image();
			mouse_im.filters = [new GlowFilter(0xff0000, 1, 2, 2, 10, 1)];
			mouse_im.alpha = 0.8;
			mouse_box.addChild(mouse_im);
			
			point_box = new Sprite();
			point_box.alpha = 0.5;
			layer_box.addChild(point_box);
			
			grid_bm = new Bitmap();
			grid_bm.alpha = 0.5;
			layer_box.addChild(grid_bm);
			
			cut_box = new Sprite();
			layer_box.addChild(cut_box);
			
			//
			tile_data_dict = { };
			tile_im_dict = { };
		}
		private var _lastRightMouseX:Number = 0;
		private var _lastRightMouseY:Number = 0;
		private function stage_rightMouseDown(e:MouseEvent):void 
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMove);
			_lastRightMouseX = stage.mouseX;
			_lastRightMouseY = stage.mouseY;
		}
		private function stage_rightMouseUp(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMove);
			detectRightPos();
		}
		private function stage_mouseMove(e:MouseEvent):void 
		{
			detectRightPos();
		}
		private function detectRightPos():void
		{
			var deltaX:Number = stage.mouseX - _lastRightMouseX;
			var deltaY:Number = stage.mouseY - _lastRightMouseY;
			_lastRightMouseX = stage.mouseX;
			_lastRightMouseY = stage.mouseY;
			layer_box.x += deltaX;
			layer_box.y += deltaY;
		}
		
		private var isEditTile:Boolean;
		private var lastEditTilePoint:Point;
		private function tile_mouseDown(e:MouseEvent):void 
		{
			//Ctrl键+鼠标左键，选定当前格子资源
			var point:Point = MapEditorConst.getCellPoint(layer_box.mouseX, layer_box.mouseY);
			if (cut_btn.selected)
			{
				//裁剪中
				cutDownHandle(point);
			}
			else if (_isCtrlDown)
			{
				if (point.x < 0 || point.x > MapEditorConst.WIDTH - 1 || point.y < 0 || point.y > MapEditorConst.HEIGHT - 1)
				{
					return;
				}
				var url:String = null;
				var layer:int;
				//var layer:int = layer_type;
				//if (layer_type != MapEditorConst.LAYER_POINT)
				//{
					//url = getTileData(point.x, point.y);
				//}
				if (url == null) 
				{
					for (layer = MapEditorConst.LAYER_UP; layer <= MapEditorConst.LAYER_DOWN; layer++) 
					{
						url = getTileData(point.x, point.y, layer);
						if (url) 
						{
							break;
						}
					}
				}
				if (url) 
				{
					layer_type_tab.selectedIndex = layer;
					setPreviewImage(url);
				}
			}
			else 
			{
				isEditTile = true;
				addNewStep();
				tile_mouseMove();
			}
		}
		private function tile_mouseUp(e:MouseEvent):void 
		{
			isEditTile = false;
			lastEditTilePoint = null;
		}
		private function tile_mouseMove(e:MouseEvent = null):void 
		{
			//mouse_box.x = layer_box.mouseX;
			//mouse_box.y = layer_box.mouseY;
			var point:Point = MapEditorConst.getCellPoint(Math.floor(layer_box.mouseX), Math.floor(layer_box.mouseY));
			var pos:Point = MapEditorConst.getPixelPoint(point.x, point.y);
			px_lb.text = "" + Math.floor(layer_box.mouseX);
			py_lb.text = "" + Math.floor(layer_box.mouseY);
			tx_lb.text = "" + point.x;
			ty_lb.text = "" + point.y;
			mouse_box.x = pos.x;
			mouse_box.y = pos.y;
			if (cut_btn.selected) 
			{
				cutDrawHandle(point);
			}
			else if (isEditTile)
			{
				if (point.x < 0 || point.x > MapEditorConst.WIDTH - 1 || point.y < 0 || point.y > MapEditorConst.HEIGHT - 1)
				{
					return;
				}
				if (lastEditTilePoint && point.x == lastEditTilePoint.x && point.y == lastEditTilePoint.y) 
				{
				}
				else 
				{
					lastEditTilePoint = point;
					var oldUrl:String = getTileData(point.x, point.y);
					setTileData(point.x, point.y);
					var newUrl:String = getTileData(point.x, point.y);
					if (oldUrl != newUrl)
					{
						addStepChange(layer_type, point.x, point.y, oldUrl, newUrl);
					}
				}
			}
		}
		
		//初始化树
		private function initTree():void
		{
			setResFolder(FlashCookie.getValue(FlashCookieConst.MAP_RES_FOLDER));
			tree.mouseHandler = new Handler(tree_mouse_handle);
			/*tree.xml = 	<root>
							<item label="1">
								<item label="1_1" >
									<item label="1_1_1" />
									<item label="1_1_2" />
									<item label="1_1_3" />
								</item>
								<item label="1_2" />
								<item label="1_3" />
							</item>
							<item label="2">
								<item label="2_1" />
								<item label="2_2" />
								<item label="2_3" />
								<item label="2_4" />
							</item>
							<item label="3"/>
						</root>;*/
		}
		
		private function initToolbar():void
		{
			//新建
			new_btn.clickHandler = new Handler(newBtnHandle, [true]);
			//属性
			modify_btn.clickHandler = new Handler(newBtnHandle, [false]);
			//打开
			open_btn.clickHandler = new Handler(open_handle);
			//保存
			save_btn.clickHandler = new Handler(save_handle);
			//资源路径
			res_folder = new File();
			
			var mapConf_url:String = FlashCookie.getValue(FlashCookieConst.MAP_CONF_FOLDER);
			if (mapConf_url) 
			{
				mapConf_folder = new File(mapConf_url);
				mapConf_lb.text = mapConf_url;
			}
			
			var publish_url:String = FlashCookie.getValue(FlashCookieConst.MAP_PUBLISH_FOLDER);
			if (publish_url) 
			{
				publish_folder = new File(publish_url);
				publish_lb.text = publish_url;
			}
			
			res_btn.clickHandler = new Handler(resBrowseHandle);
			mapConf_btn.clickHandler = new Handler(mapConfBrowseHandle);
			publish_res_btn.clickHandler = new Handler(publishBrowseHandle);
			publish_btn.clickHandler = new Handler(publishHandle);
			//查看图层
			point_cb.clickHandler = new Handler(point_cb_handle);
			grid_cb.clickHandler = new Handler(grid_cb_handle);
			up_cb.clickHandler = new Handler(up_cb_handle);
			ground_cb.clickHandler = new Handler(ground_cb_handle);
			down_cb.clickHandler = new Handler(down_cb_handle);
			//选择编辑图层
			layer_type_tab.selectHandler = new Handler(layer_type_handle);
			layer_type_tab.selectedIndex = 0;
			//擦除
			clear_btn.clickHandler = new Handler(clear_btn_handle);
			//填充
			fill_btn.clickHandler = new Handler(fillHandle);
			//撤销
			undo_btn.clickHandler = new Handler(undoHandle);
			//重做
			redo_btn.clickHandler = new Handler(redoHandle);
			
			//裁剪
			cut_btn.clickHandler = new Handler(cutHandle);
		}
		private function newBtnHandle(isNew:Boolean):void
		{
			if (isNew) 
			{
				newPage.setData(true);
			}
			else 
			{
				if (data_file == null)
				{
					return;
				}
				newPage.setData(false, data_file.name);
			}
			App.dialog.popup(newPage);
		}
		//打开
		private function open_handle():void
		{
			var file:File = new File();
			file.browseForOpen("选择地图配置文件", [new FileFilter("json", "*.json")]);
			file.addEventListener(Event.SELECT, openSelectHandle);
		}
		private function openSelectHandle(e:Event):void
		{
			data_file = e.target as File;
			data_file.removeEventListener(Event.SELECT, openSelectHandle);
			FlashCookie.setValue(FlashCookieConst.MAP_OPEN_FILE, data_file.nativePath);
			setOpenMapFile(data_file.nativePath);
		}
		private function setOpenMapFile(url:String):void 
		{
			var str:String = TxtGenerator.read(url);
			var obj:Object = JSON.parse(str);
			setMapData(true, obj);
		}
		//保存
		private function save_handle():void
		{
			if (data_file)
			{
				//保存
				save_map_data();
			}
			else 
			{
				//另存为
				var file:File = new File();
				file.browseForSave("保存地图配置");
				file.addEventListener(Event.SELECT, save_select_handle);
			}
		}
		private function save_select_handle(e:Event):void 
		{
			data_file = e.target as File;
			data_file.removeEventListener(Event.SELECT, save_select_handle);
			
			save_map_data();
		}
		private function save_map_data():void
		{
			var data:Object = { };
			data.cross = MapEditorConst.CROSS;
			data.width = MapEditorConst.WIDTH;
			data.height = MapEditorConst.HEIGHT;
			data.tileWidth = MapEditorConst.TILE_WIDTH;
			data.tileHeight = MapEditorConst.TILE_HEIGHT;
			var point_arr:Array = [];
			var up_arr:Array = [];
			var ground_arr:Array = [];
			var down_arr:Array = [];
			var layer_arr_arr:Array = [point_arr, up_arr, ground_arr, down_arr];
			for (var key:String in tile_data_dict) 
			{
				var temp_arr:Array = key.split(",");
				var layer:int = int(temp_arr[0]);
				var x:int = int(temp_arr[1]);
				var y:int = int(temp_arr[2]);
				var layer_arr:Array = layer_arr_arr[layer];
				var tileData:Object = { x:x, y:y };
				if (layer != MapEditorConst.LAYER_POINT) 
				{
					tileData.url = tile_data_dict[key];
				}
				layer_arr.push(tileData);
			}
			data["" + MapEditorConst.LAYER_POINT] = point_arr;
			data["" + MapEditorConst.LAYER_UP] = up_arr;
			data["" + MapEditorConst.LAYER_GROUND] = ground_arr;
			data["" + MapEditorConst.LAYER_DOWN] = down_arr;
			//
			var json_str:String = JSON.stringify(data);
			TxtGenerator.generate(data_file.url, json_str);
			Log.log("保存地图配置成功：" + data_file.nativePath);
			MessageUtil.prompt("保存地图配置成功！");
		}
		//编辑图层
		private var layer_type:int;
		private function layer_type_handle(index:int):void
		{
			layer_type = index;
			if (isClear) 
			{
				mouse_im.x = -MapEditorConst.TILE_WIDTH * 0.5;
				mouse_im.y = -MapEditorConst.TILE_HEIGHT * 0.5;
				mouse_im.skin = null;
				mouse_im.bitmapData = clear_bmd;
				return;
			}
			if (layer_type == 0)
			{
				mouse_im.x = -MapEditorConst.TILE_WIDTH * 0.5;
				mouse_im.y = -MapEditorConst.TILE_HEIGHT * 0.5;
				mouse_im.skin = null;
				mouse_im.bitmapData = point_bmd;
			}
			else 
			{
				if (preview_config) 
				{
					mouse_im.x = -preview_config.x;
					mouse_im.y = -preview_config.y;
					mouse_im.skin = res_folder.resolvePath(preview_url).url;
				}
				else 
				{
					mouse_im.bitmapData = null;
					mouse_im.skin = null;
				}
			}
		}
		//是否擦除
		private var isClear:Boolean;
		private function clear_btn_handle():void
		{
			isClear = clear_btn.selected;
			layer_type_handle(layer_type);
		}
		//查看图层
		private function point_cb_handle():void
		{
			point_box.visible = point_cb.selected;
		}
		private function grid_cb_handle():void
		{
			grid_bm.visible = grid_cb.selected;
		}
		private function up_cb_handle():void
		{
			up_box.visible = up_cb.selected;
		}
		private function ground_cb_handle():void
		{
			ground_box.visible = ground_cb.selected;
		}
		private function down_cb_handle():void
		{
			down_box.visible = down_cb.selected;
		}
		
		//资源功能
		private function getResConfig(url:String):Object
		{
			var config:Object = res_config_dict[url];
			if (config)
			{
				return config;
			}
			else
			{
				return { x:0, y:0, layer:0 };
			}
		}
		private function setImageConfig(url:String, x:int, y:int, layer:int = 0):void
		{
			res_config_dict[url] = { x:x, y:y, layer:layer };
			var json_str:String = JSON.stringify(res_config_dict);
			TxtGenerator.generate(res_folder.resolvePath("mapRes.json").url, json_str);
			MessageUtil.prompt("保存资源配置成功！");
		}
		private function getResBmd(url:String):BitmapData
		{
			var result:BitmapData = res_bmd_dict[url];
			if (result) 
			{
				return result;
			}
			else 
			{
				return null;
			}
		}
		
		private function setImageBmd(url:String, bmd:BitmapData):void
		{
			res_bmd_dict[url] = bmd;
		}
		
		private function resBrowseHandle():void 
		{
			res_folder.browseForDirectory("选择总资源目录");
			res_folder.addEventListener(Event.SELECT, resSelectHandle);
		}
		private function resSelectHandle(evet:Event):void
		{
			res_folder.removeEventListener(Event.SELECT, resSelectHandle);
			FlashCookie.setValue(FlashCookieConst.MAP_RES_FOLDER, res_folder.nativePath);
			setResFolder(res_folder.nativePath);
		}
		
		private function mapConfBrowseHandle():void 
		{
			var file:File = new File();
			file.browseForDirectory("选择地图配置目录");
			file.addEventListener(Event.SELECT, mapConfSelectHandle);
		}
		private function mapConfSelectHandle(evet:Event):void
		{
			mapConf_folder = evet.target as File;
			mapConf_folder.removeEventListener(Event.SELECT, mapConfSelectHandle);
			FlashCookie.setValue(FlashCookieConst.MAP_CONF_FOLDER, mapConf_folder.nativePath);
			mapConf_lb.text = mapConf_folder.nativePath;
		}
		
		private function publishBrowseHandle():void 
		{
			var file:File = new File();
			file.browseForDirectory("选择资源发布目录");
			file.addEventListener(Event.SELECT, publishSelectHandle);
		}
		private function publishSelectHandle(evet:Event):void
		{
			publish_folder = evet.target as File;
			publish_folder.removeEventListener(Event.SELECT, publishSelectHandle);
			FlashCookie.setValue(FlashCookieConst.MAP_PUBLISH_FOLDER, publish_folder.nativePath);
			publish_lb.text = publish_folder.nativePath;
		}
		
		private function publishHandle():void
		{
			if (mapConf_folder == null) 
			{
				MessageUtil.alert("未指定地图配置目录！");
				return;
			}
			if (publish_folder == null) 
			{
				MessageUtil.alert("未指定发布资源目录！");
				return;
			}
			//删除发布目录下的旧图片
			/*var publish_sub_folder_arr:Array = publish_folder.getDirectoryListing();
			for each (var publish_sub_folder:File in publish_sub_folder_arr) 
			{
				if (publish_sub_folder.isDirectory) 
				{
					publish_sub_folder.deleteDirectory(true);
				}
				else if (publish_sub_folder.extension == "png") 
				{
					publish_sub_folder.deleteFile();
				}
			}
			publish_sub_folder_arr.length = 0;*/
			if (publish_folder.exists) 
			{
				publish_folder.deleteDirectory(true);
			}
			Log.log("删除发布目录");
			
			//复制所有用到的新图片
			var imageDict:Object = { };
			var mapConf_arr:Array = mapConf_folder.getDirectoryListing();
			for each (var mapJsonFile:File in mapConf_arr)
			{
				if (mapJsonFile.extension == "json") 
				{
					var jsonData:Object = JSON.parse(TxtGenerator.read(mapJsonFile.url));
					for (var i:int = 1; i <= 3; i++)
					{
						var layer_arr:Array = jsonData["" + i];
						for each (var cell:Object in layer_arr) 
						{
							imageDict[cell.url] = true;
						}
					}
				}
			}
			mapConf_arr.length = 0;
			
			var subUrl:String = "mapRes.json";
			var res_file:File = res_folder.resolvePath(subUrl);
			var publish_file:File = publish_folder.resolvePath(subUrl);
			if (res_file.exists) 
			{
				res_file.copyTo(publish_file);
				Log.log("复制资源总配置文件到发布目录下：" + subUrl);
			}
			for (subUrl in imageDict) 
			{
				res_file = res_folder.resolvePath(subUrl);
				if (!res_file.exists) 
				{
					continue;
				}
				publish_file = publish_folder.resolvePath(subUrl);
				res_file.copyTo(publish_file);
				Log.log("复制png图片到发布目录下：" + subUrl);
			}
		}
		
		private function setResFolder(url:String):void
		{
			if (!url) 
			{
				return;
			}
			res_lb.text = url;
			res_folder = new File(url);
			
			config_file = res_folder.resolvePath("mapRes.json");
			if (config_file.exists) 
			{
				var config_str:String = TxtGenerator.read(config_file.url);
				res_config_dict = JSON.parse(config_str);
			}
			else 
			{
				res_config_dict = { };
			}
			res_bmd_dict = { };
			
			var xml:XML = 
			<root></root>
			;
			iterationHandle(res_folder, xml);
			tree.xml = xml;
		}
		
		private function iterationHandle(folder:File, xml:XML):void
		{
			for each (var file:File in folder.getDirectoryListing()) 
			{
				//if (!file.isDirectory && file.extension != "png" && file.extension != "jpg") 
				if (!file.isDirectory) 
				{
					continue;
				}
				var subXml:XML = 
				<item label={file.name}>
				</item>;
				xml.appendChild(subXml);
				//if (file.isDirectory) 
				//{
					iterationHandle(file, subXml);
				//}
			}
		}
		
		private function tree_mouse_handle(e:MouseEvent,index:int):void 
		{
			if (e.type != MouseEvent.CLICK) 
			{
				return;
			}
			//if (tree.selectedItem.isDirectory) 
			//{
				//return;
			//}
			//trace(tree.selectedItem);
			var url:String = tree.selectedItem.label;
			var item:Object = tree.selectedItem.nodeParent;
			while (item) 
			{
				url = item.label + "/" + url;
				item = item.nodeParent;
			}
			//setPreviewImage(url);
			updateResList(url);
		}
		
		private function initResList():void
		{
			res_list.renderHandler = new Handler(resListRenderHandle);
			res_list.mouseHandler = new Handler(resListMouseHandle);
			res_list.array = [];
		}
		
		private function resListRenderHandle(cell:Box, index:int):void
		{
			if (index > res_list.array.length - 1) 
			{
				return;
			}
			var url:String = res_list.array[index];
			var url_lb:Label = cell.getChildByName("url_lb") as Label;
			var im:Image = cell.getChildByName("im") as Image;
			url_lb.text = url;
			im.skin = res_folder.resolvePath(url).url;
		}
		
		private function resListMouseHandle(e:MouseEvent, index:int):void
		{
			if (e.type != MouseEvent.CLICK) 
			{
				return;
			}
			var url:String = res_list.array[index];
			var layer:int = int(getResConfig(url).layer);
			if (layer != 0) 
			{
				layer_type_tab.selectedIndex = layer;
			}
			setPreviewImage(url);
		}
		
		//private var list_folder_url:String = "";
		private function updateResList(url:String):void
		{
			//list_folder_url = url;
			var arr:Array = [];
			var folder:File = res_folder.resolvePath(url);
			for each (var file:File in folder.getDirectoryListing()) 
			{
				if (file.extension == "png" || file.extension == "jpg")
				{
					arr.push(url + "/" + file.name);
				}
			}
			res_list.array = arr;
		}
		
		private function initPreview():void
		{
			var shape:Shape = new Shape();
			preview_line_box.addChild(shape);
			shape.graphics.lineStyle(1, 0xff0000, 1);
			shape.graphics.moveTo( -preview_line_box.x, 0);
			shape.graphics.lineTo( preview_line_box.x, 0);
			shape.graphics.moveTo( 0, -preview_line_box.y);
			shape.graphics.lineTo( 0, preview_line_box.y);
			//
			pos_btn.clickHandler = new Handler(pos_save_handle);
		}
		
		private var _offsetMouseX:int;
		private var _offsetMouseY:int;
		private function preview_im_mouseDown(e:MouseEvent):void 
		{
			_offsetMouseX = preview_im.mouseX;
			_offsetMouseY = preview_im.mouseY;
			preview_box.removeEventListener(MouseEvent.MOUSE_DOWN, preview_im_mouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, preview_im_mouseUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, preview_im_mouseMove);
		}
		
		private function preview_im_mouseMove(e:MouseEvent):void
		{
			preview_im.x = preview_line_box.mouseX - _offsetMouseX;
			preview_im.y = preview_line_box.mouseY - _offsetMouseY;
			pos_x_lb.text = -preview_im.x + "";
			pos_y_lb.text = -preview_im.y + "";
		}
		
		private function preview_im_mouseUp(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, preview_im_mouseUp);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, preview_im_mouseMove);
			preview_im.addEventListener(MouseEvent.MOUSE_DOWN, preview_im_mouseDown);
		}
		
		private function pos_save_handle():void
		{
			var x:int = int(pos_x_lb.text);
			var y:int = int(pos_y_lb.text);
			var layer:int = pos_layer_cb.selectedIndex;
			setImageConfig(preview_url, x, y, layer);
			if (layer != 0) 
			{
				layer_type_tab.selectedIndex = layer;
			}
			preview_config = getResConfig(preview_url);
			mouse_im.x = -x;
			mouse_im.y = -y;
			updateTilesResOffset(preview_url, x, y);
		}
		
		private var preview_config:Object = null;
		private var preview_url:String = null;
		private function setPreviewImage(url:String):void
		{
			preview_url = url;
			preview_im.skin = res_folder.resolvePath(preview_url).url;
			var config:Object = getResConfig(preview_url);
			preview_im.x = -config.x;
			preview_im.y = -config.y;
			pos_layer_cb.selectedIndex = int(config.layer);
			pos_x_lb.text = "" + config.x;
			pos_y_lb.text = "" + config.y;
			preview_config = config;
			//
			layer_type_handle(layer_type);
			clear_btn.selected = false;
			clear_btn_handle();
		}
		
		//编辑功能
		private function setTileData(x:int, y:int, layer:int = -1, state:int = -1, offsetX:int = 0, offsetY:int = 0, url:String = null):void
		{
			if (layer < 0) 
			{
				layer = layer_type;
				if (layer != MapEditorConst.LAYER_POINT) 
				{
					if (preview_config) 
					{
						offsetX = preview_config.x;
						offsetY = preview_config.y;
					}
					url = preview_url;
				}
				else 
				{
					offsetX = MapEditorConst.TILE_WIDTH * 0.5;
					offsetY = MapEditorConst.TILE_HEIGHT * 0.5;
				}
			}
			if (state < 0) 
			{
				state = int(!isClear);
			}
			if (layer != MapEditorConst.LAYER_POINT && state && !url)
			{
				state = 0;
			}
			var key:String = layer + "," + x + "," + y;
			var tile_im:Image;
			if (state)
			{
				var pos:Point = MapEditorConst.getPixelPoint(x, y);
				tile_im = getTileIm(x, y, layer, true);
				tile_im.x = pos.x - offsetX;
				tile_im.y = pos.y - offsetY;
				
				if (layer == MapEditorConst.LAYER_POINT) 
				{
					if (getTileData(x, y, layer) != "1") 
					{
						tile_data_dict[key] = "1";
						tile_im.skin = null;
						tile_im.bitmapData = point_bmd;
					}
				}
				else 
				{
					if (getTileData(x, y, layer) != url)
					{
						tile_data_dict[key] = url;
						tile_im.bitmapData = null;
						tile_im.skin = res_folder.resolvePath(url).url;
					}
				}
			}
			else 
			{
				tile_im = getTileIm(x, y, layer, false);
				if (tile_im) 
				{
					tile_im.destory();
					tile_im.remove();
				}
				delete tile_data_dict[key];
				delete tile_im_dict[key];
			}
		}
		
		private function getTileData(x:int, y:int, layer:int = -1):String
		{
			if (layer < 0) 
			{
				layer = layer_type;
			}
			var key:String = layer + "," + x + "," + y;
			if (tile_data_dict[key]) 
			{
				return tile_data_dict[key];
			}
			else
			{
				return null;
			}
		}
		
		private function getTileIm(x:int, y:int, layer:int = -1, nullNew:Boolean = false):Image
		{
			if (layer < 0)
			{
				layer = layer_type;
			}
			var key:String = layer + "," + x + "," + y;
			if (tile_im_dict[key])
			{
				return tile_im_dict[key];
			}
			else if (nullNew) 
			{
				var im:Image = new Image();
				im.name = x + "," + y;
				tile_im_dict[key] = im;
				var box:Sprite = getLayerBox(layer);
				if (layer == MapEditorConst.LAYER_POINT)
				{
					box.addChild(im);
				}
				else 
				{
					var index:int = MapEditorConst.getPointIndex(x, y);
					//设置图层内部元件的层级
					for (var i:int = 0; i < box.numChildren; i++)
					{
						var temp_arr:Array = box.getChildAt(i).name.split(",");
						var temp_x:int = int(temp_arr[0]);
						var temp_y:int = int(temp_arr[1]);
						var temp_index:int = MapEditorConst.getPointIndex(temp_x, temp_y);
						if (index < temp_index)
						{
							break;
						}
					}
					box.addChildAt(im, i);
				}
				return im;
			}
			else 
			{
				return null;
			}
		}
		
		private function getLayerBox(layer:int = -1):Sprite
		{
			if (layer < 0)
			{
				layer = layer_type;
			}
			switch (layer) 
			{
				case 0:
					return point_box;
				break;
				case 1:
					return up_box;
				break;
				case 2:
					return ground_box;
				break;
				case 3:
					return down_box;
				break;
			}
			return null;
		}
		
		private function updateTilesResOffset(url:String, x:int, y:int):void
		{
			for (var key:String in tile_data_dict)
			{
				var tile_url:String = tile_data_dict[key];
				if (tile_url != url) 
				{
					continue;
				}
				var im:Image = tile_im_dict[key];
				if (im) 
				{
					var temp_arr:Array = im.name.split(",");
					var temp_x:int = int(temp_arr[0]);
					var temp_y:int = int(temp_arr[1]);
					var pos:Point = MapEditorConst.getPixelPoint(temp_x, temp_y);
					im.x = pos.x - x;
					im.y = pos.y - y;
				}
			}
		}
		
		//键盘功能
		private var _isCtrlDown:Boolean;
		public function keyHandle(e:KeyboardEvent):void 
		{
			if (e.type == KeyboardEvent.KEY_DOWN) 
			{
				switch (e.keyCode)
				{
				case Keyboard.CONTROL:
					_isCtrlDown = true;
					break;
				case Keyboard.LEFT://左
					preview_im.x -= 1;
					pos_x_lb.text = -preview_im.x + "";
					break;
				case Keyboard.RIGHT://右
					preview_im.x += 1;
					pos_x_lb.text = -preview_im.x + "";
					break;
				case Keyboard.UP://上
					preview_im.y -= 1;
					pos_y_lb.text = -preview_im.y + "";
					break;
				case Keyboard.DOWN://下
					preview_im.y += 1;
					pos_y_lb.text = -preview_im.y + "";
					break;
				case Keyboard.F1:
					layer_type_tab.selectedIndex = 0;
					break;
				case Keyboard.F2:
					layer_type_tab.selectedIndex = 1;
					break;
				case Keyboard.F3:
					layer_type_tab.selectedIndex = 2;
					break;
				case Keyboard.F4:
					layer_type_tab.selectedIndex = 3;
					break;
					//
				case Keyboard.N://新建
					if (e.ctrlKey)
					{
						newBtnHandle(true);
					}
					break;
				case Keyboard.O://打开
					if (e.ctrlKey)
					{
						open_handle();
					}
					break;
				case Keyboard.S://保存
					if (e.ctrlKey)
					{
						save_handle();
					}
					break;
				case Keyboard.Q://擦除
					if (e.ctrlKey)
					{
						clear_btn.selected = !clear_btn.selected;
						clear_btn_handle();
					}
					break;
				case Keyboard.A://填充
					if (e.ctrlKey)
					{
						fillHandle();
					}
					break;
				case Keyboard.Z://撤销
					if (e.ctrlKey)
					{
						undoHandle();
					}
					break;
				case Keyboard.Y://重做
					if (e.ctrlKey)
					{
						redoHandle();
					}
					break;
				}
			}
			else 
			{
				switch (e.keyCode)
				{
				case Keyboard.CONTROL:
					_isCtrlDown = false;
					break;
				}
			}
		}
		
		private function getLayerName(layer:int = -1):String
		{
			if (layer < 0) 
			{
				layer = layer_type;
			}
			switch (layer) 
			{
			case MapEditorConst.LAYER_POINT:
				return "路点层";
				break;
			case MapEditorConst.LAYER_UP:
				return "地上层";
				break;
			case MapEditorConst.LAYER_GROUND:
				return "地面层";
				break;
			case MapEditorConst.LAYER_DOWN:
				return "地下层";
				break;
			}
			return "";
		}
		
		private function fillHandle():void
		{
			var layerName:String = getLayerName();
			var actionName:String = isClear ? "擦除" : "填充";
			MessageUtil.dialog("是否对\“" + layerName + "\”进行 " + actionName + "?", new Handler(fillDialogHandle));
		}
		
		//填充
		private function fillDialogHandle(value:Boolean):void
		{
			if (!value)
			{
				return;
			}
			addNewStep();
			for (var x:int = 0; x < MapEditorConst.WIDTH; x++) 
			{
				for (var y:int = 0; y < MapEditorConst.HEIGHT; y++) 
				{
					var oldUrl:String = getTileData(x, y);
					setTileData(x, y);
					var newUrl:String = getTileData(x, y);
					if (oldUrl != newUrl) 
					{
						addStepChange(layer_type, x, y, oldUrl, newUrl);
					}
				}
			}
		}
		
		//操作记录
		private var _step_arr:Array;
		private function refreshStep():void
		{
			if (_step_arr == null) 
			{
				_step_arr = [];
			}
			else 
			{
				_step_arr.length = 0
			}
			_step_index = -1
		}
		
		private var _step_index:int = -1;
		private function addNewStep():void
		{
			//删除当前步骤之后的步骤数据
			_step_arr.splice(_step_index + 1);
			_step_index++;
			var temp_step_data:Array = [];
			_step_arr.push(temp_step_data);
		}
		
		private function addStepChange(layer:int, x:int, y:int, oldUrl:String, newUrl:String):void
		{
			_step_arr[_step_index].push( { layer:layer, x:x, y:y, oldUrl:oldUrl, newUrl:newUrl } );
		}
		
		//撤销
		private function undoHandle():void
		{
			if (_step_index < 0) 
			{
				return;
			}
			var temp_step_data:Array = _step_arr[_step_index];
			_step_index--;
			for (var i:int = temp_step_data.length - 1; i >= 0; i--) 
			{
				var changeData:Object = temp_step_data[i];
				if (changeData.oldUrl)
				{
					var offsetX:int;
					var offsetY:int;
					if (changeData.layer != MapEditorConst.LAYER_POINT) 
					{
						var config:Object = getResConfig(changeData.oldUrl);
						offsetX = config.x;
						offsetY = config.y;
					}
					else 
					{
						offsetX = MapEditorConst.TILE_WIDTH * 0.5;
						offsetY = MapEditorConst.TILE_HEIGHT * 0.5;
					}
					setTileData(changeData.x, changeData.y, changeData.layer, 1, offsetX, offsetY, changeData.oldUrl);
				}
				else 
				{
					setTileData(changeData.x, changeData.y, changeData.layer, 0);
				}
			}
			MessageUtil.prompt("撤销");
		}
		//重做
		private function redoHandle():void
		{
			if (_step_arr == null || _step_index >= _step_arr.length - 1) 
			{
				return;
			}
			_step_index++;
			var temp_step_data:Array = _step_arr[_step_index];
			for (var i:int = temp_step_data.length - 1; i >= 0; i--) 
			{
				var changeData:Object = temp_step_data[i];
				if (changeData.newUrl)
				{
					var offsetX:int;
					var offsetY:int;
					if (changeData.layer != MapEditorConst.LAYER_POINT) 
					{
						var config:Object = getResConfig(changeData.newUrl);
						offsetX = config.x;
						offsetY = config.y;
					}
					else 
					{
						offsetX = MapEditorConst.TILE_WIDTH * 0.5;
						offsetY = MapEditorConst.TILE_HEIGHT * 0.5;
					}
					setTileData(changeData.x, changeData.y, changeData.layer, 1, offsetX, offsetY, changeData.newUrl);
				}
				else 
				{
					setTileData(changeData.x, changeData.y, changeData.layer, 0);
				}
			}
			MessageUtil.prompt("重做");
		}
		
		//-----------------------------------------裁剪功能-------------------------------------------
		private var _cutStartPoint:Point;
		private var _cutEndPoint:Point;
		private function cutDownHandle(point:Point):void
		{
			if (_cutStartPoint == null) 
			{
				_cutStartPoint = point;
			}
			else 
			{
				_cutEndPoint = point;
				
				var file:File = new File();
				file.browseForSave("保存地图配置");
				file.addEventListener(Event.SELECT, save_cut_select_handle);
				file.addEventListener(Event.CANCEL, save_cut_cancel_handle);
			}
		}
		
		private function save_cut_select_handle(e:Event):void 
		{
			e.target.removeEventListener(Event.SELECT, save_select_handle);
			e.target.removeEventListener(Event.CANCEL, save_cut_cancel_handle);
			var file:File = e.target as File;
			
			var start_tx:int = Math.min(_cutStartPoint.x, _cutEndPoint.x);
			var start_ty:int = Math.min(_cutStartPoint.y, _cutEndPoint.y);
			var end_tx:int = Math.max(_cutStartPoint.x, _cutEndPoint.x);
			var end_ty:int = Math.max(_cutStartPoint.y, _cutEndPoint.y);
			if (start_tx < 0) 
			{
				start_tx = 0;
			}
			if (start_ty < 0) 
			{
				start_ty = 0;
			}
			if (end_tx > MapEditorConst.WIDTH - 1) 
			{
				end_tx = MapEditorConst.WIDTH - 1;
			}
			if (end_ty > MapEditorConst.HEIGHT - 1) 
			{
				end_ty = MapEditorConst.HEIGHT - 1;
			}
			//
			var data:Object = { };
			data.cross = MapEditorConst.CROSS;
			data.width = end_tx - start_tx + 1;
			data.height = end_ty - start_ty + 1;
			data.tileWidth = MapEditorConst.TILE_WIDTH;
			data.tileHeight = MapEditorConst.TILE_HEIGHT;
			var point_arr:Array = [];
			var up_arr:Array = [];
			var ground_arr:Array = [];
			var down_arr:Array = [];
			var layer_arr_arr:Array = [point_arr, up_arr, ground_arr, down_arr];
			for (var key:String in tile_data_dict) 
			{
				var temp_arr:Array = key.split(",");
				var x:int = int(temp_arr[1]);
				var y:int = int(temp_arr[2]);
				if (x >= start_tx && x <= end_tx && y >= start_ty && y <= end_ty) 
				{
					var layer:int = int(temp_arr[0]);
					var layer_arr:Array = layer_arr_arr[layer];
					var tileData:Object = { x:x - start_tx, y:y - start_ty };
					if (layer != MapEditorConst.LAYER_POINT) 
					{
						tileData.url = tile_data_dict[key];
					}
					layer_arr.push(tileData);
				}
			}
			data["" + MapEditorConst.LAYER_POINT] = point_arr;
			data["" + MapEditorConst.LAYER_UP] = up_arr;
			data["" + MapEditorConst.LAYER_GROUND] = ground_arr;
			data["" + MapEditorConst.LAYER_DOWN] = down_arr;
			//
			var json_str:String = JSON.stringify(data);
			TxtGenerator.generate(file.url, json_str);
			Log.log("保存裁剪地图成功！" + file.nativePath);
			MessageUtil.prompt("保存裁剪地图成功！");
			//
			clearCutState();
		}
		
		private function save_cut_cancel_handle(e:Event):void 
		{
			e.target.removeEventListener(Event.SELECT, save_select_handle);
			e.target.removeEventListener(Event.CANCEL, save_cut_cancel_handle);
			//
			clearCutState();
		}
		
		private function cutDrawHandle(point:Point):void
		{
			if (_cutStartPoint == null) 
			{
				return;
			}
			cut_box.graphics.clear();
			
			var start_tx:int = Math.min(_cutStartPoint.x, point.x);
			var start_ty:int = Math.min(_cutStartPoint.y, point.y);
			var end_tx:int = Math.max(_cutStartPoint.x, point.x);
			var end_ty:int = Math.max(_cutStartPoint.y, point.y);
			if (start_tx < 0) 
			{
				start_tx = 0;
			}
			if (start_ty < 0) 
			{
				start_ty = 0;
			}
			if (end_tx > MapEditorConst.WIDTH - 1) 
			{
				end_tx = MapEditorConst.WIDTH - 1;
			}
			if (end_ty > MapEditorConst.HEIGHT - 1) 
			{
				end_ty = MapEditorConst.HEIGHT - 1;
			}
			
			cut_width_lb.text = "" + (end_tx - start_tx + 1);
			cut_height_lb.text = "" + (end_ty - start_ty + 1);
			
			//上
			var p1:Point = MapEditorConst.getPixelPoint(start_tx, start_ty);
			p1.y -= MapEditorConst.TILE_HEIGHT / 2;
			//右
			var p2:Point = MapEditorConst.getPixelPoint(end_tx, start_ty);
			p2.x += MapEditorConst.TILE_WIDTH / 2;
			//下
			var p3:Point = MapEditorConst.getPixelPoint(end_tx, end_ty);
			p3.y += MapEditorConst.TILE_HEIGHT / 2;
			//左
			var p4:Point = MapEditorConst.getPixelPoint(start_tx, end_ty);
			p4.x -= MapEditorConst.TILE_WIDTH / 2;
			
			cut_box.graphics.beginFill(0x0000ff, 0.5);
			cut_box.graphics.moveTo(p1.x, p1.y);
			cut_box.graphics.lineTo(p2.x, p2.y);
			cut_box.graphics.lineTo(p3.x, p3.y);
			cut_box.graphics.lineTo(p4.x, p4.y);
			cut_box.graphics.lineTo(p1.x, p1.y);
			cut_box.graphics.endFill();
		}
		
		private function clearCutState():void
		{
			cut_width_lb.text = "0";
			cut_height_lb.text = "0";
			cut_btn.selected = false;
			
			_cutStartPoint = null;
			_cutEndPoint = null;
			cut_box.graphics.clear();
		}
		
		private function cutHandle():void
		{
			if (!cut_btn.selected)
			{
				clearCutState();
			}
		}
	}
}