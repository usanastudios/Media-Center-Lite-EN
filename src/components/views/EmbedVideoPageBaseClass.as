package components.views
{

import components.controls.ClearSpringTest;

import mx.containers.TitleWindow;
import mx.core.UIComponent;
import mx.core.mx_internal;




public class EmbedVideoPageBaseClass extends TitleWindow
{
	  
	
	
	/* ================================ */
	/* = INITIALIZE SEND EMAIL WINDOW = */
	/* ================================ */
	public function init():void
	{
	
		
			var clearspring:ClearSpringTest = new ClearSpringTest();
			var csWrapper:UIComponent = new UIComponent();
			csWrapper.setStyle('backgroundColor',0xFFFFFF);
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

