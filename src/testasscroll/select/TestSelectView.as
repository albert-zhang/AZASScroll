package testasscroll.select
{
	import com.landinggearup.asscroll.SelectView;
	import com.landinggearup.asscroll.SelectViewItemConfig;
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;

	public class TestSelectView extends Sprite
	{
		private var dummy1:TestSelectRow;
		private var selectView:SelectView;
		
		public function TestSelectView(frame:Rectangle, multipleSelect:Boolean)
		{
			super();
			
			selectView = new SelectView(frame);
			addChild(selectView);
			
			var configs:Vector.<SelectViewItemConfig> = new Vector.<SelectViewItemConfig>();
			
			for(var i:int=0; i<100; i++){
				var dt:TestSelectObject = new TestSelectObject();
				var c:uint = 0x666666 * i / 100 + 0x666666;
				dt.color = c;
				dt.name = "Row - "+ (i + 1);
				
				var cfg:SelectViewItemConfig = new SelectViewItemConfig();
				cfg.rowHeight = 40;
				cfg.rowReusableIdentifier = "Default";
				cfg.object = dt;
				
				configs.push(cfg);
			}
			
			selectView.setRowQualifiedClassNameForRowReusableIdentifier(
				"testasscroll.select.TestSelectRow",
				"Default");
			
			selectView.itemConfigs = configs;
			selectView.allowMultipleSelection = multipleSelect;
			if(multipleSelect){
				selectView.limitToCount = 4;
			}
		}
		
		public function release():void{
			selectView.release();
		}
	}
}