package testasscroll.list
{
	import com.landinggearup.asscroll.ListViewRow;
	import com.landinggearup.asscroll.ListViewRowData;
	
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	public class TestListRow2 extends ListViewRow
	{
		private var txt:TextField;
		private var txt2:TextField;
		
		public function TestListRow2()
		{
			super();
			
			txt = new TextField();
			addChild(txt);
			txt.x = 200;
			txt.y = 10;
			txt.mouseEnabled = false;
			txt.scrollRect = new Rectangle(0, 0, 100, 30);
			
			txt2 = new TextField();
			addChild(txt2);
			txt2.x = 10;
			txt2.y = 10;
			txt2.mouseEnabled = false;
			txt2.scrollRect = new Rectangle(0, 0, 100, 30);
			txt2.text = "Style 2 row";
			
		}
		
		override public function set data(value:ListViewRowData):void{
			super.data = value;
			
			var dt:TestListRowData = value as TestListRowData;
			
			graphics.clear();
			graphics.beginFill(dt.color, 1);
			graphics.drawRoundRect(0, 0, 290, value.rowHeight - 1, 10, 10);
			graphics.endFill();
			
			graphics.lineStyle(2, 0xffffff, 1);
			for(var i:int=10; i<=value.rowHeight-10; i+= 4){
				graphics.moveTo(10, i);
				graphics.lineTo(280, i);
			}
			
			txt.text = dt.name;
		}
	}
}