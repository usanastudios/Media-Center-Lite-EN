//AS3///////////////////////////////////////////////////////////////////////////
// 
// Copyright 2009 USANA Health Sciences, Inc.
// 
////////////////////////////////////////////////////////////////////////////////

package components.views
{
	import flash.events.MouseEvent;
	import mx.controls.Menu;
	import spark.components.Application;
	import spark.components.Button;
	import spark.components.TextInput;
	import mx.core.FlexGlobals;
	import mx.containers.ViewStack;
	

	public class MainBaseClass extends Application
	{
		
		/* ===================== */
		/* = PRIVATE VARIABLES = */
		/* ===================== */
		
		
		/* ==================== */
		/* = PUBLIC VARIABLES = */
		/* ==================== */
		public var prospectMenu1_btn:Button;
		public var prospectMenuData:XML;
		public var search_btn:Button;
		public var search_txt:TextInput;
		public var video_list:XML;
		public var main_view_stack:ViewStack;
		public var current_search_term:String;
		
		/* ====================== */
		/* = BINDABLE VARIABLES = */
		/* ====================== */
		[BINDABLE] public var current_video:XML;
		
		
		
		/* =================================== */
		/* = FUNCTION TO INITIALIZE MAIN APP = */
		/* =================================== */
		public function initMainApp():void
		{
			/*EVENT LISTENERS*/
			prospectMenu1_btn.addEventListener(MouseEvent.CLICK,createAndShowProspectMenu1);
			search_btn.addEventListener(MouseEvent.CLICK,search);
			
			
			
			/*DEFINE DATA FOR THE PROSPECT MENU*/
			prospectMenuData = <root>
	           <menuitem label=""/>
	           <menuitem label="True Wealth"/> 
	           <menuitem label="True Health" >
	                <menuitem label="Skin Care"/>
	                <menuitem label="Nutrition"/> 
	                <menuitem label="Energy"/>
	                <menuitem label="Atheletes"/>
	            </menuitem>
	            <menuitem label="USANA Health Sciences"/> 
	            <menuitem label="I'm Not Sure"/>
        	</root>;
    
		}
		
		
	  	/* ======================================== */
        /* = CREATE AND DISPLAY THE PROSPECT MENU1 CONTROL. = */
        /* ======================================== */
        public function createAndShowProspectMenu1(event:MouseEvent):void {
            var prospectMenu1:Menu = Menu.createMenu(null, prospectMenuData, false);
            prospectMenu1.labelField="@label";
            prospectMenu1.styleName="prospectMenu1";
            prospectMenu1.width = 220;
            prospectMenu1.show(340, 58);
          }
          
          
      	/* ============================================== */
		/* = FUNCTION TO SEARCH THE XML FILE FOR VIDEOS = */
		/* ============================================== */
		public function search(event:MouseEvent):void
		{	

			//SET UP FIRST VIDEO THAT WILL PLAY
			current_video = video_list.video[0];
			//SET CURRENT SEARCH TERM
			FlexGlobals.topLevelApplication.current_search_term = search_txt.text;
			
			main_view_stack.selectedIndex = 1;
		}


		
		/* =================================================================== */
		/* = FUNCTION TO GET MOST RECENT VIDEOS AND GO TO RECENT VIDEOS PAGE = */
		/* =================================================================== */
		public function get_recent_videos():void
		{
			main_view_stack.selectedIndex = 1;
			
		}
          
          
 
          
	}
}