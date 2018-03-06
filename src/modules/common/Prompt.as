package modules.common 
{
	import morn.common.PromptUI;
	
	/**
	 * ...
	 * @author Alex
	 */
	public class Prompt extends PromptUI 
	{
		public function Prompt() 
		{
			super();
			this.mouseChildren = this.mouseEnabled = false;
		}
	}
}