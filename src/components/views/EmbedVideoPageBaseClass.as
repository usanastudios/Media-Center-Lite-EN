package components.views
{

import mx.containers.TitleWindow;
import components.controls.ClearspringAPI;
import mx.core.UIComponent;
import mx.controls.Alert;


public class EmbedVideoPageBaseClass extends TitleWindow
{
	  
	
	
	/* ================================ */
	/* = INITIALIZE SEND EMAIL WINDOW = */
	/* ================================ */
	public function init():void
	{
		
			var clearspring:ClearspringAPI = new ClearspringAPI();
			var csWrapper:UIComponent = new UIComponent();
			csWrapper.addChild(clearspring);
			this.addElement(csWrapper);
	}
	
   

}

}

