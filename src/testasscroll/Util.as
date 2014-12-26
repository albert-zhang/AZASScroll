package testasscroll
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public class Util
	{
		public static function createButton(title:String, handler:Function):SimpleButton{
			const W:int = 100;
			const H:int = 36;
			
			var sp1:Sprite = new Sprite();
			sp1.graphics.beginFill(0x666666, 1);
			sp1.graphics.drawRoundRect(0, 0, W, H, H, H);
			sp1.graphics.endFill();
			
			var tx:TextField = new TextField();
			tx.embedFonts = false;
			tx.autoSize = TextFieldAutoSize.LEFT;
			tx.multiline = true;
			tx.defaultTextFormat = new TextFormat("Arial", 10, 0xffffff, null, null, null, null, null, TextFormatAlign.CENTER);
			sp1.addChild(tx);
			tx.text = title;
			tx.x = (W - tx.width) / 2;
			tx.y = (H - tx.height) / 2;
			
			var sp2:Sprite = new Sprite();
			sp2.graphics.beginFill(0x333333, 1);
			sp2.graphics.drawRoundRect(0, 0, W, H, H, H);
			sp2.graphics.endFill();
			
			var btn:SimpleButton = new SimpleButton(sp1, sp1, sp2, sp2);
			btn.addEventListener(MouseEvent.CLICK, handler, false, 0, true);
			return btn;
		}
	}
}