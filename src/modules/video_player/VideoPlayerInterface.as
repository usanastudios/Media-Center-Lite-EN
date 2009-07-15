package modules.video_player
{
	
	import flash.events.IEventDispatcher;
	
	public interface VideoPlayerInterface extends IEventDispatcher {
	
		function setVideo(id:String):void;
		function pauseVideo():void;
//        function getModuleName():String;
 //       function setBackgroundColor(n:Number):void;
	}
		
}

