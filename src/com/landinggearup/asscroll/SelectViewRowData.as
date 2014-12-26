package com.landinggearup.asscroll
{
	
	internal final class SelectViewRowData extends ListViewRowData
	{
		public var object:Object;
		
		internal var selected:Boolean = false;
		internal var enabled:Boolean = true;
		
		public function SelectViewRowData()
		{
			super();
		}
	}
}