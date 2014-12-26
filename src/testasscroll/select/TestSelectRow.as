package testasscroll.select
{
	import com.landinggearup.asscroll.ListViewRowData;
	import com.landinggearup.asscroll.SelectViewRow;
	
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class TestSelectRow extends SelectViewRow
	{
		private var txt:TextField;
		
		private var txtSelected:TextField;
		
		public function TestSelectRow()
		{
			super();
			
			txt = new TextField();
			addChild(txt);
			txt.x = 10;
			txt.y = 10;
			txt.mouseEnabled = false;
			txt.scrollRect = new Rectangle(0, 0, 100, 30);
			
			txtSelected = new TextField();
			txtSelected.filters = [new GlowFilter(0xffffff, 1, 2, 2, 2)];
			txtSelected.autoSize = TextFieldAutoSize.LEFT;
			txtSelected.defaultTextFormat = new TextFormat("Arial", 20, 0xff0000, true, false, true);
			addChild(txtSelected);
			txtSelected.x = 170;
			txtSelected.y = 10;
			txtSelected.text = "SELECTED";
			txtSelected.mouseEnabled = false;
			txtSelected.scrollRect = new Rectangle(0, 0, 120, 30);
			
			addEventListener(MouseEvent.CLICK, onRowClick, false, 0, true);
		}
		
		private function onRowClick(e:MouseEvent):void{
			if(this.enabledForSelection){
				notifySelect();
			}
		}
		
		override public function set data(value:ListViewRowData):void{
			super.data = value;
			
			var dt:TestSelectObject = this.object as TestSelectObject;
			
			graphics.clear();
			graphics.beginFill(dt.color, 1);
			graphics.drawRoundRect(0, 0, 290, value.rowHeight - 1, 10, 10);
			graphics.endFill();
			
			txt.text = dt.name;
		}
		
		override protected function updateEnableState(value:Boolean):void{
			if(value){
				this.transform.colorTransform = new ColorTransform();
			}else{
				this.transform.colorTransform = new ColorTransform(0.5, 0.5, 0.5);
			}
		}
		
		override protected function updateSelectState(value:Boolean):void{
			txtSelected.visible = value;
		}
		
		override protected function updateHighlightedState(value:Boolean):void{
			super.updateHighlightedState(value);
		}
	}
}