package org.fasex.preloader
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.fas.effects.LightRay;
	import org.fas.utils.FuMath;
	import org.fas.utils.FuNumber;
	public class LightRayMultiColorSlow extends Sprite
	{
		private var ray:LightRay;
		private var i:int = 0;
		private var colorArr:Array = [0xFF0000,0xFF9900,0xFFFF00,0x00FF00,0x00FFFF,0x0000FF,0xFF00FF];
		private var colorTHRxArr:Array = [0x000100,0x000100,-0x010000,0x000001,-0x000100,0x010000,-0x000001];
		private var colorIndex:int = 1;
		private var colorTHRxIndex:int = 0;
		private var pointSum:int = 40;
		private var radius:Number = 50;
		private var rotationStart:Number = -90;
		private var colorTHRx:int;
		private var txtNum:TextField;
		public function LightRayMultiColorSlow()
		{
			super();
		}
		public function build():void{
			//
			txtNum = new TextField();
			
			var tfNum:TextFormat = new TextFormat();
			tfNum.bold = true;
			tfNum.color = 0xFFFFFF;
			tfNum.size= 14;
			txtNum.defaultTextFormat = tfNum;
			this.percent = 11;
			//
			this.ray = new LightRay(LightRay.TYPE_COMET,16,36);
			this.addChild(ray);
			ray.rayColor = colorArr[colorIndex-1];
			ray.alpha = 0.65;
			txtNum.x = -10;
			txtNum.y = -8;
			this.addChild(txtNum);
			this.addEventListener(Event.ENTER_FRAME,this.evtFrame);
		}
		private function evtFrame(_e:Event):void{
			var _ro:Number = 360/pointSum;
			i++;
			ray.rayColor+=this.colorTHRxArr[this.colorTHRxIndex];
			if(ray.rayColor==this.colorArr[this.colorIndex]){
				colorIndex = FuNumber.nextInt(colorIndex,6,0,1);
				colorTHRxIndex = FuNumber.nextInt(colorTHRxIndex,6,0,1);
			}
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
	}
}