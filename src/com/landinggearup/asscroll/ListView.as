package com.landinggearup.asscroll
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;

	public class ListView extends ScrollView
	{
		private var _headerView:DisplayObject = null;
		private var _headerHeight:int = 0;
		
		private var _footerView:DisplayObject = null;
		private var _footerHeight:int = 0;
		
		private var _isHorizontal:Boolean;
		
		private var _rowQualifiedClassNames:Dictionary = new Dictionary(); // rowReusableIdentifier(String) => String
		
		private var _dataProvider:Vector.<ListViewRowData>;
		
		/**
		 * rows' count
		 */
		private var rowCountCache:int;
		
		/**
		 * every rows' height
		 */
		private var rowHeightsCache:Vector.<int> = new Vector.<int>();	// index(int) => int
		
		/**
		 * this height is the summation of the height of all the rows before it and inclue it.
		 */
		private var totalRowHeightsCache:Vector.<int> = new Vector.<int>();	// index(int) => int
		
		private var displayingRowsCache:Dictionary = new Dictionary();	// index(int) => ListViewRow
		private var unusedRowsCache:Dictionary = new Dictionary();	// reusableIdentifer => Vector.<ListViewRow>
		
		/**
		 * If the scroll rect not change, will not loadRows, for performance consideration
		 */
		private var lastScrollRectPos:Number = -1000;
		private var lastStartRowIndex:int = -100;
		private var lastEndRowIndex:int = -100;
		
		/**
		 * force to load the rows currently displaying, regardless of any situation
		 */
		private var forceLoadRowsForOneTime:Boolean = false;
		
		/**
		 * When calling reloadRowAtIndex(rowIndex), enqueue the rowIndex to this vector,
		 * so that in the next time load the row with that index,
		 * call the set data regardless of the data is changed.
		 */
		private var forceReloadRowIndexesForOneTime:Vector.<int> = new Vector.<int>();
		
		
		/**
		 * @param isHorizontal Whether this ListView is "Horizontal" or "Vertical". The Horizontal makes
		 * 						the rows in the ListView scroll left and right. And the Vertical makes
		 * 						the rows scroll up and down. Note: if this value is true, the "rowHeight"
		 * 						is actually means the "width of a row", not the "height".
		 */
		public function ListView(isHorizontal:Boolean=false)
		{
			super();
			
			_isHorizontal = isHorizontal;
			
			this.bounceHorizontal = _isHorizontal;
			this.bounceVertical = ! _isHorizontal;
			
			this.showVerticalScrollBar = ! _isHorizontal;
		}
		
		override public function release():void{
			this.clean();
			
			super.release();
		}
		
		
		/**
		 * The headerView will be added above all rows.
		 */
		public function get headerView():DisplayObject{
			return _headerView;
		}
		public function set headerView(value:DisplayObject):void{
			if(_headerView && (! value)){
				if(_headerView.parent){
					_headerView.parent.removeChild(_headerView);
				}
			}
			_headerView = value;
		}
		
		/**
		 * The height of the headerView. This value determine the real height to place
		 * of the headerView. 
		 */
		public function get headerHeight():int{
			return _headerHeight;
		}
		public function set headerHeight(value:int):void{
			_headerHeight = value;
		}
		
		/**
		 * The footerView will be added beneath all rows.
		 */
		public function get footerView():DisplayObject{
			return _footerView;
		}
		public function set footerView(value:DisplayObject):void{
			if(_footerView && (! value)){
				if(_footerView.parent){
					_footerView.parent.removeChild(_footerView);
				}
			}
			_footerView = value;
		}
		
		/**
		 * The height of the footerView. This value determine the real height to place
		 * of the footerView. 
		 */
		public function get footerHeight():int{
			return _footerHeight;
		}
		public function set footerHeight(value:int):void{
			_footerHeight = value;
		}
		
		
		/**
		 * For each rowReusaleIdentifier of each kind of row, set the qualitied class name
		 * before set the dataProvider.
		 */
		public final function setRowQualifiedClassNameForRowReusableIdentifier(
			clsName:String, rowReusaleIdentifier:String):void
		{
			_rowQualifiedClassNames[rowReusaleIdentifier] = clsName;
		}
		
		protected final function getRowQualifiedClassForRowReusableIdentifier(rowReusaleIdentifier:String):Class{
			var clsName:String = _rowQualifiedClassNames[rowReusaleIdentifier];
			if(! clsName){
				trace("Error: no rowQualifiedClassName is set for rowReusaleIdentifier ["+ rowReusaleIdentifier +"]");
			}
			var cls:Class = getDefinitionByName(clsName) as Class;
			return cls;
		}
		
		
		public final function set dataProvider(value:Vector.<ListViewRowData>):void{
			_dataProvider = value;
			
			rowHeightsCache.splice(0, rowHeightsCache.length);
			
			rowCountCache = _dataProvider.length;
			
			var i:int;
			for(i=0; i<rowCountCache; i++){
				var dt:ListViewRowData = _dataProvider[i];
				dt.index = i;
				var rh:int = dt.rowHeight;
				rowHeightsCache.push(rh);
			}
			
			this.reCalcTotalRowHeightCache();
			
			this.reloadData();
		}
		
		public final function get dataProvider():Vector.<ListViewRowData>{
			return _dataProvider;
		}
		
		
		
		private function clean():void{
			var i:int = 0;
			for(i in displayingRowsCache){
				var row:ListViewRow = displayingRowsCache[i];
				row.parent.removeChild(row);
				row.release();
				delete displayingRowsCache[i];
			}
			for(var k:* in unusedRowsCache){
				delete unusedRowsCache[k];
			}
		}
		
		
		private function adjustContentSize(animated:Boolean=false):void{
			if(rowCountCache <= 0){
				this.contentSize = new SizeInt();
			}else{
				var r:SizeInt = this.contentSize.clone();
				if(_isHorizontal){
					r.width = totalRowHeightsCache[rowCountCache - 1] + _headerHeight + _footerHeight;
				}else{
					r.height = totalRowHeightsCache[rowCountCache - 1] + _headerHeight + _footerHeight;
				}
				this.setContentSizeWithAdjustment(r, animated);
			}
		}
		
		
		public final function reloadData():void{
			this.clean();
			
			this.adjustContentSize();
			
			this.contentOffset = new SizeInt();
			
			forceLoadRowsForOneTime = true;
			
			if(_headerView){
				if(_headerView.parent){
					if(_headerView.parent != this){
						addChild(_headerView);
					}
				}else{
					addChild(_headerView);
				}
				_headerView.x = 0;
				_headerView.y = 0;
			}
			
			if(_footerView){
				if(_footerView.parent){
					if(_footerView.parent != this){
						addChild(_footerView);
					}
				}else{
					addChild(_footerView);
				}
				_footerView.x = 0;
				_footerView.y = totalRowHeightsCache[_dataProvider.length - 1] + _headerHeight;
			}
		}
		
		
		
		public final function positionOfRow(rowIndex:int):int{
			var totalHeight:int = totalRowHeightsCache[rowIndex] - rowHeightsCache[rowIndex];
			return (totalHeight + _headerHeight);
		}
		
		public final function rectangleOfRow(rowIndex:int):Rectangle{
			var r:Rectangle = new Rectangle();
			
			if(_isHorizontal){
				r.x = this.positionOfRow(rowIndex);
				r.y = 0;
				r.width = rowHeightsCache[rowIndex];
				r.height = this.viewportSize.height;
			}else{
				r.x = 0;
				r.y = this.positionOfRow(rowIndex);
				r.width = this.viewportSize.width;
				r.height = rowHeightsCache[rowIndex];
			}
			
			return r;
		}
		
		public final function rowIndexOfPosition(val:Number):int{
			var rowIndex:int = rowCountCache - 1;
			
			var i:int = 0;
			for(i=0; i<rowCountCache; i++){
				var totalHeight:int = totalRowHeightsCache[i];
				if(totalHeight + _headerHeight >= val){
					rowIndex = i;
					break;
				}
			}
			
			return rowIndex;
		}
		
		public final function rowAtIndex(rowIndex:int):ListViewRow{
			return displayingRowsCache[rowIndex];
		}
		
		public final function rowForData(data:ListViewRowData):ListViewRow{
			return this.rowAtIndex(data.index);
		}
		
		/**
		 * Scroll to a row.
		 * @param rowIndex The 0 based index of the row.
		 * @param animated Whether show the scroll animation.
		 */
		public function scrollToRow(rowIndex:int, animated:Boolean=false):void{
			var pos:int = this.positionOfRow(rowIndex);
			var sz:SizeInt = this.contentOffset.clone();
			if(_isHorizontal){
				sz.width = - pos;
			}else{
				sz.height = - pos;
			}
			this.setContentOffsetWithAdjustment(sz, animated);
		}
		
		public function changeRowHeight(rowIndex:int, newHeight:int):void{
			var oldHeight:int = _dataProvider[rowIndex].rowHeight;
			_dataProvider[rowIndex].rowHeight = newHeight;
			rowHeightsCache[rowIndex] = newHeight;
			this.reCalcTotalRowHeightCache();
			
			this.adjustContentSize();
			
			this.moveAllDisplayingRowCacheToUnused();
			forceLoadRowsForOneTime = true;
			if(forceReloadRowIndexesForOneTime.indexOf(rowIndex) < 0){
				forceReloadRowIndexesForOneTime.push(rowIndex);
			}
			
			this.loadRows();
		}
		
		public function insertRowAtIndex(data:ListViewRowData, rowIndex:int):void{
			_dataProvider.splice(rowIndex, 0, data);
			rowHeightsCache.splice(rowIndex, 0, data.rowHeight);
			rowCountCache ++;
			this.reCalcTotalRowHeightCache();
			
			this.adjustContentSize();
			
			this.moveAllDisplayingRowCacheToUnused();
			forceLoadRowsForOneTime = true;
			
			this.loadRows();
		}
		
		public function removeRowAtIndex(rowIndex:int):void{
			_dataProvider.splice(rowIndex, 1);
			rowHeightsCache.splice(rowIndex, 1);
			rowCountCache --;
			this.reCalcTotalRowHeightCache();
			
			this.adjustContentSize();
			
			this.moveAllDisplayingRowCacheToUnused();
			forceLoadRowsForOneTime = true;
			
			this.loadRows();
		}
		
		
		/**
		 * NOTE: reloadRowAtIndex doesn't handle the row height change.
		 */
		public function reloadRowAtIndex(rowIndex:int):void{
			forceLoadRowsForOneTime = true;
			if(forceReloadRowIndexesForOneTime.indexOf(rowIndex) < 0){
				forceReloadRowIndexesForOneTime.push(rowIndex);
			}
			
			this.loadRows();
		}
		
		
		
		private function moveAllDisplayingRowCacheToUnused():void{
			var i:int;
			for(i in displayingRowsCache){
				var row:ListViewRow = displayingRowsCache[i];
				row.visible = false;
				
				var unused:Vector.<ListViewRow> = unusedRowsCache[row.data.reusableIdentifier];
				if(! unused){
					unused = new Vector.<ListViewRow>();
					unusedRowsCache[row.data.reusableIdentifier] = unused;
				}
				
				unused.push(row);
				delete displayingRowsCache[i];
			}
		}
		
		
		/**
		 * rowCountCache and rowHeightsCache must be ready before calling thie method
		 */
		private function reCalcTotalRowHeightCache():void{
			totalRowHeightsCache.splice(0, totalRowHeightsCache.length);
			
			var totalRowHeight:int = 0;
			
			var i:int;
			
			for(i=0; i<rowCountCache; i++){
				totalRowHeight += rowHeightsCache[i];
				totalRowHeightsCache.push(totalRowHeight);
			}
		}
		
		
		private function handleRow(row:ListViewRow):void{
			var rowDt:ListViewRowData = _dataProvider[row.index];
			var forceReloadRowIndex:int = forceReloadRowIndexesForOneTime.indexOf(row.index);
			var forceReloadRow:Boolean = (forceReloadRowIndex >= 0);
			if(forceReloadRow || row.data != rowDt){
				row.data = rowDt;
				forceReloadRowIndexesForOneTime.splice(forceReloadRowIndex, 1);
			}
			
			var thePos:int = this.positionOfRow(row.index);
			if(_isHorizontal){
				row.x = thePos;
			}else{
				row.y = thePos;
			}
		}
		
		
		protected function createNewRow(rowReusaleIdentifier:String):ListViewRow{
			var cls:Class = this.getRowQualifiedClassForRowReusableIdentifier(rowReusaleIdentifier);
			var newlyRow:ListViewRow = new cls();
			return newlyRow;
		}
		
		
		private function loadRowAtIndex(rowIndex:int):ListViewRow{
			var rowDt:ListViewRowData = _dataProvider[rowIndex];
			
			var newlyRow:ListViewRow = null;
			
			var isNewlyCreate:Boolean = false;
			
			var unused:Vector.<ListViewRow> = unusedRowsCache[rowDt.reusableIdentifier];
			
			if(unused && unused.length > 0){
				// try to find the old row with the same data and others first:
				for(var i:int=0; i<unused.length; i++){
					var r:ListViewRow = unused[i];
					if(r.index == rowIndex){
						newlyRow = r;
						unused.splice(i, 1);
						break;
					}
				}
				if(! newlyRow){
					newlyRow = unused.splice(0, 1)[0];
				}
			}else{
				isNewlyCreate = true;
				newlyRow = this.createNewRow(rowDt.reusableIdentifier);
			}
			newlyRow.index = rowIndex;
			
			if(! newlyRow.parent){
				addChild(newlyRow);
			}
			newlyRow.visible = true;
			
			displayingRowsCache[rowIndex] = newlyRow;
			
			if(isNewlyCreate){
				var evt:ListViewEvent = new ListViewEvent(ListViewEvent.CREATE_ROW);
				evt.loadedRow = newlyRow;
				dispatchEvent(evt);
			}
			
			return newlyRow;
			
		}
		
		
		private function loadRows():void{
			if(! _dataProvider || rowCountCache <= 0){
				return;
			}
			
			var sr:Rectangle = this.scrollRect;
			if((! sr) && (! forceLoadRowsForOneTime)){
				return;
			}
			
			var isSameScrollPos:Boolean;
			if(_isHorizontal){
				isSameScrollPos = (sr.x == lastScrollRectPos);
			}else{
				isSameScrollPos = (sr.y == lastScrollRectPos);
			}
			if(isSameScrollPos && (! forceLoadRowsForOneTime)){
				return;
			}
			
			if(_isHorizontal){
				lastScrollRectPos = sr.x;
			}else{
				lastScrollRectPos = sr.y;
			}
			
			var startRowIndex:int;
			var endRowIndex:int;
			if(_isHorizontal){
				startRowIndex = this.rowIndexOfPosition(sr.x);
				endRowIndex = this.rowIndexOfPosition(sr.x + sr.width);
			}else{
				startRowIndex = this.rowIndexOfPosition(sr.y);
				endRowIndex = this.rowIndexOfPosition(sr.y + sr.height);
			}
			
			if(! forceLoadRowsForOneTime){
				if(startRowIndex == lastStartRowIndex && endRowIndex == lastEndRowIndex){
					return;
				}
			}
			lastStartRowIndex = startRowIndex;
			lastEndRowIndex = endRowIndex;
			
			var i:int;
			for(i = startRowIndex; i <= endRowIndex; i++){
				var row:ListViewRow = displayingRowsCache[i];
				
				if(! row){
					row = this.loadRowAtIndex(i);
				}
				
				this.handleRow(row);
			}
			
			
			if(forceLoadRowsForOneTime){
				forceLoadRowsForOneTime = false;
			}
			
			
			for(i in displayingRowsCache){
				if(i < startRowIndex || i > endRowIndex){
					var unusedRow:ListViewRow = displayingRowsCache[i];
					var unused:Vector.<ListViewRow> = unusedRowsCache[unusedRow.data.reusableIdentifier];
					if(! unused){
						unused = new Vector.<ListViewRow>();
						unusedRowsCache[unusedRow.data.reusableIdentifier] = unused;
					}
					unused.push(unusedRow);
					unusedRow.visible = false;
					delete displayingRowsCache[i];
				}
			}
			
		}
		
		override protected function onEnterFrame(e:Event):void{
			super.onEnterFrame(e);
			
			this.loadRows();
			
		}
		
		
	}
}