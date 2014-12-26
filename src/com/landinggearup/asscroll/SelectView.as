package com.landinggearup.asscroll
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	public class SelectView extends ListView
	{
		public var allowMultipleSelection:Boolean = false;
		
		public var limitToCount:int = -1;
		
		protected var _itemConfigs:Vector.<SelectViewItemConfig>;
		
		protected var _lastSelectedObject:Object;
		
		protected var _selectedObjects:Vector.<Object> = new Vector.<Object>();
		
		protected var _frame:Rectangle;
		
		public function SelectView(frame:Rectangle, isHorizontal:Boolean=false)
		{
			super(isHorizontal);
			
			this.setFrameInner(frame);
		}
		
		override public function release():void{
			super.release();
		}
		
		
		override protected function onAddedToStage(e:Event):void{
			super.onAddedToStage(e);
		}
		
		override protected function onRemovedFromStage(e:Event):void{
			super.onRemovedFromStage(e);
		}
		
		override protected function onEnterFrame(e:Event):void{
			super.onEnterFrame(e);
		}
		
		
		private function setFrameInner(f:Rectangle):void{
			_frame = f;
			var sz:SizeInt = new SizeInt(f.width, f.height);
			this.viewportSize = sz;
			this.x = f.x;
			this.y = f.y;
		}
		
		public function setFrame(value:Rectangle):void{
			this.setFrameInner(value);
		}
		
		
		override protected function createNewRow(rowReusaleIdentifier:String):ListViewRow{
			var row:ListViewRow = super.createNewRow(rowReusaleIdentifier);
			row.addEventListener(SelectViewRowEvent.SELECT, onSelectRow, false, 0, true);
			row.addEventListener(SelectViewRowEvent.CUSTOM_EVENT, onCustomEvent, false, 0, true);
			return row;
		}
		
		
		public final function get selectedObjects():Vector.<Object>{
			return _selectedObjects;
		}
		
		public final function set selectedObjects(value:Vector.<Object>):void{
			var i:int;
			
			_selectedObjects.splice(0, _selectedObjects.length);
			if(value){
				for(i=0; i<value.length; i++){
					_selectedObjects.push(value[i]);
				}
			}
			
			if(! this.allowMultipleSelection && _selectedObjects.length > 0){
				_lastSelectedObject = _selectedObjects[0];
			}else{
				_lastSelectedObject = null;
			}
			
			if(this.dataProvider){
				for(i=0; i<this.dataProvider.length; i++){
					var rowDt:SelectViewRowData = this.dataProvider[i] as SelectViewRowData;
					var foundInSelected:Boolean = (_selectedObjects.indexOf(rowDt.object) >= 0);
					if(rowDt.selected != foundInSelected){
						rowDt.selected = foundInSelected;
						
						var row:SelectViewRow = SelectViewRow(this.rowForData(rowDt));
						if(row){
							row.selected = foundInSelected;
						}
					}
				}
				
				this.checkLimitCount();
			}
			
		}
		
		public final function checkLimitCount():void{
			if(! this.dataProvider){
				return;
			}
			
			if(this.limitToCount <= 0 || this.limitToCount >= this.dataProvider.length){
				return;
			}
			
			var i:int;
			var rowDt:SelectViewRowData;
			var row:SelectViewRow;
			
			if(_selectedObjects.length >= this.limitToCount){
				for(i=0; i<this.dataProvider.length; i++){
					rowDt = this.dataProvider[i] as SelectViewRowData;
					var foundInSelected:Boolean = (_selectedObjects.indexOf(rowDt.object) >= 0);
					if(rowDt.enabled != foundInSelected){
						rowDt.enabled = foundInSelected;
						
						row = SelectViewRow(this.rowForData(rowDt));
						if(row){
							row.enabled = foundInSelected;
						}
					}
				}
			}else{
				for(i=0; i<this.dataProvider.length; i++){
					rowDt = this.dataProvider[i] as SelectViewRowData;
					if(! rowDt.enabled){
						rowDt.enabled = true;
						
						row = SelectViewRow(this.rowForData(rowDt));
						if(row){
							row.enabled = true;
						}
					}
				}
			}
		}
		
		
		public function get itemConfigs():Vector.<SelectViewItemConfig>{
			return _itemConfigs;
		}
		public function set itemConfigs(value:Vector.<SelectViewItemConfig>):void{
			_itemConfigs = value;
			this.reloadObjects();
		}
		
		
		public function reloadObjects():void{
			var finalRows:Vector.<ListViewRowData> = new Vector.<ListViewRowData>();
			
			for(var i:int=0; i<_itemConfigs.length; i++){
				var bd:Object = _itemConfigs[i].object;
				
				var enabled:Boolean = true;
				var selected:Boolean = (_selectedObjects.indexOf(bd) >= 0);
				
				var rowDt:SelectViewRowData = new SelectViewRowData();
				rowDt.object = bd;
				rowDt.rowHeight = _itemConfigs[i].rowHeight;
				rowDt.reusableIdentifier = _itemConfigs[i].rowReusableIdentifier;
				rowDt.enabled = enabled;
				rowDt.selected = selected;
				
				finalRows.push(rowDt);
			}
			
			super.dataProvider = finalRows;
			
			this.checkLimitCount();
		}
		
		
		private function onSelectRow(e:SelectViewRowEvent):void{
			var i:int;
			
			var row:SelectViewRow = e.row;
			var rowDt:SelectViewRowData = row.data as SelectViewRowData;
			
			if(this.allowMultipleSelection){
				row.selected = ! row.selected;
				rowDt.selected = ! rowDt.selected;
				
				if(rowDt.selected){
					if(_selectedObjects.indexOf(rowDt.object) < 0){
						_selectedObjects.push(rowDt.object);
					}
				}else{
					var existIndex:int = _selectedObjects.indexOf(rowDt.object);
					if(existIndex >= 0){
						_selectedObjects.splice(existIndex, 1);
					}
				}
				
				this.checkLimitCount();
				
			}else{
				var lastSelectedRowData:SelectViewRowData = this.rowDataOfObject(_lastSelectedObject);
				
				if(lastSelectedRowData){
					if(rowDt != lastSelectedRowData){
						// deselecte old row and data:
						lastSelectedRowData.selected = false;
						var lastSelectedRow:SelectViewRow = this.rowForData(lastSelectedRowData) as SelectViewRow;
						if(lastSelectedRow){
							lastSelectedRow.selected = false;
						}
						// select new row:
						rowDt.selected = true;
						row.selected = true;
						_lastSelectedObject = rowDt.object;
					}
				}else{
					rowDt.selected = true;
					row.selected = true;
					_lastSelectedObject = rowDt.object;
				}
				
				_selectedObjects.splice(0, _selectedObjects.length);
				_selectedObjects.push(_lastSelectedObject);
				
			}
			
			this.mouseChildren = false;
			this.mouseEnabled = false;
			
			// wait for one frame to let the select effect show
			var tmr:Timer = new Timer(1000 / stage.frameRate);
			tmr.addEventListener(TimerEvent.TIMER, doSelectionChange, false, 0, false);
			tmr.start();
		}
		
		private function doSelectionChange(e:TimerEvent):void{
			var tmr:Timer = e.currentTarget as Timer;
			tmr.removeEventListener(TimerEvent.TIMER, doSelectionChange, false);
			
			this.mouseChildren = true;
			this.mouseEnabled = true;
			
			var evt:SelectViewEvent = new SelectViewEvent(SelectViewEvent.SELECTION_CHANGE);
			dispatchEvent(evt);
		}
		
		private function onCustomEvent(e:SelectViewRowEvent):void{
			var evt:SelectViewEvent = new SelectViewEvent(SelectViewEvent.CUSTOM_EVENT);
			evt.row = e.row;
			evt.customInfo = e.customInfo;
			evt.object = (e.row.data as SelectViewRowData).object;
			dispatchEvent(evt);
		}
		
		
		
		private function rowDataOfObject(object:Object):SelectViewRowData{
			for(var i:int=0; i<this.dataProvider.length; i++){
				var rowDt:SelectViewRowData = this.dataProvider[i] as SelectViewRowData;
				if(rowDt.object == object){
					return rowDt;
				}
			}
			return null;
		}
		
		public final function setObjectSelected(object:Object, selected:Boolean):void{
			var rowDtIndex:int = -1;
			var rowDt:SelectViewRowData;
			
			var i:int;
			for(i=0; i<this.dataProvider.length; i++){
				rowDt = this.dataProvider[i] as SelectViewRowData;
				if(rowDt.object == object){
					rowDtIndex = i;
					break;
				}
			}
			
			if(rowDtIndex >= 0){
				var index:int = _selectedObjects.indexOf(object);
				rowDt = this.dataProvider[rowDtIndex] as SelectViewRowData;
				rowDt.selected = selected;
				
				var row:SelectViewRow = SelectViewRow(this.rowForData(rowDt));
				if(row){
					row.selected = selected;
				}
				
				if(selected){
					if(index < 0){
						_selectedObjects.push(object);
					}
				}else{
					if(index >= 0){
						_selectedObjects.splice(index, 1);
					}
				}
				
				this.checkLimitCount();
				
			}else{
				trace("Warning: BaseObjectSelectView.setDataSelected, but the object was not found.");
				
			}
			
		}
		
		
		
		public final function rowForObject(object:Object):SelectViewRow{
			if(! this.dataProvider){
				return null;
			}
			
			var foundBosvRowDt:SelectViewRowData = null;
			
			var rowDts:Vector.<ListViewRowData> = this.dataProvider;
			for each(var rowDt:ListViewRowData in rowDts){
				var bosvRowDt:SelectViewRowData = rowDt as SelectViewRowData;
				if(! bosvRowDt){
					trace("Error: is not a BaseObjectSelectViewRowData: "+ rowDt);
				}
				if(bosvRowDt.object == object){
					foundBosvRowDt = bosvRowDt;
					break;
				}
			}
			
			if(foundBosvRowDt){
				var row:ListViewRow = this.rowForData(foundBosvRowDt);
				if(row){
					var bosvRow:SelectViewRow = row as SelectViewRow;
					if(! bosvRow){
						trace("Error: is not BaseObjectSelectViewRow: "+ row);
					}
					return bosvRow;
				}
			}
			return null;
		}
		
		
	}
}