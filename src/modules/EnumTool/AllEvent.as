package modules.EnumTool 
{
	/**
	 * ...
	 * @author Charbo
	 */
	public class AllEvent extends myEvent 
	{
		public static const LOAD_COMPLETE:String = "load_complete";
		public function AllEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
		} 
		
	}
	
}