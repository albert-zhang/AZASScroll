package testasscroll
{
	import com.landinggearup.asscroll.ListView;
	import com.landinggearup.asscroll.ListViewRowData;
	import com.landinggearup.asscroll.ScrollView;
	import com.landinggearup.asscroll.SizeInt;
	import testasscroll.list.TestListRow;
	import testasscroll.list.TestListRow2;
	import testasscroll.list.TestListRowData;
	import testasscroll.select.TestSelectView;
	
	import flash.display.Loader;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.text.TextField;
	
	public class AZASScroll extends Sprite
	{
		private var dummy1:TestListRow;
		private var dummy2:TestListRow2;
		
		private var btnScroll:SimpleButton;
		private var btnList:SimpleButton;
		private var btnSelect:SimpleButton;
		private var btnMultiSelect:SimpleButton;
		
		private var canvas:Sprite;
		
		private var scrollView:ScrollView;
		private var listView:ListView;
		private var selectView:TestSelectView;
		
		private var viewPort:Rectangle;
		
		
		public function AZASScroll()
		{
			super();
			
			// support autoOrients
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 30;
			
			viewPort = new Rectangle(0, 0, stage.fullScreenWidth - 20, stage.fullScreenHeight - 70);
			
			btnScroll = Util.createButton("ScrollView", testScroll);
			btnList = Util.createButton("ListView", testList);
			btnSelect = Util.createButton("SelectView", testSelect);
			btnMultiSelect = Util.createButton("SelectView\n(Multiple)", testMultiple);
			
			addChild(btnScroll);
			addChild(btnList);
			addChild(btnSelect);
			addChild(btnMultiSelect);
			
			btnScroll.x = 10;
			btnList.x = 120;
			btnSelect.x = 230;
			btnMultiSelect.x = 340;
			
			btnScroll.y = 10;
			btnList.y = 10;
			btnSelect.y = 10;
			btnMultiSelect.y = 10;
			
			canvas = new Sprite();
			canvas.graphics.beginFill(0xeeeeee, 1);
			canvas.graphics.drawRect(0, 0, viewPort.width, viewPort.height);
			canvas.graphics.endFill();
			addChild(canvas);
			canvas.x = 10;
			canvas.y = 60;
		}
		
		
		private function clean():void{
			while(canvas.numChildren > 0){
				canvas.removeChildAt(0);
			}
			if(scrollView){
				scrollView.release();
				scrollView = null;
			}
			if(listView){
				listView.release();
				listView = null;
			}
			if(selectView){
				selectView.release();
				selectView = null;
			}
		}
		
		
		private function testScroll(e:MouseEvent):void{
			this.clean();
			
			scrollView = new ScrollView();
			scrollView.viewportSize = new SizeInt(300, 300);
			canvas.addChild(scrollView);
			scrollView.x = 10;
			scrollView.y = 10;
			
			var ldr:Loader = new Loader();
			ldr.load(new URLRequest("assets/pic.jpg"));
			scrollView.addChild(ldr);
			scrollView.contentSize = new SizeInt(1920, 1200); // 1920x1200 is the dimension of the picture
		}
		private function testList(e:MouseEvent):void{
			this.clean();
			
			listView = new ListView(false);
			listView.viewportSize = new SizeInt(300, 450);
			listView.setRowQualifiedClassNameForRowReusableIdentifier(
				"testasscroll.list.TestListRow",
				ListViewRowData.DefaultReusableIdentifier);
			listView.setRowQualifiedClassNameForRowReusableIdentifier(
				"testasscroll.list.TestListRow2",
				"another");
			canvas.addChild(listView);
			listView.x = 10;
			listView.y = 10;
			
			const RR:int = 30;
			
			var header:Sprite = new Sprite();
			header.graphics.beginFill(0xff0000, 1);
			header.graphics.drawRoundRect(0, 0, 290, RR, RR, RR);
			header.graphics.endFill();
			var txh:TextField = new TextField();
			txh.textColor = 0xffffff;
			header.addChild(txh);
			txh.x = 10;
			txh.y = 10;
			txh.text = "This is Header";
			
			var footer:Sprite = new Sprite();
			footer.graphics.beginFill(0xff0000, 1);
			footer.graphics.drawRoundRect(0, 0, 290, RR, RR, RR);
			footer.graphics.endFill();
			var txf:TextField = new TextField();
			txf.textColor = 0xffffff;
			footer.addChild(txf);
			txf.x = 10;
			txf.y = 10;
			txf.text = "This is Footer";
			
			listView.headerView = header;
			listView.headerHeight = RR;
			listView.footerView = footer;
			listView.footerHeight = RR;
			
			var dts:Vector.<ListViewRowData> = new Vector.<ListViewRowData>();
			for(var i:int=0; i<100; i++){
				var dt:TestListRowData = new TestListRowData();
				dt.rowHeight = 40;
				var c:uint = 0x888888 * Math.random() + 0x888888
				dt.color = c;
				dt.name = "Row - "+ (i + 1);
				if((i + 1) % 10 == 0){
					dt.reusableIdentifier = "another";
					dt.rowHeight = 100;
					dt.color = 0xff0000;
				}
				dts.push(dt);
			}
			listView.dataProvider = dts;
			
		}
		private function testSelect(e:MouseEvent):void{
			this.clean();
			
			selectView = new TestSelectView(new Rectangle(0, 0, 300, 450), false);
			canvas.addChild(selectView);
			selectView.x = 10;
			selectView.y = 10;
		}
		private function testMultiple(e:MouseEvent):void{
			this.clean();
			
			selectView = new TestSelectView(new Rectangle(0, 0, 300, 450), true);
			canvas.addChild(selectView);
			selectView.x = 10;
			selectView.y = 10;
		}
	}
}