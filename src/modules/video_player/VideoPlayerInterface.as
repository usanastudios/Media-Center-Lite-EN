package modules.video_player
{
	
	import flash.events.IEventDispatcher;
	
	public interface VideoPlayerInterface extends IEventDispatcher {
	
		function setIsPausedVar(isPaused:Boolean):void;
		function setVideo(id:String,playNow:Boolean):void;
		
	}
		
}

