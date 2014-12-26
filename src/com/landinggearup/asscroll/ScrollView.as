package com.landinggearup.asscroll
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	
	public class ScrollView extends Sprite
	{
		public static var ScrollViewAnimationDurationMilliSec:int = 250;
		public static var ScrollViewShowScrollBarDurMilliSec:int = 500;
		public static var ScrollViewIgnoreMoveAsTouchDist:int = 20;
		
		public static const DefaultInertiaScrollDeceleration:Number = 0.96;
		public var inertiaScrollDeceleration:Number = DefaultInertiaScrollDeceleration;
		
		private var _contentSize:SizeInt;
		private var _contentOffset:SizeInt;
		private var _viewportSize:SizeInt;
		public var bounceVertical:Boolean = true;
		public var bounceHorizontal:Boolean = true;
		private var _scrollEnabled:Boolean = true;
		
		private var _pagingEnabled:Boolean = false;
		private var _currentPage:int = 0;
		
		private var isMouseDown:Boolean = false;
		private var lastMousePosition:Point;
		private var lastMouseTime:int = 0;
		private var beginMousePosition:Point;	// the stage's mouse coord when touch begin
		
		private var velocityX:Number = 0;
		private var velocityY:Number = 0;
		private var isScrollingX:Boolean = false;
		private var isScrollingY:Boolean = false;
		private var isBounceScrollingX:Boolean = false;
		private var isBounceScrollingY:Boolean = false;
		private var bounceScrollVelocityX:Number = 0;
		private var bounceScrollVelocityY:Number = 0;
		private var bounceScrollStepX:int = 0;
		private var bounceScrollStepY:int = 0;
		private var bounceScrollTotalStep:uint;
		
		private var progSetOffsetStep:int = 0;
		private var progSetOffsetTotalStep:int = 0;
		private var isProgSetOffset:Boolean = false;
		private var progSetOffsetVelocityX:Number = 0;
		private var progSetOffsetVelocityY:Number = 0;
		private var progSetOffsetTargetOffset:SizeInt;
		
		public var showVerticalScrollBar:Boolean = true;
		private var showScrollBarsTimer:Timer;
		private var showScrollBarsIsSleeping:Boolean = true;
		private var showScrollBarsIsDimming:Boolean;
		private var showScrollBarsTotalStep:int = 0;
		private var showScrollBarsStep:int = 0;
		
		
		public function ScrollView()
		{
			super();
			
			_contentOffset = new SizeInt();
			_viewportSize = new SizeInt();
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
			
			showScrollBarsTimer = new Timer(1000, 1);
			showScrollBarsTimer.addEventListener(TimerEvent.TIMER, onShowScrollBarsTimer, false, 0, true);
		}
		
		public function release():void{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false);
			showScrollBarsTimer.removeEventListener(TimerEvent.TIMER, onShowScrollBarsTimer, false);
			showScrollBarsTimer.stop();
			showScrollBarsTimer = null;
		}
		
		
		public function get scrollEnabled():Boolean{
			return _scrollEnabled;
		}
		
		public function set scrollEnabled(value:Boolean):void{
			_scrollEnabled = value;
			
			if(! value){
				isScrollingX = false;
				isScrollingY = false;
				isBounceScrollingX = false;
				isBounceScrollingY = false;
				
				var sz:SizeInt = this.contentOffset;
				this.adjustContentOffsetX(sz);
				this.adjustContentOffsetY(sz);
				this.contentOffset = sz;
			}
			
		}
		
		
		public function get contentSize():SizeInt{
			if(_contentSize == null){
				return this.viewportSize.clone();
			}
			return _contentSize;
		}
		
		public function set contentSize(sz:SizeInt):void{
			_contentSize = sz;
		}
		
		public function setContentSizeWithAdjustment(sz:SizeInt, animated:Boolean = true):void{
			_contentSize = sz;
			
			var offset:SizeInt = this.contentOffset.clone();
			this.setContentOffsetWithAdjustment(offset, animated);
		}
		
		
		public function get contentOffset():SizeInt{
			return _contentOffset;
		}
		
		public function set contentOffset(sz:SizeInt):void{
			_contentOffset = sz;
			
			var r:Rectangle = this.scrollRect;
			if(! r){
				r = new Rectangle();
			}
			r.x = -sz.width;
			r.y = -sz.height;
			r.width = this.viewportSize.width;
			r.height = this.viewportSize.height;
			this.scrollRect = r;
			
			showScrollBarsTimer.reset();
			showScrollBarsTimer.start();
			showScrollBarsIsDimming = false;
			showScrollBarsIsSleeping = false;
			
		}
		
		public function setContentOffsetWithAdjustment(sz:SizeInt, animated:Boolean = true):void{
			isScrollingX = false;
			isScrollingY = false;
			isBounceScrollingX = false;
			isBounceScrollingY = false;
			
			progSetOffsetTargetOffset = sz.clone();
			this.adjustContentOffsetX(progSetOffsetTargetOffset);
			this.adjustContentOffsetY(progSetOffsetTargetOffset);
			
			if(animated){
				progSetOffsetStep = 0;
				isProgSetOffset = true;
			}else{
				this.contentOffset = progSetOffsetTargetOffset;
			}
		}
		
		
		public function get viewportSize():SizeInt{
			if(! _viewportSize){
				return new SizeInt(width, height);
			}
			return _viewportSize;
		}
		
		public function set viewportSize(sz:SizeInt):void{
			_viewportSize = sz;
			
			var r:Rectangle = this.scrollRect;
			if(r == null){
				r = new Rectangle(this.contentOffset.width, this.contentOffset.height);
			}
			r.width = sz.width;
			r.height = sz.height;
			this.scrollRect = r;
			
		}
		
		
		private function get sizeToCalcAsContentSize():SizeInt{
			var sz:SizeInt = new SizeInt();
			sz.width = Math.max(this.viewportSize.width, this.contentSize.width);
			sz.height = Math.max(this.viewportSize.height, this.contentSize.height); 
			return sz;
		}
		
		
		/**
		 * adjust the content offset ensure that the ther is no "blank space"
		 */
		public function adjustContentOffsetX(offset:SizeInt):Boolean{
			var sz:SizeInt = offset;
			
			var b:Boolean = false;
			if(sz.width > 0){
				sz.width = 0;
				b = true;
			}else if(-sz.width + this.viewportSize.width > this.sizeToCalcAsContentSize.width){
				sz.width = - (this.sizeToCalcAsContentSize.width - this.viewportSize.width);
				b = true;
			}
			
			return b;
		}

		public function adjustContentOffsetY(offset:SizeInt):Boolean{
			var sz:SizeInt = offset;
			
			var b:Boolean = false;
			if(sz.height > 0){
				sz.height = 0;
				b = true;
			}else if(-sz.height + this.viewportSize.height > this.sizeToCalcAsContentSize.height){
				sz.height = - (this.sizeToCalcAsContentSize.height - this.viewportSize.height);
				b = true;
			}
			
			return b;
		}
		
		
		public function get pagingEnabled():Boolean{
			return _pagingEnabled;
		}
		
		public function set pagingEnabled(value:Boolean):void{
			_pagingEnabled = value;
			
			// TOD: here
		}
		
		public function get currentPage():int{
			return _currentPage;
		}
		
		public function set currentPage(value:int):void{
			_currentPage = value;
			if(_currentPage >= this.maxPageCount()){
				_currentPage = this.maxPageCount() - 1;
			}
			if(_currentPage < 0){
				_currentPage = 0;
			}
			
			isScrollingX = false;
			isScrollingY = false;
			isBounceScrollingX = false;
			isBounceScrollingY = false;
			isProgSetOffset = false;
			
			var sz:SizeInt = this.contentOffsetForPate(_currentPage);
			this.contentOffset = sz;
		}
		
		public function setCurrentPageWithAnimation(value:int):void{
			_currentPage = value;
			if(_currentPage >= this.maxPageCount()){
				_currentPage = this.maxPageCount() - 1;
			}
			if(_currentPage < 0){
				_currentPage = 0;
			}
			var sz:SizeInt = this.contentOffsetForPate(_currentPage);
			this.setContentOffsetWithAdjustment(sz);
		}
		
		private function innerSetCurrentPageAnimation(value:int, changed:Boolean):void{
			this.setCurrentPageWithAnimation(value);
			
			if(changed){
				var evt:ScrollViewEvent = new ScrollViewEvent(ScrollViewEvent.PAGE_CHANGED);
				dispatchEvent(evt);
			}
		}
		
		private function maxPageCount():int{
			var n:int = Math.ceil(this.contentSize.width / this.viewportSize.width);
			return n;
		}
		
		private function contentOffsetForPate(page:int):SizeInt{
			var sz:SizeInt = new SizeInt(- page * this.viewportSize.width, 0);
			return sz;
		}
		
		private function renderScrollBars():void{
			if(! showVerticalScrollBar){
				return;
			}
			
			if(showScrollBarsIsSleeping){
				return;
			}
			
			var scrollBarsAlpha:Number = 0.5;
			if(showScrollBarsIsDimming){
				scrollBarsAlpha = 0.5 - showScrollBarsStep / showScrollBarsTotalStep * 0.5;
				
				showScrollBarsStep ++;
				if(showScrollBarsStep > showScrollBarsTotalStep){
					showScrollBarsIsDimming = false;
					showScrollBarsIsSleeping = true;
					graphics.clear();
					return;
				}
			}
			
			const scrollBarThickness:int = 5;
			const scrollBarConorRadius:int = 5;
			const scrollBarYMinLength:int = 10;
			
			var viewportSizeW:int = this.viewportSize.width;
			var viewportSizeH:int = this.viewportSize.height;
			var contentSizeW:int = this.contentSize.width;
			var contentSizeH:int = this.contentSize.height;
			var contentOffsetW:int = this.contentOffset.width;
			var contentOffsetH:int = this.contentOffset.height;
			
			var fixedContentSizeH:int = contentSizeH > viewportSizeH ? contentSizeH:viewportSizeH;
			
			var scrollBarYLength:Number = 0;
			
			scrollBarYLength = viewportSizeH / fixedContentSizeH * viewportSizeH;
			if(scrollBarYLength < scrollBarYMinLength){
				scrollBarYLength = scrollBarYMinLength;
			}
			var scrollBarYX:Number = viewportSizeW - scrollBarThickness;
			
			var scrollBarYY:int = 0;
			if(fixedContentSizeH == viewportSizeH){
				scrollBarYY = 0;
			}else{
				var percentY:Number = - contentOffsetH / (fixedContentSizeH - viewportSizeH);
				scrollBarYY = - contentOffsetH + (viewportSizeH - scrollBarYLength) * percentY;
			}
			
			graphics.clear();
			graphics.beginFill(0xbbbbbb, scrollBarsAlpha);
			graphics.drawRoundRect(scrollBarYX, scrollBarYY, scrollBarThickness, scrollBarYLength, scrollBarConorRadius);
			
		}
		
		
		
		protected function onAddedToStage(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false);
			bounceScrollTotalStep = stage.frameRate * ScrollViewAnimationDurationMilliSec / 1000;
			progSetOffsetTotalStep = stage.frameRate * ScrollViewAnimationDurationMilliSec / 1000;
			showScrollBarsTotalStep = stage.frameRate * ScrollViewShowScrollBarDurMilliSec / 1000;
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
			addEventListener(MouseEvent.MOUSE_DOWN, onScrollViewMouseDown, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, onScrollViewStageMouseUp, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onScrollViewStageMouseMove, false, 0, true);
			
		}
		
		protected function onRemovedFromStage(e:Event):void{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false);
			removeEventListener(Event.ENTER_FRAME, onEnterFrame, false);
			removeEventListener(MouseEvent.MOUSE_DOWN, onScrollViewMouseDown, false);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onScrollViewStageMouseUp, false);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onScrollViewStageMouseMove, false);
		}
		
		
		protected function onEnterFrame(e:Event):void{
			this.handleProgramSetContentOffset();
			this.handleInertialScroll();
			this.handleBounceScoll();
			this.renderScrollBars();
			this.update();
		}
		
		
		private function onShowScrollBarsTimer(e:TimerEvent):void{
			showScrollBarsStep = 0;
			showScrollBarsIsDimming = true;
		}
		
		
		private function onScrollViewMouseDown(e:MouseEvent):void{
			isMouseDown = true;
			
			if(! this.scrollEnabled){
				return;
			}
			
			isBounceScrollingX = false;
			isBounceScrollingY = false;
			
			if(isScrollingX){
				velocityX *= 0.1;
			}else{
				velocityX = 0;
			}
			if(isScrollingY){
				velocityY *= 0.1;
			}else{
				velocityY = 0;
			}
			
			beginMousePosition = new Point(stage.mouseX, stage.mouseY);
			lastMousePosition = beginMousePosition.clone();
			lastMouseTime = getTimer();
			
		}
		
		private function onScrollViewStageMouseUp(e:MouseEvent):void{
			if(! isMouseDown){
				return;
			}
			
			isMouseDown = false;
			
			if(! this.scrollEnabled){
				return;
			}
			
			const minStartScrollingVelocity:int = 2;
			
			if(this.pagingEnabled){
				const shouldIgnoreChangePageVelocity:Number = 1;
				var orgPage:int = this.currentPage;
				var newpage:int = orgPage;
				if(velocityX > shouldIgnoreChangePageVelocity){
					newpage -= 1;
				}else if(velocityX < - shouldIgnoreChangePageVelocity){
					newpage += 1;
				}
				if(newpage >= this.maxPageCount()){
					newpage = this.maxPageCount() - 1;
				}
				if(newpage < 0){
					newpage = 0;
				}
				this.innerSetCurrentPageAnimation(newpage, (newpage != orgPage));
				this.mouseChildren = true;
				return;
			}
			
			if(! isScrollingX){
				if(Math.abs(velocityX) >= minStartScrollingVelocity){
					isScrollingX = true;
					this.mouseChildren = false;
				}
			}
			if(! isScrollingY){
				if(Math.abs(velocityY) >= minStartScrollingVelocity){
					isScrollingY = true;
					this.mouseChildren = false;
				}
			}
			
			if(! isScrollingX){
				isBounceScrollingX = true;
				bounceScrollStepX = 0;
			}
			if(! isScrollingY){
				isBounceScrollingY = true;
				bounceScrollStepY = 0;
			}
			
		}
		
		private function onScrollViewStageMouseMove(e:MouseEvent):void{
			if(! this.scrollEnabled){
				return;
			}
			
			if(isMouseDown){
				var mousePos:Point = new Point(stage.mouseX, stage.mouseY);
				var mouseTime:int = getTimer();
				
				var dTime:int = mouseTime - lastMouseTime;
				var dx:Number = mousePos.x - lastMousePosition.x;
				var dy:Number = mousePos.y - lastMousePosition.y;
				
				if(this.mouseChildren){
					var distToBeginPos:Number = Point.distance(mousePos, beginMousePosition);
					if(distToBeginPos > ScrollViewIgnoreMoveAsTouchDist){
						this.mouseChildren = false;
					}
				}
				
				velocityX = dx / dTime * 1000 / stage.frameRate;
				velocityY = dy / dTime * 1000 / stage.frameRate;
				
				var sz:SizeInt = this.contentOffset;
				
				const reduce:Number = 0.3;
				if(this.bounceHorizontal){
					if(sz.width > 0){
						dx *= reduce;
					}else if(-sz.width + this.viewportSize.width > this.sizeToCalcAsContentSize.width){
						dx *= reduce;
					}
				}
				if(this.bounceVertical){
					if(sz.height > 0){
						dy *= reduce;
					}else if(-sz.height + this.viewportSize.height > this.sizeToCalcAsContentSize.height){
						dy *= reduce;
					}
				}
				
				sz.width += dx;
				sz.height += dy;
				
				if(! this.bounceHorizontal){
					this.adjustContentOffsetX(sz);
				}
				if(! this.bounceVertical){
					this.adjustContentOffsetY(sz);
				}
				
				this.contentOffset = sz;
				
				lastMousePosition = mousePos;
				lastMouseTime = mouseTime;
				
			}
		}
		
		
		private function shouldBounceX():Boolean{
			var b:Boolean = false;
			var offset:SizeInt = this.contentOffset;
			if(offset.width > 0){
				b = true;
			}else if(-offset.width + this.viewportSize.width > this.sizeToCalcAsContentSize.width){
				b = true;
			}
			return b;
		}
		
		private function shouldBounceY():Boolean{
			var b:Boolean = false;
			var offset:SizeInt = this.contentOffset;
			if(offset.height > 0){
				b = true;
			}else if(-offset.height + this.viewportSize.height > this.sizeToCalcAsContentSize.height){
				b = true;
			}
			return b;
		}
		
		
		private function handleProgramSetContentOffset():void{
			if(isProgSetOffset){
				if(progSetOffsetStep == 0){
					var dx:Number = progSetOffsetTargetOffset.width - this.contentOffset.width;
					var dy:Number = progSetOffsetTargetOffset.height - this.contentOffset.height;
					progSetOffsetVelocityX = dx / progSetOffsetTotalStep;
					progSetOffsetVelocityY = dy / progSetOffsetTotalStep;
				}
				
				if(progSetOffsetStep >= progSetOffsetTotalStep - 1){
					this.contentOffset = progSetOffsetTargetOffset;
					isProgSetOffset = false;
					
				}else{
					var sz:SizeInt = this.contentOffset;
					sz.width += progSetOffsetVelocityX;
					sz.height += progSetOffsetVelocityY;
					this.contentOffset = sz;
					
					progSetOffsetStep ++;
				}
				
			}
		}
		
		
		private function handleInertialScroll():void{
			const maxVelocity:Number = 200;
			const shouldStopVelocity:Number = 1;
			const overEdgeBounceDecceration:Number = 0.2;
			
			var scrolling:Boolean = false;
			
			if(isScrollingX){
				scrolling = true;
				
				if(Math.abs(velocityX) > maxVelocity){
					velocityX = velocityX > 0 ? maxVelocity:-maxVelocity;
				}
				
				if(this.shouldBounceX()){
					velocityX *= overEdgeBounceDecceration;
				}
				
				if(Math.abs(velocityX) > shouldStopVelocity){
					var szX:SizeInt = this.contentOffset;
					szX.width += velocityX;
					if(! this.bounceHorizontal){
						var adjustedX:Boolean = this.adjustContentOffsetX(szX);
						if(adjustedX){
							velocityX = 0;
						}
					}
					this.contentOffset = szX;
					velocityX *= this.inertiaScrollDeceleration;
				}
				
				if(Math.abs(velocityX) <= shouldStopVelocity){
					velocityX = 0;
				}
				
				if(velocityX == 0){
					isScrollingX = false;
					
					if(this.bounceHorizontal && this.shouldBounceX()){
						isBounceScrollingX = true;
						bounceScrollStepX = 0;
					}
					
				}
			}
			
			if(isScrollingY){
				scrolling = true;
				
				if(Math.abs(velocityY) > maxVelocity){
					velocityY = velocityY > 0 ? maxVelocity:-maxVelocity;
				}
				
				if(this.shouldBounceY()){
					velocityY *= overEdgeBounceDecceration;
				}
				
				if(Math.abs(velocityY) > shouldStopVelocity){
					var szY:SizeInt = this.contentOffset;
					szY.height += velocityY;
					if(! this.bounceVertical){
						var adjustedY:Boolean = this.adjustContentOffsetY(szY);
						if(adjustedY){
							velocityY = 0;
						}
					}
					this.contentOffset = szY;
					velocityY *= this.inertiaScrollDeceleration;
				}
				
				if(Math.abs(velocityY) <= shouldStopVelocity){
					velocityY = 0;
				}
				
				if(velocityY == 0){
					isScrollingY = false;
					
					if(this.bounceVertical && this.shouldBounceY()){
						isBounceScrollingY = true;
						bounceScrollStepY = 0;
					}
					
				}
			}
			
			
			if(scrolling){
				
				if(isScrollingX || isScrollingY || isBounceScrollingX || isBounceScrollingY){
					
				}else{
					this.mouseChildren = true;
				}
			}
			
		}
		
		
		private function handleBounceScoll():void{
			var scrolling:Boolean = false;
			
			if(! isScrollingX && isBounceScrollingX){
				scrolling = true;
				
				if(bounceScrollStepX == 0){
					var dx:Number = 0;
					
					var szX:SizeInt = this.contentOffset;
					if(szX.width > 0){
						dx = - szX.width;
					}else if(-szX.width + this.viewportSize.width > this.sizeToCalcAsContentSize.width){
						dx = -szX.width + this.viewportSize.width - this.sizeToCalcAsContentSize.width;
					}
					
					if(dx != 0){
						bounceScrollVelocityX = dx / bounceScrollTotalStep;
						isBounceScrollingX = true;
					}else{
						isBounceScrollingX = false;
					}
				}
				
				if(isBounceScrollingX){
					if(bounceScrollStepX >= bounceScrollTotalStep - 1){
						var finalOffsetX:SizeInt = this.contentOffset;
						if(bounceScrollVelocityX < 0){
							finalOffsetX.width = 0;
						}else if(bounceScrollVelocityX > 0){
							finalOffsetX.width = - (this.sizeToCalcAsContentSize.width - this.viewportSize.width);
						}
						this.contentOffset = finalOffsetX;
						
						isBounceScrollingX = false;
						
					}else{
						var offset:SizeInt = this.contentOffset;
						offset.width += bounceScrollVelocityX;
						this.contentOffset = offset;
						
						bounceScrollStepX ++;
						
					}
				}
				
			}
			
			if(! isScrollingY && isBounceScrollingY){
				scrolling = true;
				
				if(bounceScrollStepY == 0){
					var dy:Number = 0;
					
					var szY:SizeInt = this.contentOffset;
					if(szY.height > 0){
						dy = - szY.height;
					}else if(-szY.height + this.viewportSize.height > this.sizeToCalcAsContentSize.height){
						dy = -szY.height + this.viewportSize.height - this.sizeToCalcAsContentSize.height;
					}
					
					if(dy != 0){
						bounceScrollVelocityY = dy / bounceScrollTotalStep;
						isBounceScrollingY = true;
					}else{
						isBounceScrollingY = false;
					}
				}
				
				if(isBounceScrollingY){
					if(bounceScrollStepY >= bounceScrollTotalStep - 1){
						var finalOffsetY:SizeInt = this.contentOffset;
						if(bounceScrollVelocityY < 0){
							finalOffsetY.height = 0;
						}else if(bounceScrollVelocityY > 0){
							finalOffsetY.height = - (this.sizeToCalcAsContentSize.height - this.viewportSize.height);
						}
						this.contentOffset = finalOffsetY;
						
						isBounceScrollingY = false;
						
					}else{
						var offsetY:SizeInt = this.contentOffset;
						offsetY.height += bounceScrollVelocityY;
						this.contentOffset = offsetY;
						
						bounceScrollStepY ++;
						
					}
				}
				
			}
			
			if(scrolling){
				if(isScrollingX || isScrollingY || isBounceScrollingX || isBounceScrollingY){
					
				}else{
					this.mouseChildren = true;
				}
			}
			
		}
		
		private function update():void{
			
		}
		
	}
}