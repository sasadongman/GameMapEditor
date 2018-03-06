package modules.AnimationTool 
{
	import dragData.vily.DragDataManager;
	import dragData.vily.interfaces.IDragData;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import modules.AvatarTool.ExternalManager;
	import morn.core.components.Box;
	import morn.core.components.Label;
	import morn.core.events.DragEvent;
	import utils.ImageCreator;
	import modules.IPage;
	import morn.AnimationToolUI;
	import morn.core.handlers.Handler;
	import smh.core.bmr.cache.BmrCacheAnimation;
	import smh.core.bmr.cache.BmrCacheFrame;
	import smh.core.bmr.display.BmrAnimation;
	import utils.TxtGenerator;
	
	/**
	 * ...
	 * @author Alex
	 */
	public class AnimationTool extends AnimationToolUI implements IDragData, IPage
	{
		//拖拽管理器
		private var _dragDM:DragDataManager;
		private var folder_file:File;
		private var nativeFile:File;
		private var swfFolder:String;
		private var nativePath:String;
		private var nativeFolderName:String;
		private var fileNames:Array;
		private var curFileName:String;
		private var bmdDict:Dictionary;
		private var minBmdDict:Dictionary;
		private var info_xml:XML;
		private var _animation_box:Sprite;
		public function AnimationTool() 
		{
			super();
			
			_dragDM = new DragDataManager();
			_dragDM.setTarget(this);
			_dragDM.setReceiver(this);
			//
			info_box.visible = false;
			info_list.renderHandler = new Handler(info_list_render_handle);
			info_list.mouseHandler = new Handler(info_list_mouse_handle);
			//
			loop_cb.clickHandler = new Handler(loop_cb_click);
			addMode_cb.clickHandler = new Handler(addMode_cb_click);
			package_btn.clickHandler = new Handler(package_click);
			ani_btn.clickHandler = new Handler(ani_click);
			play_btn.clickHandler = new Handler(play_btn_click);
			stop_btn.clickHandler = new Handler(stop_btn_click);
			clear_btn.clickHandler = new Handler(clear_btn_click);
			clear_bg_btn.clickHandler = new Handler(clear_bg_btn_click);
			
			_animation_box = new Sprite();
			_animation_box.mouseChildren = false;
			//this.addChild(_animation_box);
			animation_box.addChild(_animation_box);
			_animation_box.addEventListener(MouseEvent.MOUSE_DOWN, animation_box_mouseDown);
			_animation_box.addEventListener(DragEvent.DRAG_COMPLETE, animation_box_dragComplete);
			_animation = new BmrAnimation(null);
			_animation_box.addChild(_animation);
			
			animation_box.x = bg_im.x = int(this.width / 2);
			animation_box.y = bg_im.y = int(this.height / 2);
			
			this.addEventListener(Event.RESIZE, resize_handle);
			animation_x_lb.textField.addEventListener(Event.CHANGE, animation_lb_change);
			animation_y_lb.textField.addEventListener(Event.CHANGE, animation_lb_change);
			speedScale_it.textField.addEventListener(Event.CHANGE, speedScale_it_change);
			
			this.addEventListener(Event.ADDED_TO_STAGE, this_addedToStage);
		}
		
		private function this_addedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, this_addedToStage);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown_handle);
			stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, stage_rightMouseDown);
			stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, stage_rightMouseUp);
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
			animation_box.x += deltaX;
			animation_box.y += deltaY;
			bg_im.x += deltaX;
			bg_im.y += deltaY;
			updateAnimationGraphics();
		}
		
		private function animation_lb_change(e:Event):void
		{
			setAnimationPosition(int(animation_x_lb.text), int(animation_y_lb.text), true);
		}
		
		private function speedScale_it_change(e:Event):void
		{
			if (_animation) 
			{
				_animation.speedScale = Number(speedScale_it.text);
			}
		}
		
		private function resize_handle(e:Event = null):void 
		{
			//animation_box.x = bg_im.x = int(this.width / 2);
			//animation_box.y = bg_im.y = int(this.height / 2);
			updateAnimationGraphics();
		}
		
		private function updateAnimationGraphics():void
		{
			animation_box.graphics.clear();
			animation_box.graphics.lineStyle(1, 0x00ff00);
			animation_box.graphics.moveTo(-animation_box.x, 0);
			animation_box.graphics.lineTo(this.width - animation_box.x / 2, 0);
			animation_box.graphics.moveTo(0, -animation_box.y);
			animation_box.graphics.lineTo(0, this.height - animation_box.y);
		}
		
		private function keyDown_handle(e:KeyboardEvent):void 
		{
			switch (e.keyCode) 
			{
				case Keyboard.LEFT:
					setAnimationPosition(_animation_box.x - 1, _animation_box.y);
				break;
				case Keyboard.RIGHT:
					setAnimationPosition(_animation_box.x + 1, _animation_box.y);
				break;
				case Keyboard.UP:
					setAnimationPosition(_animation_box.x, _animation_box.y - 1);
				break;
				case Keyboard.DOWN:
					setAnimationPosition(_animation_box.x, _animation_box.y + 1);
				break;
			}
		}
		
		private function animation_box_mouseDown(e:MouseEvent):void 
		{
			App.drag.doDrag(_animation_box);
		}
		
		private var _animation_box_x:int;
		private var _animation_box_y:int;
		private function animation_box_dragComplete(e:DragEvent):void 
		{
			setAnimationPosition(_animation_box.x, _animation_box.y);
		}
		
		private function setAnimationPosition(x:int = 0, y:int = 0, changeByLabel:Boolean = false):void
		{
			_animation_box.x = x;
			_animation_box.y = y;
			if (!changeByLabel)
			{
				animation_x_lb.text = "" + x;
				animation_y_lb.text = "" + y;
			}
			_animation_box_x = x;
			_animation_box_y = y;
		}
		
		public function transIn():void
		{
			Log.log("支持两种模式：");
			Log.log("1.打包模式：拖动素材所在文件夹到上面窗口");
			Log.log("2.swf查看模式：拖动动画swf文件到上面窗口");
			Log.log("3.1图集查看模式：拖动动画ani文件到上面窗口");
			Log.log("3.2图集查看模式：拖动图集json文件到上面窗口");
			Log.log("设定背景：拖动jpg或png文件到上面窗口");
			Log.log("设定动画注册点：左键拖动动画文件、上下左右按键、修改动画位置输入框");
			Log.log("移动参考线：右键拖动舞台");
		}
		
		public function transOut():void
		{
			
		}
		
		/* INTERFACE dragData.vily.interfaces.IDragData */
		/**
			添加数据到接收者
			@param		obj:{format:"数据类型",data:*,x:0,y:0},format表示的数据类型都包含在dragData.vily.data.DragDataFormat中
						x和y属性记录了拖动时放开鼠标的位置坐标
		*/
		public function setDragData(obj:Object):void
		{
			//trace("obj.format:" + obj.format);
			//trace("obj.data:" + obj.data);
			nativeFile = new File(String(obj.data));
			if (nativeFile.isDirectory) 
			{
				Log.log("拖入了文件夹，尝试1.打包模式");
				nativePath = obj.data + "\\";
				//trace("nativePath:" + nativePath);
				nativeFolderName = nativeFile.name;
				Log.log("开始处理文件夹:" + nativeFile.nativePath);
				
				info_xml = null;
				var files:Array = nativeFile.getDirectoryListing();
				var arr:Array = [];
				for each (var file:File in files)
				{
					if (file.extension == "txt")
					{
						arr.push(file.name.substring(0, file.name.length - 4));
					}
				}
				if (arr.length > 0)
				{
					Log.log("有多个配置文件，选择需要操作的配置文件");
					info_list.selectedIndex = -1;
					info_list.array = arr;
					info_box.visible = true;
				}
				else 
				{
					Log.log("配置文件不存在");
					Log.log("帧频将使用文本框填入数据");
					excuteHandle();
				}
			}
			else
			{
				if (nativeFile.extension == "swf")
				{
					Log.log("拖入了swf文件，尝试2.swf查看模式");
					clearAnimation();
					var loader:Loader = new Loader();
					loader.load(new URLRequest(nativeFile.url));
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, swf_load_complete);
				}
				else if (nativeFile.extension == "ani") 
				{
					Log.log("拖入了json文件，尝试3.1图集ani查看模式");
					startAtlasAni(String(obj.data));
				}
				else if (nativeFile.extension == "json") 
				{
					Log.log("拖入了json文件，尝试3.2图集json查看模式");
					startAtlasJson(String(obj.data));
				}
				else if (nativeFile.extension == "jpg" || nativeFile.extension == "png") 
				{
					Log.log("拖入了" + nativeFile.extension + "文件，设定为背景");
					bg_im.url = nativeFile.url;
				}
			}
		}
		
		private function info_list_render_handle(cell:Box, index:int):void
		{
			var name_lb:Label = cell.getChildByName("name_lb") as Label;
			name_lb.text = info_list.array[index];
		}
		
		private function info_list_mouse_handle(e:MouseEvent, index:int):void
		{
			if (e.type != MouseEvent.CLICK) 
			{
				return;
			}
			var info_name:String = info_list.array[index] + ".txt";
			Log.log("选定了配置文件：" + info_name);
			var info_str:String = TxtGenerator.read(nativePath + info_name);
			try 
			{
				info_xml = new XML(info_str);
			}
			catch (err:Error)
			{
				Log.log("读取配置文件出错！");
			}
			finally 
			{
				Log.log("读取配置文件成功！");
				info_box.visible = false;
				nativeFolderName = info_list.array[index];
				excuteHandle();
			}
		}
		
		private function excuteHandle():void
		{
			fileNames = [];
			bmdDict = new Dictionary();
			minBmdDict = new Dictionary();
			var files:Array = nativeFile.getDirectoryListing();
			for each (var file:File in files)
			{
				if (file.extension == "png" || file.extension == "jpg")
				{
					fileNames.push(file.name);
				}
			}
			loadNext();
		}
		
		//---------------------------------------打包模式相关代码----------------------------------
		private function loadNext():void
		{
			if (fileNames.length == 0) 
			{
				loadFinish();
				return;
			}
			curFileName = fileNames.shift();
			
			var loader:Loader = new Loader();
			//loader.load(new URLRequest(nativePath + curFileName + ".png"));
			loader.load(new URLRequest(nativePath + curFileName));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_complete);
		}
		
		private function loader_complete(e:Event):void 
		{
			var loaderInfo:LoaderInfo = e.target as LoaderInfo;
			var loader:Loader = loaderInfo.loader;
			var loader_bm:Bitmap = loader.content as Bitmap;
			//
			bmdDict[curFileName] = loader_bm.bitmapData;
			//
			loadNext();
		}
		
		private var destPoint:Point = new Point();
		//文件夹内图片全部加载完成
		private var _isLoadFinish:Boolean;
		private function loadFinish():void
		{
			_isLoadFinish = true;
			//
			var frames:Vector.<BmrCacheFrame> = new Vector.<BmrCacheFrame>();
			var frame:BmrCacheFrame;
			//
			var type:int = 1;
			if (info_xml != null)
			{
				type = int(info_xml.@type);
			}
			var frameRate:int = int(frameRate_it.text);
			if (info_xml != null)
			{
				frameRate = int(info_xml.@frameRate);
			}
			var frameTime:int = int(1000 / frameRate);
			var loop:Boolean = false;
			var imageInfoArr:Array = [];
			if (type == 1) 
			{
				loop = loop_cb.selected;
				var sort_arr:Array = [];
				for (var imageName:String in bmdDict) 
				{
					sort_arr.push(imageName);
				}
				//排序
				sort_arr.sort();
				for each(imageName in sort_arr)
				{
					frame = new BmrCacheFrame(bmdDict[imageName], 0, 0, frameTime);
					frames.push(frame);
				}
			}
			else
			{
				var curFrameImage:String = "";
				var curFramesNum:int = 0;
				for (var i:int = 0; i < info_xml.sec.frame.length(); i++) 
				{
					//curFrameIndex++;
					curFramesNum++;
					var frame_xml:XML = info_xml.sec.frame[i];
					//image		空表示非关键帧,1...数字表示关键帧的对应png名字,“*”表示循环自第一帧开始,“#”表示在此帧结束不循环
					var temp_frame_image:String = String(frame_xml.@image);
					if (temp_frame_image == "")
					{
					}
					else
					{
						if (curFrameImage != "") 
						{
							imageName = curFrameImage + "." + "png";
							frame = new BmrCacheFrame(bmdDict[imageName], 0, 0, frameTime * curFramesNum);
							frames.push(frame);
						}
						//
						if (temp_frame_image == "*")
						{
							loop = true;
							break;
						}
						else if (temp_frame_image == "#")
						{
							loop = false;
							break;
						}
						else 
						{
							//下一张图
							curFrameImage = temp_frame_image;
							curFramesNum = 0;
						}
					}
				}
			}
			clearAnimation();
			_cacheAnimation = new BmrCacheAnimation(frames, frameRate, loop);
			_animation.setCache(_cacheAnimation, true, _cacheAnimation.loop, false, Number(speedScale_it.text));
			setAnimationPosition();
			loop_cb.selected = _animation.loop;
		}
		
		private function package_click():void
		{
			if (!_isLoadFinish) 
			{
				return;
			}
			_isLoadFinish = false;
			//
			var type:int = 1;
			if (info_xml != null)
			{
				type = int(info_xml.@type);
			}
			var frameRate:int = int(frameRate_it.text);
			if (info_xml != null)
			{
				frameRate = int(info_xml.@frameRate);
			}
			var frameTime:int = int(1000 / frameRate);
			var loop:Boolean = false;
			var imageInfoArr:Array = [];
			if (type == 1) 
			{
				var sort_arr:Array = [];
				for (var imageName:String in bmdDict) 
				{
					sort_arr.push(imageName);
				}
				//排序
				sort_arr.sort();
				//for (var imageName:String in bmdDict)
				for each(imageName in sort_arr)
				{
					var name_arr:Array = imageName.split(".");
					var image_name_no_extention:String = name_arr[0];
					var extention:String = name_arr[1];
					if (extention == "png")
					{
						var bmd:BitmapData = bmdDict[imageName];
						var minRect:Rectangle = bmd.getColorBoundsRect(0xffffffff, 0x00000000, false);
						var minBmd:BitmapData;
						var imageInfo:String;
						if (minRect.width > 0 && minRect.height > 0)
						{
							minBmd = new BitmapData(minRect.width, minRect.height, true, 0);
							minBmd.copyPixels(bmd, minRect, destPoint, null, null, true);
							ImageCreator.createImage(this.nativePath + image_name_no_extention, minBmd);
							imageInfo = "{n:\"" + image_name_no_extention + "\",x:" + (minRect.x + _animation_box_x) + ",y:" + (minRect.y + _animation_box_y) + ",time:" + frameTime + "}";
						}
						else 
						{
							imageInfo = "{n:\"" + "" + "\",x:" + 0 + ",y:" + 0 + ",time:" + frameTime + "}";
						}
					}
					else 
					{
						var file:File = new File(this.nativePath + imageName);
						var copy_file:File = new File(this.nativePath + image_name_no_extention);
						file.copyTo(copy_file, true);
						imageInfo = "{n:\"" + image_name_no_extention + "\",x:" + 0 + ",y:" + 0 + ",time:" + frameTime + "}";
					}
					imageInfoArr.push(imageInfo);
				}
			}
			else
			{
				//var curFrameIndex:int = -1;
				var curFrameImage:String = "";
				var curFramesNum:int = 0;
				for (var i:int = 0; i < info_xml.sec.frame.length(); i++) 
				{
					//curFrameIndex++;
					curFramesNum++;
					var frame_xml:XML = info_xml.sec.frame[i];
					//image		空表示非关键帧,1...数字表示关键帧的对应png名字,“*”表示循环自第一帧开始,“#”表示在此帧结束不循环
					var temp_frame_image:String = String(frame_xml.@image);
					if (temp_frame_image == "")
					{
					}
					else
					{
						if (curFrameImage != "") 
						{
							image_name_no_extention = curFrameImage;
							extention = "png";
							imageName = image_name_no_extention + "." + extention;
							bmd = bmdDict[imageName];
							if (bmd == null)
							{
								Log.log("帧图片缺失:" + image_name_no_extention);
								extention = "jpg";
								imageName = image_name_no_extention + "." + extention;
								Log.log("尝试读取:" + imageName);
							}
							if (extention == "png")
							{
								minRect = bmd.getColorBoundsRect(0xffffffff, 0x00000000, false);
								if (minRect.width > 0 && minRect.height > 0)
								{
									minBmd = new BitmapData(minRect.width, minRect.height, true, 0);
									minBmd.copyPixels(bmd, minRect, destPoint, null, null, true);
									ImageCreator.createImage(this.nativePath + image_name_no_extention, minBmd);
									imageInfo = "{n:\"" + image_name_no_extention + "\",x:" + (minRect.x + _animation_box_x) + ",y:" + (minRect.y + _animation_box_y) + ",time:" + (frameTime * curFramesNum) + "}";
								}
								else 
								{
									imageInfo = "{n:\"" + "" + "\",x:" + 0 + ",y:" + 0 + ",time:" + (frameTime * curFramesNum) + "}";
								}
							}
							else 
							{
								file = new File(this.nativePath + imageName);
								copy_file = new File(this.nativePath + image_name_no_extention);
								file.copyTo(copy_file, true);
								imageInfo = "{n:\"" + image_name_no_extention + "\",x:" + 0 + ",y:" + 0 + ",time:" + (frameTime * curFramesNum) + "}";
							}
							imageInfoArr.push(imageInfo);
						}
						//
						if (temp_frame_image == "*")
						{
							loop = true;
							break;
						}
						else if (temp_frame_image == "#")
						{
							loop = false;
							break;
						}
						else 
						{
							//下一张图
							curFrameImage = temp_frame_image;
							curFramesNum = 0;
						}
					}
				}
			}
			info_xml = null;
			//var nativePath:String = nativePath;
			var nativePath:String = nativeFile.url;
			//{imageName:{x:100,y:100},imageName:{x:100,y:100}}
			//var imagesInfo:String = "{" + imageInfoArr.join(",") + "}";
			var imagesInfo:String = "[" + imageInfoArr.join(",") + "]";
			//
			var package_data:Object = { nativePath:nativePath, nativeFolderName:nativeFolderName, swfFolder:nativePath, isAnimation:true, frameNum:imageInfoArr.length, frameRate:frameRate, imagesInfo:imagesInfo };
			Log.log("处理完成，等待Flash打包资源完毕！");
			package_data.imageQuality = int(imageQuality_it.text);
			package_data.loop = loop_cb.selected;
			package_data.blend = addMode_cb.selected ? BlendMode.ADD : BlendMode.NORMAL;
			ExternalManager.callJsfl(package_data);
		}
		//---------------------------------------打包模式相关代码----------------------------------END
		
		//---------------------------------------swf查看模式相关代码----------------------------------
		private function clearAnimation():void
		{
			if (_animation)
			{
				_animation.setCache(null);
			}
			if (_cacheAnimation)
			{
				_cacheAnimation.dispose();
				_cacheAnimation = null;
			}
		}
		
		private function loop_cb_click():void 
		{
			if (_animation)
			{
				_animation.loop = loop_cb.selected;
				if (_animation.loop && !_animation.isPlay) 
				{
					_animation.play();
				}
			}
		}
		
		private function addMode_cb_click():void 
		{
			if (_animation)
			{
				_animation.blendMode = addMode_cb.selected ? BlendMode.ADD : BlendMode.NORMAL;
			}
		}
		
		private function play_btn_click():void 
		{
			if (_animation)
			{
				_animation.play();
			}
		}
		
		private function stop_btn_click():void 
		{
			if (_animation)
			{
				_animation.stop();
			}
		}
		
		private function clear_btn_click():void 
		{
			clearAnimation();
		}
		
		private function clear_bg_btn_click():void 
		{
			bg_im.url = null;
		}
		
		private var _cacheAnimation:BmrCacheAnimation;
		private var _animation:BmrAnimation;
		private function swf_load_complete(e:Event):void 
		{
			e.target.removeEventListener(Event.COMPLETE, swf_load_complete);
			var loader:Loader = e.target.loader as Loader;
			//
			var mc:MovieClip = loader.content as MovieClip;
			var frames:Vector.<BmrCacheFrame> = new Vector.<BmrCacheFrame>();
			var bmd_dict:Dictionary = new Dictionary();
			for each (var temp_info:Object in mc.positionInfo)
			{
				var bmd:BitmapData = null;
				if (temp_info.link)
				{
					bmd = bmd_dict[temp_info.link];
					if (bmd == null) 
					{
						var bmd_class:Class = loader.contentLoaderInfo.applicationDomain.getDefinition(temp_info.link) as Class;
						bmd = new bmd_class() as BitmapData;
						bmd_dict[temp_info.link] = bmd.clone();
						bmd.dispose();
						
						bmd = bmd_dict[temp_info.link];
					}
				}
				var image_x:int = temp_info.x;
				var image_y:int = temp_info.y;
				var time:int = temp_info.time;
				var bmrCacheFrame:BmrCacheFrame = new BmrCacheFrame(bmd, image_x, image_y, time);
				frames.push(bmrCacheFrame);
			}
			loader.unload();
			
			//清除临时位图字典
			for (var link:String in bmd_dict)
			{
				delete bmd_dict[link];
			}
			bmd_dict = null;
			clearAnimation();
			_cacheAnimation = new BmrCacheAnimation(frames, mc.frameRate, mc.loop, mc.blend);
			_animation.setCache(_cacheAnimation, true, _cacheAnimation.loop, false, Number(speedScale_it.text));
			setAnimationPosition();
			loop_cb.selected = _animation.loop;
			addMode_cb.selected = mc.blend == BlendMode.ADD;
		}
		//---------------------------------------swf查看模式相关代码----------------------------------END
		
		//---------------------------------------图集查看模式相关代码----------------------------------
		private var atlas_ani_url:String;
		private var atlas_json_url:String;
		private var atlas_png_url:String;
		private var atlas_json_data:Object;
		private function startAtlasAni(url:String):void
		{
			var ani_str:String = TxtGenerator.read(url);
			var ani_data:Object = JSON.parse(ani_str);
			animation_x_lb.text = "" + ani_data.x;
			animation_y_lb.text = "" + ani_data.y;
			frameRate_it.text = "" + Math.round(1000 / ani_data.interval);
			loop_cb.selected = ani_data.loop;
			addMode_cb.selected = ani_data.blend == "lighter";
			
			startAtlasJson(url.substr(0, url.length - 3) + "json");
		}
		
		private function startAtlasJson(url:String):void 
		{
			atlas_json_url = url;
			var json_file:File = new File(atlas_json_url);
			var json_name:String = json_file.name.substr(0, json_file.name.length - 5);
			var folder_file:File = json_file.parent;
			var atlas_folder_url:String = folder_file.nativePath;
			
			var json_str:String = TxtGenerator.read(atlas_json_url);
			atlas_json_data = JSON.parse(json_str);
			
			atlas_png_url = atlas_folder_url + "/" + atlas_json_data.meta.image;
			atlas_ani_url = atlas_folder_url + "/" + json_name + ".ani";
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, atlas_complete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, atlas_ioError);
			loader.load(new URLRequest(atlas_png_url));
		}
		
		private function atlas_complete(e:Event):void
		{
			e.target.removeEventListener(Event.COMPLETE, atlas_complete);
			e.target.removeEventListener(IOErrorEvent.IO_ERROR, atlas_ioError);
			Log.log("加载图集文件成功！" + atlas_png_url);
			
			var loader:Loader = e.target.loader as Loader;
			//
			var atlas_bmd:BitmapData = (loader.content as Bitmap).bitmapData;
			var frames:Vector.<BmrCacheFrame> = new Vector.<BmrCacheFrame>();
			var bmd_dict:Dictionary = new Dictionary();
			var time:int = Math.round(1000 / int(frameRate_it.text));
			var sourceRect:Rectangle = new Rectangle();
			var destPoint:Point = new Point();
			
			var frameObjArr:Array = [];
			var frame_Obj:Object;
			for (var frame_name:String in atlas_json_data.frames)
			{
				frame_Obj = atlas_json_data.frames[frame_name];
				frame_Obj.name = frame_name;
				frameObjArr.push(frame_Obj);
			}
			frameObjArr.sortOn("name");
			for each(frame_Obj in frameObjArr)
			{
				var frame_data:Object = frame_Obj.frame;
				var spriteSourceSize:Object = frame_Obj.spriteSourceSize;
				var bmd:BitmapData = new BitmapData(frame_data.w, frame_data.h, true, 0x0);
				sourceRect.x = int(frame_data.x);
				sourceRect.y = int(frame_data.y);
				sourceRect.width = int(frame_data.w);
				sourceRect.height = int(frame_data.h);
				bmd.copyPixels(atlas_bmd, sourceRect, destPoint, null, null, true);
				var bmrCacheFrame:BmrCacheFrame = new BmrCacheFrame(bmd, int(spriteSourceSize.x), int(spriteSourceSize.y), time);
				frames.push(bmrCacheFrame);
			}
			atlas_bmd.dispose();
			loader.unload();
			
			clearAnimation();
			_cacheAnimation = new BmrCacheAnimation(frames, int(frameRate_it.text), loop_cb.selected, (addMode_cb.selected ? BlendMode.ADD : BlendMode.NORMAL));
			_animation.setCache(_cacheAnimation, true, _cacheAnimation.loop, false, Number(speedScale_it.text));
			setAnimationPosition(int(animation_x_lb.text), int(animation_y_lb.text), true);
			_animation.blendMode = _cacheAnimation.blend;
		}
		
		private function atlas_ioError(e:IOErrorEvent):void
		{
			e.target.removeEventListener(Event.COMPLETE, atlas_complete);
			e.target.removeEventListener(IOErrorEvent.IO_ERROR, atlas_ioError);
			Log.log("加载图集文件失败！" + atlas_png_url);
		}
		
		private function ani_click():void
		{
			var json_obj:Object = { };
			json_obj.x = int(animation_x_lb.text);
			json_obj.y = int(animation_y_lb.text);
			json_obj.interval = Math.round(1000 / int(frameRate_it.text));
			json_obj.loop = loop_cb.selected;
			json_obj.blend = addMode_cb.selected ? "lighter" : BlendMode.NORMAL;
			var ani_str:String = JSON.stringify(json_obj);
			TxtGenerator.generate(atlas_ani_url, ani_str);
			Log.log("动画信息文件生成：" + atlas_ani_url);
		}
		//---------------------------------------图集查看模式相关代码----------------------------------END
	}
}