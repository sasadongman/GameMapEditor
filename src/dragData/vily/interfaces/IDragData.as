package dragData.vily.interfaces
{
	//dragData.vily.interfaces.IDragData
	/**
		本接口作为拖动数据,drop的时候获取实际得到的数据的对象接收数据的行为规范
	*/
	public interface IDragData{
		/**
			添加数据到接收者
			@param		obj:{format:"数据类型",data:*,x:0,y:0},format表示的数据类型都包含在dragData.vily.data.DragDataFormat中
						x和y属性记录了拖动时放开鼠标的位置坐标
		*/
		function setDragData(obj:Object):void;
		
		/**
			实现接口 dragData.vily.interfaces.IDragData 的方法
			添加数据到接收者
			@param		obj:{format:"数据类型",data:*},format表示的数据类型都包含在dragData.vily.data.DragDataFormat中
		
		public function setDragData(obj:Object):void{
			
		}
		*/
	}
}