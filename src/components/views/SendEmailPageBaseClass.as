package components.views
{

import components.data.MochiBot;

import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.system.System;
import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.containers.FormItem;
import mx.containers.TitleWindow;
import mx.containers.ViewStack;
import mx.controls.DataGrid;
import mx.controls.Text;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.ListEvent;
import mx.events.ValidationResultEvent;
import mx.managers.CursorManager;
import mx.managers.PopUpManager;
import mx.rpc.http.mxml.HTTPService;
import mx.validators.EmailValidator;

import spark.components.Button;
import spark.components.CheckBox;
import spark.components.TextArea;
import spark.components.TextInput;

public class SendEmailPageBaseClass extends TitleWindow
{
	
	public var cancel_btn:Button; 
	public var send_btn:Button; 
	public var add_email_btn:Button; 
	public var target_email:TextInput;
	public var email_dg:DataGrid;
	public var emailValidator:EmailValidator;
	public var copyTimer:Timer;


	 
	[Bindable] public var emailArrayColl:ArrayCollection = new ArrayCollection();
	[Bindable] public var your_name:TextInput;
	[Bindable] public var your_email:TextInput;
	[Bindable] public var your_subject:TextInput;
	[Bindable] public var your_message:TextArea;
	[Bindable] public var email_svc:HTTPService;
	[Bindable] public var email_view_stack:ViewStack;
	[Bindable] public var send_to_self_chk:CheckBox;
	[Bindable] public var direct_link:TextInput;
	[Bindable] public var headertext:Text;
	[Bindable] public var send_to_self_chk_fi:FormItem;
	[Bindable] public var codeCopiedText:FormItem;
 

  /* ================================ */
  /* = INITIALIZE SEND EMAIL WINDOW = */
  /* ================================ */
	public function init():void
	{
		
		var formattedHeader:String = "Send <font color='#4d6d84'>" + parentDocument.current_video.title + "</font> to a prospect";
		headertext.htmlText = formattedHeader;
		cancel_btn.addEventListener(MouseEvent.CLICK, cancelEmail);
		send_btn.addEventListener(MouseEvent.CLICK,send_email);
	
		copyTimer = new Timer(1000, 3);

		addEventListener(FlexEvent.UPDATE_COMPLETE, moveCloseButton);
		
	}
	
	public function moveCloseButton(e:FlexEvent):void {

		
		/*ADJUST CLOSE BUTTON*/
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
		
           mx.controls.Alert.show("Please enter a valid email address",null,0,email_dg);
      
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
			//email_view_stack.selectedIndex = 1;
			
			// SET BUSY CURSOR
			CursorManager.setBusyCursor();

			
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
			params['body'] = your_message.text+ "<br><br>Watch This USANA video: http://www.usanamedia.com/Media-Center-Lite-Standalone/main.html#video_id="+parentDocument.current_video.@id;
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
		email_view_stack.selectedIndex = 1;
		
		// REMOVE BUSY CURSOR
		CursorManager.removeBusyCursor();
		
		/*ADJUST CLOSE BUTTON*/
		this.mx_internal::closeButton.x = 778;
		this.mx_internal::closeButton.y = -6;
		this.mx_internal::closeButton.width = 29;
		this.mx_internal::closeButton.height = 29;
		this.mx_internal::closeButton.buttonMode = true;
		this.mx_internal::closeButton.useHandCursor = true;

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
		
		copyTimer.reset();
		codeCopiedText.visible=true;
		copyTimer.addEventListener(TimerEvent.TIMER_COMPLETE, deleteTimer);
		copyTimer.start();
		
	}
	
	public function deleteTimer(evt:TimerEvent):void
	{

		codeCopiedText.visible=false;
		
	}
	
	public function send_to_self_chk_clickHandler(event:MouseEvent):void
	{
		
		if (send_to_self_chk.selected == true ) {
			send_to_self_chk_fi.styleName="checkSelected";
		} else {
			send_to_self_chk_fi.styleName="checkUnselected";
		}
		
	}
	
}

}

