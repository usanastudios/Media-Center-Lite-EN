package components.controls
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	import flash.utils.*;
	
	import mx.core.FlexGlobals;
	
		
		public class ClearSpringTest extends Sprite
		{
			private static const wid:String = '4a804e796cd38579';
			private var _api:Object;
			private var isOpen:Boolean = false;
			
			public function ClearSpringTest()
			{
				Security.allowDomain("bin.clearspring.com");
				Security.allowDomain("widgets.clearspring.com");
				var kernelUrl:String = 'http://widgets.clearspring.com/o/'+wid+'/-/-TRK/1/lib.as3.swf';
				var url:URLRequest = new URLRequest(kernelUrl);
				
				var api:Loader = new Loader();
				api.contentLoaderInfo.addEventListener(Event.COMPLETE, onApiLoad);
				addChild(api);
				
				// Load Clearspring kernel into our security domain
				api.load(url, new LoaderContext(false, ApplicationDomain.currentDomain,
					SecurityDomain.currentDomain));
			}
			
			private function onApiLoad(e:Event):void 
			{
				// Grab API reference
				_api = e.target.loader.content;
				
				trace('User has viewed me ' + _api.context.user.WIDGET_VIEWS + ' times');
				
				// Show service menu
				//_api.menu.show();
				_api.menu.addEventListener(_api.menu.event.OPEN, onMenuEvent);
				_api.menu.addEventListener(_api.menu.event.CLOSE, onMenuEvent);
				stage.addEventListener(MouseEvent.CLICK, function (e:MouseEvent):void {
					if (!isOpen && e.target == stage) {
						_api.menu.show();
					}
				});
				
				_api.menu.setOptions({widgetId: "4a804e796cd38579"});
				_api.menu.configure({video_id:FlexGlobals.topLevelApplication.current_video.@id });
				_api.menu.show();
				

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
					case _api.menu.event.OPEN:
						isOpen = true;
						trace('Menu opened!');
						break;
					case _api.menu.event.CLOSE:
						isOpen = false;
						trace('Menu closed.');
						break;
					default:
						trace('Got a menu event: ' + event);
				}
			}
			
			
			
		}
		

		
}