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
import spark.components.TextArea;
import mx.rpc.http.mxml.HTTPService;
import mx.containers.ViewStack;
import spark.components.CheckBox;
import mx.core.UIComponent;
import mx.core.mx_internal;
import flash.system.System;

import components.data.MochiBot;

public class SendEmailPageBaseClass extends TitleWindow
{
	
	public var cancel_btn:Button; 
	public var send_btn:Button; 
	public var add_email_btn:Button; 
	public var target_email:TextInput;
	public var email_dg:DataGrid;
	public var emailValidator:EmailValidator;



	 
	[Bindable] public var emailArrayColl:ArrayCollection = new ArrayCollection();
	[Bindable] public var your_name:TextInput;
	[Bindable] public var your_email:TextInput;
	[Bindable] public var your_subject:TextInput;
	[Bindable] public var your_message:TextArea;
	[Bindable] public var email_svc:HTTPService;
	[Bindable] public var email_view_stack:ViewStack;
	[Bindable] public var send_to_self_chk:CheckBox;
	[Bindable] public var direct_link:TextInput;
 

  /* ================================ */
  /* = INITIALIZE SEND EMAIL WINDOW = */
  /* ================================ */
	public function init():void
	{
		cancel_btn.addEventListener(MouseEvent.CLICK, cancelEmail);
		send_btn.addEventListener(MouseEvent.CLICK,send_email);
		
		this.mx_internal::closeButton.x = 778;
		this.mx_internal::closeButton.y = -6;
		this.mx_internal::closeButton.width = 29;
		this.mx_internal::closeButton.height = 29;
		this.mx_internal::closeButton.buttonMode = true;
		this.mx_internal::closeButton.useHandCursor = true;
		
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



	/* ========================== */
	/* = FUNCTION TO SEND EMAIL = */
	/* ========================== */
	public function send_email(event:MouseEvent):void
	{
		//BE SURE FIELDS ARE FILLED OUT
		if(your_name.text.length > 0 && your_email.text.length > 0 && your_subject.text.length > 0 && your_message.text.length > 0 && emailArrayColl.length > 0)
		{

			//PUT UP THE "SENDING EMAILS" SCREEN
			email_view_stack.selectedIndex = 1;
			
			//FOR EACH EMAIL ADDRESS, SEND EMAIL
			for each (var email:Object in emailArrayColl)
			{ 
				email_action(email.email);
				//TRACK WITH MOCHIBOT
				MochiBot.track(this, "9a3ec6e1");
				
			}
			
			//IF SEND TO SELF IS CHECKED, SEND EMAIL TO SENDER'S EMAIL
			if (send_to_self_chk.selected == true)
			{
				email_action(your_email.text);
				MochiBot.track(this, "9a3ec6e1");
				
			}
			
		}
		else
		{
			mx.controls.Alert.show("Please make sure all fields are filled in.");
			
		}
	}
	
	/* ============================== */
	/* = ACTION EMAIL SEND FUNCTION = */
	/* ============================== */
	public function email_action(emailAddress:String):void
	{
			var randEMailId:Number = Math.round (Math.random() *9999999999);
			var params:Object = {};
			
			params['email1'] = emailAddress;
			params['fromname'] = your_name.text;
			params['fromemail'] = your_email.text;
			params['subject'] = your_subject.text;
			params['body'] = your_message.text+ "\n Link to standalone video will go here. Video ID for this one is"+parentDocument.current_video.@id;
			params['videoID'] = parentDocument.current_video.@id;
			params['emailID'] = randEMailId;
			email_svc.send(params);
			
		
	}
	
	/* ========================================= */
	/* = FUNCTION CALLED AFTER EACH EMAIL SENT = */
	/* ========================================= */
	public function emailResultHandler():void
	{
		//PUT UP "EMAILS SENT" SCREEN
		email_view_stack.selectedIndex = 2;
	}
	
	
	/* ================================== */
	/* = FUNCTION TO CLOSE EMAIL WINDOW = */
	/* ================================== */
	public function close_email_window():void
	{
		PopUpManager.removePopUp(this);
	}
	
	
	/* ================================================ */
	/* = FUNCTION TO COPY VIDEO LINK TO THE CLIPBOARD = */
	/* ================================================ */
	public function copyLinkToClipboard():void
	{
		System.setClipboard(direct_link.text);
		
	}
}

}

