package components.views
{

	import flash.events.MouseEvent;
	import mx.containers.Canvas;
	import mx.controls.Menu;
	import mx.core.FlexGlobals;
	import spark.components.Button;


public class LandingPageBaseClass extends Canvas
{
	
	/* ==================== */
	/* = PUBLIC VARIABLES = */
	/* ==================== */
	public var prospectMenu2_btn:Button;
	
	public function initLandingPage():void
	{
		/*EVENT LISTENERS*/
		prospectMenu2_btn.addEventListener(MouseEvent.CLICK,createAndShowProspectMenu2);
	}
	
	
	/* =========================================== */
     /* =  CREATE AND DISPLAY THE MENU 2 CONTROL. = */
     /* =========================================== */
     public function createAndShowProspectMenu2(event:MouseEvent):void {
         var prospectMenu2:Menu = Menu.createMenu(null, FlexGlobals.topLevelApplication.prospectMenuData, false);
         prospectMenu2.labelField="@label";
         prospectMenu2.styleName="prospectMenu1";
         prospectMenu2.width = 250;
         prospectMenu2.rowHeight = 27;
         prospectMenu2.show(443, 195);
     }
    
	
}

}

