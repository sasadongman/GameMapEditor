package modules 
{
	import flash.events.KeyboardEvent;
	
	/**
	 * ...
	 * @author Alex
	 */
	public interface IKeyboardPage extends IPage 
	{
		function keyHandle(e:KeyboardEvent):void;
	}
	
}