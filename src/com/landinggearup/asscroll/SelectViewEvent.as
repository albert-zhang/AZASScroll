package com.landinggearup.asscroll
{
	import flash.events.Event;
	
	internal class SelectViewEvent extends Event
	{
		public static const CUSTOM_EVENT:String = "AZ.SelectViewEvent.CUSTOM_EVENT";
		public static const SELECTION_CHANGE:String = "AZ.SelectViewEvent.SELECTION_CHANGE";
		
		public var row:SelectViewRow;
		public var object:Object;
		public var customInfo:Object;
		
		public function SelectViewEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}