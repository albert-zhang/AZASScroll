package com.landinggearup.asscroll
{
	import flash.events.Event;
	
	public class ScrollViewEvent extends Event
	{
		public static const PAGE_CHANGED:String = "AZ.ScrollViewEvent.PAGE_CHANGED";
		
		public function ScrollViewEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}