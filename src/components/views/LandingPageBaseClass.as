package components.views
{

	import flash.events.MouseEvent;
	import mx.containers.Canvas;
	import mx.controls.Menu;
	import spark.components.Button;


public class LandingPageBaseClass extends Canvas
{
	
	/* ==================== */
	/* = PUBLIC VARIABLES = */
	/* ==================== */
	public var prospectMenu2_btn:Button;
	
	public function initLandingPage():void
	{
		
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
     }
    
	
}

}

