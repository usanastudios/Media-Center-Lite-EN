package components.controls{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	import flash.utils.*;
	
	import mx.core.FlexGlobals;
	
	public class ClearSpringAPI extends MovieClip
	{
		private const kernelUrl:String = "http://widgets.clearspring.com/o/4a804e796cd38579/4a804e796cd38579/-/-TRK/1/lib.v3.as3.swf";
		private var kernel:Object;
		private var kernelLoader:Loader;
		private var isOpen:Boolean = false;
		
		public function ClearSpringAPI():void
		{
				
			Security.allowDomain("bin.clearspring.com");
			Security.allowDomain("widgets.clearspring.com");
			kernelLoader = new Loader();
			
			kernelLoader.addEventListener('on_ready', onApiLoad);
			addChild(kernelLoader);
			
			// Load Clearspring kernel
				kernelLoader.load(new URLRequest(kernelUrl),
				new LoaderContext(false,  new ApplicationDomain(ApplicationDomain.currentDomain),SecurityDomain.currentDomain));
		}
		
		private function onApiLoad(e:Event):void
		{
			// Grab reference to actual kernel
				
			kernel = Object(kernelLoader.content).kernel;
			// Send a custom event
			// @see http://www.clearspring.com/docs/tech/apis/in-widget/track
			kernel.track.event('Kernel loaded');
			
			
			
			// @see http://www.clearspring.com/docs/tech/apis/in-widget/context
			trace('You have viewed this widget ' + kernel.context.user.WIDGET_VIEWS + ' times');
			trace('You seem to be in ' + kernel.context.user.geo.getCountry());
			
			
			
			// Retrieves a new embed tag for this widget
			// @see http://www.clearspring.com/docs/tech/apis/in-widget/share
			// Uncomment the following line to see how it works:
			// kernel.share.get('tag', {}, shareCallback);
			
			
			
			// Shows menu on mouse click
			// @see http://www.clearspring.com/docs/tech/apis/in-widget/menu
			kernel.menu.addEventListener(kernel.menu.event.OPEN, onMenuEvent);
			kernel.menu.addEventListener(kernel.menu.event.CLOSE, onMenuEvent);
		//		trace('test');
				stage.addEventListener(MouseEvent.CLICK, function (e:MouseEvent):void {
				
				if (!isOpen && e.target == stage) {
					kernel.menu.show();
				}
			});
				
				kernel.menu.setOptions({widgetId: "4a804e796cd38579"});
				kernel.menu.configure({video_id:FlexGlobals.topLevelApplication.current_video.@id });
				kernel.menu.show();

			
			
			
			// WARNING:
			// Do not publicly deploy a widget containing your user ID, as it can
			// be used to modify any of your widgets. Treat it like your password.
			
			// Updates widget's content template permanently. Use wisely!
			// @see http://www.clearspring.com/docs/tech/apis/in-widget/widget-1
			// To use this call, modify the following line to contain
			// 1. your own Clearspring user ID 
			// 2. your desired content
			// and then uncomment it:
			// kernel.widget.update(YOUR-USER-ID, '4a804e796cd38579', {content: '<h1>insert your own content</h1>'});
			
		}
		
		
		/**
		 * Callback for Clearspring share services; since sharing is asynchronous,
		 * we need to specify a callback function to interpret the results.
		 *
		 * In this example, we're using share.get() below to return an embed tag.
		 *
		 * @see http://www.clearspring.com/docs/tech/apis/in-widget/share#share.get
		 */
		public function shareCallback(status:Number, result:Object):void
		{
			if (status) {
				trace('An error occurred: ' + status);
			} else if (result.tag) {
				trace('Got embed tag: ' + escape(result.tag));
			} else {
				trace('No embed tag returned');
			}
		}
		
		
		
		/**
		 * Callback for Clearspring service menu events. Traces open/closed state of menu each
		 * time it changes.
		 *
		 * @see http://www.clearspring.com/docs/tech/apis/in-widget/menu#menu.addEventListener
		 */
		public function onMenuEvent(event:Event):void
		{
			switch (event.type)
			{
				case kernel.menu.event.OPEN:
					isOpen = true;
					trace('Menu opened!');
					break;
				case kernel.menu.event.CLOSE:
					isOpen = false;
					trace('Menu closed.');
					break;
				default:
					trace('Got a menu event: ' + event);
			}
		}
		
	}
}
