package dragData.vily.utils
{
	//dragData.vily.utils.DragDataParser

	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.BitmapData;
	import flash.filesystem.File;
	
	import dragData.vily.data.DragDataFormat;
	
	public class DragDataParser{
		public static var DRAG_FORMAT:String = "drag_data";		
		public function DragDataParser(){			
		}
		
		/**
          * get data from a Clipboard object.
          * 
          * @param data The Clipboard object
          * @param placeX The new scrap x coordinate.
          * @param placeY The new scrap y coordinate.
          * @param action The copy or move actions
          * 
          */
         public static function parseData(data:Clipboard, action:String):Object{
         	//trace("data.hasFormat(ClipboardFormats.URL_FORMAT):" + data.hasFormat(ClipboardFormats.URL_FORMAT));
         	//trace("DragDataParser: "+data.formats.length + " formats found: " + " " + data.formats);
            if(data.hasFormat(DragDataParser.DRAG_FORMAT)){	           
				trace("create drag obj self");
            } else if(data.hasFormat(ClipboardFormats.BITMAP_FORMAT)){
				//trace("data.hasFormat(ClipboardFormats.BITMAP_FORMAT)");
    	        return {format:DragDataFormat.BITMAPDATA_FORMAT, data:BitmapData(data.getData(ClipboardFormats.BITMAP_FORMAT))};
				
			} else if(data.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)){
				//trace("data.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)");
				//var dropfiles:File = data.getData(ClipboardFormats.FILE_LIST_FORMAT) as File;
    	        //trace(dropfiles);
				//trace(dropfiles.name);
				//trace(dropfiles.nativePath);
				
				var dropfiles:Array = data.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
				var i:int = 0;
				for each (var file:File in dropfiles)
				{					
					if(i < 1){
						//得到文件file数据
						return parseFile(file);
						break;
					}else{
						break;
					}
					i++;
				}
            }else if (data.hasFormat(ClipboardFormats.TEXT_FORMAT)) {
				//trace("data.hasFormat(ClipboardFormats.TEXT_FORMAT)");
				return {format:DragDataFormat.TEXT_FORMAT, data:String(data.getData(ClipboardFormats.TEXT_FORMAT))};
				
            }else if (data.hasFormat(ClipboardFormats.URL_FORMAT)) {
				//trace("data.hasFormat(ClipboardFormats.URL_FORMAT)");
				return {format:DragDataFormat.HTML_URL_FORMAT, data:String(data.getData(ClipboardFormats.URL_FORMAT))};
            }
			
			return {format:DragDataFormat.UNDEFINED_FORMAT, data:null};
		}
		
		public static function parseFile(file:File):Object{
			
			switch(file.extension){
				case "jpg":
				case "png":
				case "gif":
					return {format:DragDataFormat.FILE_URL_FORMAT, data:file.url};
					break;
				case "swf" :
                    return {format:DragDataFormat.SWF_FORMAT, data:file.url};
                    break;
				default:					
					//就仅仅加载图标进来
					//return {format:DragDataFormat.BITMAPDATA_FORMAT, data:file.icon.bitmaps.shift()};
					//return {format:DragDataFormat.FILE_URL_FORMAT, data:file.url};
					return {format:DragDataFormat.FILE_URL_FORMAT, data:file.nativePath};
			}
			return {format:DragDataFormat.UNDEFINED_FORMAT, data:null};
		}
		
	}
}