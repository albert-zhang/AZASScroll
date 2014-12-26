package com.landinggearup.asscroll
{
	
	/**
	 */
	
	public class SizeInt
	{
		
		public var width:int;
		public var height:int;
		
		public function SizeInt(w:int=0, h:int=0)
		{
			width = w;
			height = h;
		}
		
		public function toString():String{
			return "[object SizeInt] (width="+ width +", height="+ height +")";
		}
		
		public function clone():SizeInt{
			return new SizeInt(width, height);
		}
		
		public function isEqual(sz:SizeInt):Boolean{
			if(this == sz){
				return true;
			}
			return (sz.width == this.width && sz.height == this.height);
		}
		
	}
}