package com.easily.util 
{
	/**
	 * ...
	 * @author ...
	 */
	public class AsyncResponder 
	{
		private var _result:Function;
		private var _fault:Function;
		private var _token:Object;
		public function AsyncResponder(result:Function, fault:Function, token:Object = null) 
		{
			_result = result;
			_fault = fault;
			_token = token;
		}
		public function fault(info:Object):void
		{
			_fault(info, _token);
		}
		public function result(data:Object):void
		{
			_result(data, _token);
		}
	}

}