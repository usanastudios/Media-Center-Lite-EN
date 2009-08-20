package components.views
{

import mx.containers.TitleWindow;
import mx.managers.PopUpManager;
import mx.core.mx_internal;

public class RecommendedPopUpBaseClass extends TitleWindow
{
	public function init():void
	{
		
		/*ADJUST CLOSE BUTTON*/
		this.mx_internal::closeButton.x = 778;
		this.mx_internal::closeButton.y = -6;
		this.mx_internal::closeButton.width = 29;
		this.mx_internal::closeButton.height = 29;
		this.mx_internal::closeButton.buttonMode = true;
		this.mx_internal::closeButton.useHandCursor = true;
	}

}

}

