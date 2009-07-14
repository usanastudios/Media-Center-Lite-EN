package modules.preloader
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.filters.DropShadowFilter;
	
	import mx.events.FlexEvent;
	import mx.preloaders.DownloadProgressBar;

	public class Pre extends DownloadProgressBar
	{
		private var cp:customPreloader;
		
		public function Pre()
		{
			cp = new customPreloader();
			cp.filters = [new DropShadowFilter(4, 45, 0, 0.5)];
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			addChild(cp);
		}
		
		public override function set preloader(preloader:Sprite):void
		{
			preloader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			preloader.addEventListener(FlexEvent.INIT_COMPLETE, initComplete);
		}
		
		private function onProgress(e:ProgressEvent):void
		{
			cp.gotoAndStop(Math.ceil(e.bytesLoaded/e.bytesTotal*100));
		}
		
		private function initComplete(e:Event):void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function onAdded(e:Event):void
		{
			cp.stop();
			cp.x = 0;
			cp.y = 0;
		}
		
	}
}