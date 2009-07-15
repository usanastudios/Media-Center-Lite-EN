package org.fas.utils
{
	import flash.geom.Point;
	
	public class FuMath
	{
		public function FuMath(){
		}
		public static function rowByIndex(_index:int,_colLength:int):int{
			return int(_index/_colLength);
		}
		public static function colByIndex(_index:int,_colLength:int):int{
			return _index%_colLength;
		}
		//override
		public static function abs(_v:Number):Number{
			return Math.abs(_v);
		}
		public static function abs360(_v:Number):Number{
			if(_v>=0 && _v<360){
				return _v;
			}else if(_v<0){
				_v+=360;
				return abs360(_v);
			}else{
				_v-=360;
				return abs360(_v);
			}
		}
		public static function randomInt(_max:int=10,_min:int=0):int{
			var _r:int;
			_r = Math.round((_max-_min)*Math.random()+_min);
			return _r;
		}
		public static function random(_max:Number=1,_min:Number=0):Number{
			return (_max-_min)*Math.random()+_min;
		}
		public static function randomArea(_center:Number,_area:Number):Number{
			return random(_center+_area,_center-_area);
		}
		public static function asin():Number{
			return Math.asin(1);
		}
		public static function sin(_ro:Number):Number{
			return Math.sin(FuMath.ro2pi(_ro));
		}
		public static function cos(_ro:Number):Number{
			return Math.cos(FuMath.ro2pi(_ro));
		}
		public static function tan(_ro:Number):Number{
			return Math.tan(FuMath.ro2pi(_ro));
		}
		public static function atan(_v:Number):Number{
			return Math.atan(_v)*180/Math.PI;//Math.cos(F3math.ro2pi(_ro));
		}
		public static function atan2(_y:Number,_x:Number):Number{
			return atan(_y/_x);
		}
		public static function getCenterFromOriginPoint():void{
			
		}
		public static function getOriginFromCenterPoint():void{
			
		}
		//extend
//		/**
//		 * @return 
//		 * 
//		 */		
//		public static function getRadialInt():int{
//			
//		}
		public static function isOdd(_n:int):Boolean{
			if(_n%2==0){
				return false;
			}return true;
		}
		public static function forceSum(_fx:Number,_fy:Number,_ro:Number):Number{
			//return _fx/FaMath.cos(_ro)+_fy/FaMath.sin(_ro);
			return _fx*FuMath.cos(_ro)+_fy*FuMath.sin(_ro);
		}
		public static function forceCent(_f:Number,_ro:Number):Point{
			return new Point(_f*FuMath.cos(_ro),_f*FuMath.sin(_ro));
		}
		public static function inRange(_v:Number,_max:Number,_min:Number,_isEqual:Boolean=true):Boolean{
			if(_max>_min){
			}else{
				var _temp:Number = _min;
				_min = _max;
				_max = _temp;
			}
			if(_isEqual){
				if(_v>=_min && _v<=_max){
					return true;
				}return false;
			}else{
				if(_v>_min && _v<_max){
					return true;
				}return false;
			}
		}
		public static function area(_v:Number,_max:Number,_min:Number=0):Number{
			if(_max>_min){
			}else{
				var _temp:Number = _min;
				_min = _max;
				_max = _temp;
			}
			return Math.min(_max,Math.max(_min,_v));
		}
		public static function dis(_dx:Number,_dy:Number):Number{
			return Math.sqrt(_dx*_dx+_dy*_dy);
		}
		public static function ro2pi(_ro:Number):Number {
			return Math.PI/180*_ro;
		}
		public static function pi2ro(_pi:Number):Number {
			return _pi/Math.PI*180;
		}
		/**
		 *real angle/rotation value in flash coordinate space 
		 * @param _x
		 * @param _y
		 * @return 
		 * 
		 */		
		public static function angle(_x:Number, _y:Number):Number {
			if (_x == 0) {
				if (_y == 0) {
					return 0;
				} else if (_y>0) {
					return 90;
				} else if (_y<0) {
					return 270;
				}
			} else if (_x>0) {
				if (_y == 0) {
					return 0;
				} else if (_y>0) {
					return atan2(_y,_x);//Math.atan(_y/_x)*180/Math.PI;
				} else if (_y<0) {
					return 360-atan(-1*_y/_x);
				}
			}
			 else if (_x<0) {
				if (_y == 0) {
					return 180;
				} else if (_y>0) {
					return 180-atan(-1*_y/_x);
				} else if (_y<0) {
					return 180+atan2(_y,_x);
				}
			}
			return 0;
		}
	}
}