package modules.EnumTool
{
	import flash.events.Event;

	public class myEvent extends Event
	{
		public var id:String="";
		public var index:uint=0;
		
				
		public function myEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);			
		}
		public function dispatchEvent():void{
			myEventDispatcher.getInstance().dispatchEvent(this);
		}
	}
}