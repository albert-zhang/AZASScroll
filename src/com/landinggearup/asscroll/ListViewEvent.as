package com.landinggearup.asscroll
{
	import flash.events.Event;
	
	public class ListViewEvent extends Event
	{
		/**
		 * Fire when a row created. The row is reused so not every show of a row will fire this event.
		 */
		public static const CREATE_ROW:String = "AZ.ListViewEvent.CREATE_ROW";
		
		public var loadedRow:ListViewRow;
		
		public function ListViewEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}