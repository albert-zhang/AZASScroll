package com.landinggearup.asscroll
{
	import flash.events.Event;
	
	internal class SelectViewRowEvent extends Event
	{
		public static const SELECT:String = "AZ.SelectViewRowEvent.SELECT";
		public static const CUSTOM_EVENT:String = "AZ.SelectViewRowEvent.CUSTOM_EVENT";
		
		public var customInfo:Object;
		public var row:SelectViewRow;
		
		public function SelectViewRowEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}