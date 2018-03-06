
package modules.EnumTool
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	
	public class myEventDispatcher extends EventDispatcher
	{
		private static var _instance:myEventDispatcher;
		public function myEventDispatcher(force:singletonForce,target:IEventDispatcher=null):void{
			super(target);
		}
		public static function getInstance():myEventDispatcher{
			if(_instance==null){
				_instance=new myEventDispatcher(new singletonForce(),null);
			}
			return _instance;		
		}
	}	
}
class singletonForce{ 
	public function singletonForce(){}
}