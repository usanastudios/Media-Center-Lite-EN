package components.views
{

	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.Menu;
	import mx.controls.SWFLoader;
	import mx.events.MenuEvent;
	
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
	
	wall.content.addEventListener("Wall3DEvent", wallClick);
	
	}
	
	public function wallClick():void
	{
		Alert.show("wall clicked");
	}
	
	/* =========================================== */
     /* =  CREATE AND DISPLAY THE MENU 2 CONTROL. = */
     /* =========================================== */
     public function createAndShowProspectMenu2():void {
         var prospectMenu2:Menu = Menu.createMenu(null, parentDocument.prospectMenuData, false);
         prospectMenu2.labelField="@label";
         prospectMenu2.styleName="prospectMenu1";
         prospectMenu2.width = 250;
         prospectMenu2.rowHeight = 27;
         prospectMenu2.show(443, 195);
		 prospectMenu2.addEventListener(MenuEvent.ITEM_CLICK, parentDocument.prospectMenu1ClickHandler);
		
     }
    
	
}

}

