//AS3///////////////////////////////////////////////////////////////////////////
// 
// Copyright 2009 USANA Health Sciences, Inc.
// 
////////////////////////////////////////////////////////////////////////////////

package components.views
{
	import flash.events.MouseEvent;
	import modules.video_player.VideoPlayerInterface;
	import components.views.VideoPlayerBasic;
	import mx.containers.ViewStack;
	import mx.controls.Alert;
	import mx.controls.Menu;
	import mx.rpc.http.mxml.HTTPService;
	import mx.validators.Validator;
	
	import spark.components.Application;
	import spark.components.Button;
	import spark.components.TextInput;

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
		public var video_list:XML = new XML;
		public var main_view_stack:ViewStack;
		public var current_search_term:String;
		public var search_svc:HTTPService;
		public var video_player_basic_view:VideoPlayerBasic;
		public var search_text_validator:Validator;
		
		/* ====================== */
		/* = BINDABLE VARIABLES = */
		/* ====================== */
		[Bindable]public var search_txt:TextInput;
		
		
		
		
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
            prospectMenu1.width = 224;
            prospectMenu1.rowHeight = 27;
            prospectMenu1.show(240, 60);
          }
          
          
      	/* ============================================== */
		/* = FUNCTION TO SEARCH THE XML FILE FOR VIDEOS = */
		/* ============================================== */
		public function search(event:MouseEvent):void
		{	

			//SET CURRENT SEARCH TERM
			current_search_term = '';
			current_search_term = search_txt.text;
			
			
			if(current_search_term.length == 0)
			{
				mx.controls.Alert.show("Please enter a search term.");
			}
			else
			{
				
				/*POP UP SEARCHING VIEW*/
				main_view_stack.selectedIndex = 2;
				
				
				
				/*STOP VIDEO IF PLAYING*/
				if (main_view_stack.selectedIndex == 1)
				{
					var vpchild:* = video_player_basic_view.video_player.child as VideoPlayerInterface;                
		            if (video_player_basic_view.video_player.child != null) {                    
		                // Call setters in the module to adjust its
		                // appearance when it loads.
		               vpchild.pausePlayback();
		            } else {                
		                trace("Uh oh. The video_player.child property is null");                 
		            }
				}
				
				
				/*CALL THE WEB SERVICE*/
				search_svc.send();
			} 
					
		}
		
		
		/* ================================================== */
		/* = FUNCTION CALLED WHEN SEARCH RESULT IS RETURNED = */
		/* ================================================== */
		public function searchResultHandler():void
		{
			
			
			/*SET THE VIDEO_LIST RESULTS*/
			video_list = search_svc.lastResult as XML;
				
			if ((video_list) && (video_list.video.length() > 0))
			{			
				video_player_basic_view.current_video = video_list.video[0];
				main_view_stack.selectedIndex = 1;
			}
			else
			{
				mx.controls.Alert.show("No results found. Please try a different search term");
				main_view_stack.selectedIndex = 0;
			}
		}

		
		/* =================================================================== */
		/* = FUNCTION TO GET MOST RECENT VIDEOS AND GO TO RECENT VIDEOS PAGE = */
		/* =================================================================== */
		public function get_recent_videos():void
		{
			video_list = search_svc.lastResult as XML;
			video_player_basic_view.current_video = video_list.video[0];
			
		}
          
          
  
          
	}
}