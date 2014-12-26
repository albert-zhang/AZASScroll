package com.landinggearup.asscroll
{	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	
	public class SelectViewRow extends ListViewRow
	{
		private var _selected:Boolean = false;
		private var _enabled:Boolean = true;
		
		private var isMouseDown:Boolean;
		
		
		public function SelectViewRow()
		{
			super();
			addEventListener(MouseEvent.MOUSE_DOWN, onSelectViewRowMouseDown, false, 0, true);
			addEventListener(MouseEvent.MOUSE_UP, onSelectViewRowMouseUp, false, 0, true);
			addEventListener(MouseEvent.MOUSE_OUT, onSelectViewRowMouseUp, false, 0, true);
			
			addEventListener(Event.ADDED_TO_STAGE, onSelectViewRowAddedToStage, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, onSelectViewRowRemovedToStage, false, 0, true);
		}
		
		private function onSelectViewRowAddedToStage(e:Event):void{
		}
		
		private function onSelectViewRowRemovedToStage(e:Event):void{
		}
		
		private function onSelectViewRowMouseDown(e:MouseEvent):void{
			if(_enabled){
				isMouseDown = true;
				this.updateHighlightedState(true);
			}
		}
		
		private function onSelectViewRowMouseUp(e:Event):void{
			if(isMouseDown){
				this.updateHighlightedState(false);
			}
			isMouseDown = false;
		}
		
		
		protected function updateHighlightedState(value:Boolean):void{
			if(value){
				var s:Number = 0.7;
				this.transform.colorTransform = new ColorTransform(s, s, s, 1, 0, 0, 0, 0);
			}else{
				this.transform.colorTransform = new ColorTransform();
			}
		}
		
		
		internal function get selected():Boolean{
			return _selected;
		}
		internal function set selected(value:Boolean):void{
			_selected = value;
			this.updateSelectState(_selected);
		}
		
		protected function updateSelectState(value:Boolean):void{
			
		}
		
		
		internal function get enabled():Boolean{
			return _enabled;
		}
		internal function set enabled(value:Boolean):void{
			_enabled = value;
			this.updateEnableState(_enabled);
		}
		
		
		protected function updateEnableState(value:Boolean):void{
			this.mouseEnabled = value;
			this.mouseChildren = value;
			if(value){
				this.alpha = 1;
				this.transform.colorTransform = new ColorTransform();
			}else{
				this.alpha = 0.8;
			}
		}
		
		
		override public function set data(value:ListViewRowData):void{
			super.data = value;
			
			var rowDt:SelectViewRowData = value as SelectViewRowData;
			this.selected = rowDt.selected;
			this.enabled = rowDt.enabled;
		}
		
		
		protected final function notifySelect():void{
			var evt:SelectViewRowEvent = new SelectViewRowEvent(SelectViewRowEvent.SELECT);
			evt.row = this;
			this.dispatchEvent(evt);
		}
		
		protected final function dispatchCustomEvent(customInfo:Object):void{
			var evt:SelectViewRowEvent = new SelectViewRowEvent(SelectViewRowEvent.CUSTOM_EVENT);
			evt.customInfo = customInfo;
			evt.row = this;
			this.dispatchEvent(evt);
		}
		
		protected final function get object():Object{
			var rowDt:SelectViewRowData = this.data as SelectViewRowData;
			return rowDt.object;
		}
		
		protected final function get enabledForSelection():Boolean{
			return _enabled;
		}
		
	}
}