package components.views
{

	import flash.events.MouseEvent;
	import mx.containers.Canvas;
	import mx.controls.Menu;
	import mx.events.MenuEvent;
	import spark.components.Button;
	import mx.controls.Alert;



public class LandingPageBaseClass extends Canvas
{
	
	/* ==================== */
	/* = PUBLIC VARIABLES = */
	/* ==================== */
	public var prospectMenu2_btn:Button;
	
	public function initLandingPage():void
	{
		parentApplication.landing_page_view.wall.content.addEventListener("Wall3DEvent", wallClick);
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

