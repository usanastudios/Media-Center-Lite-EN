package components.views
{

	import flash.events.Event;
	
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.Menu;
	import mx.controls.SWFLoader;
	import mx.events.MenuEvent;
	import mx.utils.StringUtil;
	
	import spark.components.Button;

public class LandingPageBaseClass extends Canvas
{
	 
	/* ==================== */
	/* = PUBLIC VARIABLES = */
	/* ==================== */
	public var prospectMenu2_btn:Button;
	public var wall:SWFLoader;
	
	public function initLandingPage():void
	{
	
	}
	
	
	/* ========================================================================= */
	/* = FUNCTION CALLED WHEN THE WALL IS LOADED - ADDS EVENT LISTENER TO WALL = */
	/* ========================================================================= */
	public function wallLoaded(event:Event): void {
    	wall.content.addEventListener("Wall3DEvent", wallClick);
	}
	

	/* ========================================================================== */
	/* = FUNCTION CALLED WHEN WALL CLICKED - RETURNS ITEM CLICKED ON WALL (SWF) = */
	/* ========================================================================== */
	public function wallClick(event:Event):void
	{
		//GET VIDEO ID
		var thumbUrl:String = StringUtil.trim(event.currentTarget.wall.selectedElement.src);
		var lastSlash:Number = thumbUrl.lastIndexOf("/");
		var video_id:String = thumbUrl.substr(lastSlash + 1).replace(".jpg","");
		parentDocument.selectedWallVideoID = video_id;
	    parentDocument.getWallVideo();
	    
	}
	

	/* =========================================== */
     /* =  CREATE AND DISPLAY THE MENU 2 CONTROL. = */ 
     /* =========================================== */
     public function createAndShowProspectMenu2():void {
         var prospectMenu2:Menu = Menu.createMenu(null, parentDocument.prospectMenuData, false);
         prospectMenu2.labelField="@label";
         prospectMenu2.styleName="prospectMenu1";
		prospectMenu2.setStyle("border-thickness",0);
         prospectMenu2.width = 250;
         prospectMenu2.rowHeight = 27;
         prospectMenu2.show(prospectMenu2_btn.x + 12,prospectMenu2_btn.y + 95);
		 prospectMenu2.addEventListener(MenuEvent.ITEM_CLICK, parentDocument.prospectMenu1ClickHandler);
		
     }
    
	
}

}

