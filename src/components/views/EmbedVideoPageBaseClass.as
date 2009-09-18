package components.views
{

import mx.containers.TitleWindow;
import components.controls.ClearspringAPI;
import mx.core.UIComponent;
import mx.controls.Alert;
import mx.core.mx_internal;



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
	
	
	/* =================================== */
	/* = ADJUST POSITION OF CLOSE BUTTON = */
	/* =================================== */
	public function setCloseButton():void
	{
		
				this.mx_internal::closeButton.x = 522;
				this.mx_internal::closeButton.y = -6;
				this.mx_internal::closeButton.width = 29;
				this.mx_internal::closeButton.height = 29;
				this.mx_internal::closeButton.buttonMode = true;
				this.mx_internal::closeButton.useHandCursor = true;
	}
	
   

}

}

