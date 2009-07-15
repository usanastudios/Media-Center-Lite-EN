package org.fasex.preloader
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.fas.effects.LightRay;
	import org.fas.utils.FuMath;
	public class LightRaySimpleColor extends Sprite
	{
		private var ray:LightRay;
		private var i:int = 0;
		private var pointSum:int = 40;
		private var radius:Number = 50;
		private var rotationStart:Number = -90;
		private var txtNum:TextField;
		public var rayColor:uint = 0xFFFFFF;
		public function LightRaySimpleColor()
		{
			super();
			txtNum = new TextField();
			this.ray = new LightRay(LightRay.TYPE_COMET,12,36);
		}
		public function build():void{
			//
			var tfNum:TextFormat = new TextFormat();
			tfNum.bold = true;
			tfNum.color = 0xFFFFFF;
			tfNum.size= 14;
			txtNum.defaultTextFormat = tfNum;
			this.percent = 11;
			this.addChild(ray);
			ray.rayColor = this.rayColor;
			ray.alpha = 0.9;
			txtNum.x = -10;
			txtNum.y = -8;
			this.addChild(txtNum);
			this.addEventListener(Event.ENTER_FRAME,this.evtFrame);
		}
		private function evtFrame(_e:Event):void{
			var _ro:Number = 360/pointSum;
			i++;
			if(i>=pointSum){
				i=0;
			}
			var x:Number = FuMath.cos(_ro*i+rotationStart)*radius;
			var y:Number = FuMath.sin(_ro*i+rotationStart)*radius;
			ray.updateXY(x,y);
		}
		private var er_percent:Number = 0;
		public function set percent(_num:Number):void{
			this.er_percent = _num;
			this.txtNum.text = (_num+'%');
		}
		public function get percent():Number{
			return this.er_percent;
		}
		public function set showPercent(_bl:Boolean):void{
			 this.txtNum.visible = _bl;
		}
		public function get showPercent():Boolean{
			return this.txtNum.visible;
		}
	}
}