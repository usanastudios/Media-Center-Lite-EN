package components.views
{

import flash.events.MouseEvent;
import mx.collections.ArrayCollection;
import mx.containers.TitleWindow;
import mx.controls.DataGrid;
import mx.events.ListEvent;
import mx.events.ValidationResultEvent;
import mx.managers.PopUpManager;
import mx.validators.EmailValidator;
import spark.components.Button;
import spark.components.TextInput;


public class SendEmailPageBaseClass extends TitleWindow
{
	
	public var cancel_btn:Button; 
	public var add_email_btn:Button; 
	public var target_email:TextInput;
	public var email_dg:DataGrid;
	public var emailValidator:EmailValidator;
	 
	[Bindable] public var emailArrayColl:ArrayCollection = new ArrayCollection();
	
	/* ================================ */
	/* = INITIALIZE SEND EMAIL WINDOW = */
	/* ================================ */
	public function init():void
	{
		cancel_btn.addEventListener(MouseEvent.CLICK, cancelEmail);
	}
	
	
	
	/* ================================ */
	/* = FUNCTION TO CANCEL THE EMAIL = */
	/* ================================ */
	public function cancelEmail(event:MouseEvent):void
	{
		PopUpManager.removePopUp(this);
	}
	
	

	
	/* ================================================== */
	/* = FUNCTION TO DELETE EMAIL FROM ARRAY COLLECTION = */
	/* ================================================== */
	public function deleteEmail(event:ListEvent):void
	{
		emailArrayColl.removeItemAt(event.currentTarget.selectedIndex);
	}
	
	
	/* ================================================= */
	/* = FUNCTION TO VALIDATE EMAIL ADDRESS WHEN ADDED = */
	/* ================================================= */
	public function validateEmail():void
	{
		emailValidator = new EmailValidator();  
		emailValidator.addEventListener(ValidationResultEvent.VALID, emailValidator_valid);
	    emailValidator.addEventListener(ValidationResultEvent.INVALID, emailValidator_invalid);  
		emailValidator.validate(target_email.text);
		
	}
	
	private function emailValidator_valid(evt:ValidationResultEvent):void 
		{
	        emailArrayColl.addItem({"email":target_email.text});
			email_dg.dataProvider = emailArrayColl;
	    }

       private function emailValidator_invalid(evt:ValidationResultEvent):void {
		
           mx.controls.Alert.show("You entered an invalid email address:",null,0,email_dg);
      
       }
}

}

