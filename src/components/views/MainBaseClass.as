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
	import mx.events.MenuEvent;
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
		public var recommended_search_svc:HTTPService;
		public var video_player_basic_view:VideoPlayerBasic;
		public var video_player_recommended_view:VideoPlayerRecommended;
		public var search_text_validator:Validator;
		public var current_search_message:String
		public var current_video:XML;
		
		
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
			prospectMenu1.addEventListener(MenuEvent.ITEM_CLICK, prospectMenu1ClickHandler);
          }
          


		/* =========================================================== */
		/* = FUNCTION CALLED WHEN SELECTION IS MADE IN PROSPECT MENU = */
		/* =========================================================== */
		public function prospectMenu1ClickHandler(event:MenuEvent):void
		{
			if (event.label == "True Wealth")
			{
				recommendedSearch("True Wealth");
			}
			else if (event.label == "Skin Care")
			{
				recommendedSearch("Skin Care");
			}
			else if (event.label == "Nutrition")
			{
				recommendedSearch("Nutrition");
			}
			else if (event.label == "Energy")
			{
				recommendedSearch("Energy");
			}
			else if (event.label == "Atheletes")
			{
				recommendedSearch("Atheletes");
			}
			else if (event.label == "USANA Health Sciences")
			{
				recommendedSearch("USANA Health Sciences");
			}
			
		}
          
      	/* ============================================== */
		/* = FUNCTION TO DO BASIC SEARCH FOR VIDEOS = */
		/* ============================================== */
		public function search(event:MouseEvent):void
		{	

			//SET CURRENT SEARCH TERM
			current_search_term = '';
			current_search_term = search_txt.text;
			current_search_message = "Searching for '" + current_search_term + "'";
			
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
		               //vpchild.pausePlayback();
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
				current_video = video_list.video[0];
				main_view_stack.selectedIndex = 1;
			}
			else
			{
				mx.controls.Alert.show("No results found. Please try a different search term");
				main_view_stack.selectedIndex = 0;
			}
		}
		
		
		/* ============================================== */
		/* = FUNCTION TO DO RECOMMENDED SEARCH FOR VIDEOS = */
		/* ============================================== */
		public function recommendedSearch(search_term:String):void
		{	
			
				/*SET CURRENT SEARCH TERM (FOR DISPLAY ON VIDEO PLAYER PAGE)*/
				current_search_term = search_term;
				
				/*SEARCHING MESSAGE*/
				current_search_message = "Getting videos for '" +search_term+ "'";
				
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
				var params:Object = new Object;
	 			params['q'] = search_term;
				params['l'] = "en";
				recommended_search_svc.send(search_term);
			} 
					
		
    	
		
		/* ============================================================== */
		/* = FUNCTION CALLED WHEN RECOMMENDED SEARCH RESULT IS RETURNED = */
		/* ============================================================== */
		public function recommendedSearchResultHandler():void
		{
			
			/*SET THE VIDEO_LIST RESULTS*/
			video_list = recommended_search_svc.lastResult as XML;
				
			if ((video_list) && (video_list.video.length() > 0))
			{			
				current_video = video_list.video[0];
				main_view_stack.selectedIndex = 3;
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
			current_video = video_list.video[0];
			
		}
          
          
  
          
	}
}