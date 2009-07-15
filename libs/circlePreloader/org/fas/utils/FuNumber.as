package org.fas.utils
{
	public class FuNumber
	{
		public static function nextInt(_nowInt:int,_maxInt:int,_minInt:int=0,_stepInt:int=1):int{
			if(_nowInt+_stepInt==_maxInt){
				return _maxInt;
			}
			return (_nowInt+_stepInt)%(_maxInt-_minInt+1);
		}
		public static function lastInt(_nowInt:int,_maxInt:int,_minInt:int=0,_stepInt:int=-1):int{
			return nextInt(_nowInt,_maxInt,_minInt,_stepInt);
		}
	}
}