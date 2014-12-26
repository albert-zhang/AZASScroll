package com.landinggearup.asscroll
{
	import flash.display.Sprite;
	
	public class ListViewRow extends Sprite
	{
		internal var index:int = -1;
		
		protected var _data:ListViewRowData;
		
		public function ListViewRow()
		{
			super();
		}
		
		public function release():void{
			
		}
		
		/**
		 * Override must call super
		 */
		public function set data(value:ListViewRowData):void{
			_data = value;
		}
		public final function get data():ListViewRowData{
			return _data;
		}
		
	}
}