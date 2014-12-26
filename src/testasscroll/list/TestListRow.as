package testasscroll.list
{
	import com.landinggearup.asscroll.ListViewRow;
	import com.landinggearup.asscroll.ListViewRowData;
	
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	public class TestListRow extends ListViewRow
	{
		private var txt:TextField;
		
		public function TestListRow()
		{
			super();
			
			txt = new TextField();
			addChild(txt);
			txt.x = 10;
			txt.y = 10;
			txt.mouseEnabled = false;
			txt.scrollRect = new Rectangle(0, 0, 100, 30);
			
		}
		
		override public function set data(value:ListViewRowData):void{
			super.data = value;
			
			var dt:TestListRowData = value as TestListRowData;
			
			graphics.clear();
			graphics.beginFill(dt.color, 1);
			graphics.drawRoundRect(0, 0, 290, value.rowHeight - 1, 10, 10);
			graphics.endFill();
			
			txt.text = dt.name;
		}
	}
}