package com.landinggearup.asscroll
{
	public class ListViewRowData extends Object
	{
		public static const DefaultReusableIdentifier:String = "__Default";
		
		/**
		 * The index of the row data in the dataProvider
		 */
		internal var index:int = -1;
		
		public var reusableIdentifier:String = DefaultReusableIdentifier;
		
		protected var _rowHeight:int;
		
		public function ListViewRowData()
		{
			super();
		}
		
		
		public final function get rowHeight():int{
			return _rowHeight;
		}
		
		public final function set rowHeight(value:int):void{
			_rowHeight = value;
		}
		
	}
}
