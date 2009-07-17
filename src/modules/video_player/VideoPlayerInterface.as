package modules.video_player
{
	
	import flash.events.IEventDispatcher;
	
	public interface VideoPlayerInterface extends IEventDispatcher {
	
		function setVideo(id:String):void;
	}
		
}

