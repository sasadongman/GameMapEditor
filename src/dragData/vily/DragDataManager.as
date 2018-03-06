package dragData.vily
{
	//dragData.vily.DragDataManager
	
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	
	import flash.events.NativeDragEvent;
	import flash.desktop.NativeDragOptions;
	import flash.desktop.NativeDragActions;
	import flash.desktop.NativeDragManager;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	
	import dragData.vily.interfaces.IDragData;
	import dragData.vily.utils.DragDataParser;
	
	/**
		本类用于实现拖动数据的行为管理
	*/
	public class DragDataManager{
		
		//定义拖动到可以放下的目标区的显示对象
		private var _targetSpr:Sprite = null;
		private var _receiver:IDragData = null;
		public function DragDataManager():void {
			
		}
		public function initState():void{
			
		}
		/**
			设置拖动到可以放下的目标区的显示对象
		*/
		public function setTarget(spr:Sprite):void{
			if(_targetSpr != spr){
				_targetSpr = spr;
				addDragTargetListener(_targetSpr);
			}
		}
		/**
			清除拖动到可以放下的目标区的显示对象
		*/
		public function clearTarget():void{
			if(_targetSpr != null){
				removeDragTargetListener(_targetSpr);
				_targetSpr = null;
			}
		}
		/**
			设置接收拖动得到的数据对象
		*/
		public function setReceiver(obj:IDragData):void{
			_receiver = obj;
		}
		/**
			设置接收拖动得到的数据对象
		*/
		public function clearReceiver():void{
			_receiver = null;
		}
		
		private function addDragTargetListener(spr:Sprite):void{
			spr.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER,nativeDragEnter);
			spr.addEventListener(NativeDragEvent.NATIVE_DRAG_OVER,nativeDragOver);
			spr.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP,nativeDragDrop);
			spr.addEventListener(NativeDragEvent.NATIVE_DRAG_EXIT,nativeDragExit);
		}
		private function removeDragTargetListener(spr:Sprite):void{
			spr.removeEventListener(NativeDragEvent.NATIVE_DRAG_ENTER,nativeDragEnter);
			spr.removeEventListener(NativeDragEvent.NATIVE_DRAG_OVER,nativeDragOver);
			spr.removeEventListener(NativeDragEvent.NATIVE_DRAG_DROP,nativeDragDrop);
			spr.removeEventListener(NativeDragEvent.NATIVE_DRAG_EXIT,nativeDragExit);
		}
		
		private function nativeDragEnter(evt:NativeDragEvent):void{
			//trace("native drag enter");
			var transferable:Clipboard = evt.clipboard;
			if(transferable.hasFormat(ClipboardFormats.BITMAP_FORMAT) ||
				transferable.hasFormat(ClipboardFormats.FILE_LIST_FORMAT) ||
				transferable.hasFormat(ClipboardFormats.TEXT_FORMAT) ||
				transferable.hasFormat(ClipboardFormats.URL_FORMAT) ||
				transferable.hasFormat(DragDataParser.DRAG_FORMAT)){
					//NativeDragManager.acceptDragDrop((evt.target as Sprite));
					NativeDragManager.acceptDragDrop((evt.target as InteractiveObject));
					NativeDragManager.dropAction = NativeDragActions.MOVE;
			} else {
				trace("Unrecognized format");
			}
		}
		private function nativeDragOver(evt:NativeDragEvent):void{
			//trace("native drag over");
		}
		private function nativeDragDrop(evt:NativeDragEvent):void{
			//trace("native drag drop,evt.dropAction: "+evt.dropAction);
			/*var spr:DragSpr = DragSpr.createDragSpr(evt.clipboard, evt.stageX, evt.stageY, evt.dropAction);
			if(spr != null){
				this.addChild(spr);				
				
			}*/
			var obj:Object = DragDataParser.parseData(evt.clipboard, evt.dropAction);
			obj.x = evt.stageX;
			obj.y = evt.stageY;
			if(_receiver != null && obj != null){
				_receiver.setDragData(obj);
			}
		}
		private function nativeDragExit(evt:NativeDragEvent):void{
			//trace("native drag exit");
		}
		
		/*private function keyDownHandler(evt:KeyboardEvent):void{
			
			if(evt.keyCode == 67){
				DragSpr.isCtrKeyDown = true;
			}
		}
		private function keyUpHandler(evt:KeyboardEvent):void{
			//ctrl键
			if(evt.keyCode == 67){
				DragSpr.isCtrKeyDown = false;
			}
		}*/
	}
}