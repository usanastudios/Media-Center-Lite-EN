//AS3///////////////////////////////////////////////////////////////////////////
// 
// Copyright 2009 USANA Health Sciences, Inc.
// 
////////////////////////////////////////////////////////////////////////////////

package components.views
{

	
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import modules.video_player.VideoPlayerInterface;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.collections.XMLListCollection;
	import mx.containers.ViewStack;
	import mx.controls.Alert;
	import mx.controls.LinkButton;
	import mx.controls.Menu;
	import mx.core.FlexGlobals;
	import mx.events.MenuEvent;
	import mx.formatters.DateFormatter;
	import mx.managers.PopUpManager;
	import mx.rpc.http.mxml.HTTPService;
	import mx.validators.Validator;
	import mx.controls.TextInput;
	
	import spark.components.Application;
	import spark.components.Button;

	

	public class MainBaseClass extends Application
	{

		/* ==================== */
		/* = PUBLIC VARIABLES = */
		/* ==================== */
		public var akamaiArray:ArrayCollection = new ArrayCollection();
		//public var akamai_svc:HTTPService;
		public var all_videos_svc:HTTPService;
		public var auto_complete_svc:HTTPService;
		public var clipentArray:ArrayCollection = new ArrayCollection();
		public var current_search_message:String
		public var current_video:XML;
		public var landing_page_view:components.views.LandingPage;
		public var lastPageSelectedButton:LinkButton;
		public var last_selected_page:Number;
		public var main_view_stack:ViewStack;
		public var mostRecent_btn:Button;
		//public var mostViewed_btn:Button;

		//public var most_viewed_videos_svc:HTTPService;

		public var most_viewed_videos_svc:HTTPService;

		public var recommendedXML_svc:HTTPService;
		public var prospectMenu1_btn:Button;
		public var prospectMenuData:XML;
		public var recent_videos_svc:HTTPService;
		public var recommended_search_svc:HTTPService;
		public var search_svc:HTTPService;
		public var search_text_validator:Validator;
		public var selectedWallVideoID:String;
		public var video_list:XML = new XML;
		public var video_player_basic_view:VideoPlayerBasic;
		public var video_player_recommended_view:VideoPlayerRecommended;
		public var wall_video_svc:HTTPService;
		public var recommended_searchTitle:String;
		public var recommended_searchTerm:String;
		public var playNow:Boolean;
		
		
		public static const LANGUAGE:String = "en";
		
		/* ====================== */
		/* = BINDABLE VARIABLES = */
		/* ====================== */
		[Bindable] public var akamai_start_date:String;
		[Bindable] public var akamai_stop_date:String;
		[Bindable] public var audio_btn:Button;
		[Bindable] public var current_search_term:String;
		[Bindable] public var dateFormatter:DateFormatter;
		[Bindable] public var myDP:XMLListCollection;
		[Bindable] public var results_for:String;
		[Bindable] public var search_btn:Button;
		[Bindable] public var search_results_dp:ArrayCollection = new ArrayCollection();
		//[Bindable] public var search_txt:AutoComplete;
		[Bindable] public var search_txt:TextInput;
		[Bindable] public var search_type:String;
		[Bindable] public var video_long_description:String;
		[Bindable] public var video_short_description:String;
		[Bindable] public var video_title:String;
		[Bindable] public var recommended_videos:XMLList;
		

		

		
		/* =================================== */
		/* = VARS FOR PAGINATION OF TILELIST = */
		/* =================================== */
		[Bindable] public var pagedDataProvider:ArrayCollection;
		[Bindable] public var currentPage:int=1;
		[Bindable] public var pageCount:int=0;
		[Bindable] public var pageCountDummyArray:Array;
		private var PERPAGE:int=15;
	
		
		
		
		/* =================================== */
		/* = FUNCTION TO INITIALIZE MAIN APP = */
		/* =================================== */
		public function initMainApp():void
		{
			
			// Inititates the autocomplete
			 //auto_complete_svc.send();
		
			recommendedXML_svc.send();
			
		
			
			
			/*EVENT LISTENERS*/
			prospectMenu1_btn.addEventListener(MouseEvent.CLICK,createAndShowProspectMenu1);
			search_btn.addEventListener(MouseEvent.CLICK,search);
			//mostViewed_btn.addEventListener(MouseEvent.CLICK,get_most_viewed);
			mostRecent_btn.addEventListener(MouseEvent.CLICK,get_most_recent);
			audio_btn.addEventListener(MouseEvent.CLICK, navigateToAudio);
			
			
			//DISABLE MOST VIEWED BUTTON UNTIL WE GET AKAMI RESULTS BACK
			//mostViewed_btn.enabled = false;
			
			/*DEFINE AKAMAI START AND STOP DATES*/
			akamai_start_date = "2009-01-01";
			akamai_stop_date = dateFormatter.format(new Date());
			
			//CALL THE AKAMAI SERVICE AND GET ALL VIDEO INFO
			//akamai_svc.send();
			
			/*DEFINE DATA FOR THE PROSPECT MENU*/
			prospectMenuData = <root>
	           <menuitem label="True Wealth">
	          	 	<menuitem label="The Pay Plan"/>
	           		<menuitem label="The Opportunity"/>
	           		<menuitem label="Wealth Testimonials"/>
	           </menuitem> 
	           <menuitem label="True Health" >
	                <menuitem label="Skin Care"/>
	                <menuitem label="Nutrition"/> 
	                <menuitem label="Energy"/>
	                <menuitem label="Athletes"/>
	                <menuitem label="Health Testimonials"/>
	            </menuitem>
	            <menuitem label="USANA Health Sciences"/> 


        	</root>;

    

	            


		}
		
	
		
	  	/* ======================================== */
        /* = CREATE AND DISPLAY THE PROSPECT MENU1 CONTROL. = */
        /* ======================================== */
        public function createAndShowProspectMenu1(event:MouseEvent):void {
            var prospectMenu1:Menu = Menu.createMenu(null, prospectMenuData, false);
            prospectMenu1.labelField="@label";
            prospectMenu1.styleName="prospectMenu1";
            prospectMenu1.width = 226;
            prospectMenu1.rowHeight = 27;
            prospectMenu1.show(361, 60);
			prospectMenu1.addEventListener(MenuEvent.ITEM_CLICK, prospectMenu1ClickHandler);
          }
          


		/* =========================================================== */
		/* = FUNCTION CALLED WHEN SELECTION IS MADE IN PROSPECT MENU = */
		/* =========================================================== */
		public function prospectMenu1ClickHandler(event:MenuEvent):void
		{

			if (event.label == "Skin Care")
			{
				recommendedPopUp("skin","Skin Care",recommendedXML_svc.lastResult.skincare.video);
			}
			else if (event.label == "Nutrition")
			{
				recommendedPopUp("nutrition","Nutrition",recommendedXML_svc.lastResult.nutrition.video);
			}
			else if (event.label == "Energy")
			{
				recommendedPopUp("energy","Energy",recommendedXML_svc.lastResult.energy.video);
			}
			else if (event.label == "Athletes")
			{
				recommendedPopUp("athletes","Athletes",recommendedXML_svc.lastResult.athletes.video);
			}
			else if (event.label == "USANA Health Sciences")
			{
				recommendedPopUp("usana","USANA Health Sciences",recommendedXML_svc.lastResult.usanahealthsciences.video);
			}
			else if (event.label == "The Pay Plan")
			{
				recommendedPopUp("comp plan","The Pay Plan",recommendedXML_svc.lastResult.thepayplan.video);
			}
			else if (event.label == "The Opportunity")
			{
				recommendedPopUp("opportunity","The Opportunity",recommendedXML_svc.lastResult.opportunity.video);
			}
			else if (event.label == "Health Testimonials")
			{
				recommendedPopUp("health","Health Testimonials",recommendedXML_svc.lastResult.healthtestimonials.video);
			}
			else if (event.label == "Wealth Testimonials")
			{
				recommendedPopUp("wealth","Wealth Testimonials",recommendedXML_svc.lastResult.wealth.video);
			}			
			else if (event.label == "I'm Not Sure")
			{
				//IF NOT SURE, GET MOST VIEWED
				//get_most_viewed();
			}
			
		} 
		
		
		/* ========================================= */
		/* = FUNCTION TO POP UP RECOMMENDED VIDEOS = */
		/* ========================================= */
		public function recommendedPopUp(searchTerm:String,searchTitle:String,serviceResult:XMLList):void
		{
			var recommendedPopUp:RecommendedPopUp = new components.views.RecommendedPopUp();
	        PopUpManager.addPopUp(recommendedPopUp, this, true);
			recommendedPopUp.y = 100;
			recommendedPopUp.x = 100;
			recommendedPopUp.weRecommend_txt.text ='USANA recommends these videos for "'+searchTitle+'"';
			recommended_videos = serviceResult;
			recommended_searchTerm = searchTerm;
			recommended_searchTitle = searchTitle;
		}
		     
		/* ============================================== */
		/* = FUNCTION TO NAVIGATE TO AUDIO LINK		    = */
		/* ============================================== */
		public function navigateToAudio(event:MouseEvent):void
		{
			var audioURL:String = "http://www.usana.com/Main/myUsana/page/MediaCenterAudio";
			var audioURLRequest:URLRequest = new URLRequest(audioURL);
			navigateToURL(audioURLRequest, "_self");
		}
		
          
      	/* ============================================== */
		/* = FUNCTION TO DO BASIC SEARCH FOR VIDEOS = */
		/* ============================================== */
		public function search(event:MouseEvent):void
		{	
			
			/*SET CURRENT SEARCH TERM (FOR DISPLAY ON VIDEO PLAYER PAGE)*/
			current_search_term = search_txt.text;

			/*SEARCHING MESSAGE*/
			current_search_message = 'Searching videos for "' +search_txt.text+ '"';
			
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
				
				//REMOVE 3DWALL DUE TO BUG
				landing_page_view.wall.unloadAndStop();
				
				search_type = null;
				current_search_term = 'Results for "'+search_txt.text+'"';
				//current_search_term = 'Search Results';
		 		
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
		public function recommendedSearch(event:MouseEvent,mode:String):void
		{	
            
			/*SEARCHING MESSAGE*/
			if (mode == "playVideo")
			{
				current_search_message = "Getting Selected Video"
				current_video = event.currentTarget as XML;
				playNow = true;
			}
			else
			{
				current_search_message = 'Getting videos for "' +recommended_searchTitle+ '"';
				playNow = false;
			}
			
			
			search_type="rec_video"
			
				/*SET CURRENT SEARCH TERM (FOR DISPLAY ON VIDEO PLAYER PAGE)*/
				current_search_term = recommended_searchTitle + " videos";
				
		
				/*POP UP SEARCHING VIEW*/
				main_view_stack.selectedIndex = 2;
				
				var thumbNailIndex:int = event.currentTarget.automationName;
				
				current_video = recommended_videos[thumbNailIndex];
				
				
				
				/*CALL THE WEB SERVICE*/
				recommended_search_svc.send();
				
				
				
			} 
					
		
    	
		
		/* ============================================================== */
		/* = FUNCTION CALLED WHEN RECOMMENDED SEARCH RESULT IS RETURNED = */
		/* ============================================================== */
		public function recommendedSearchResultHandler():void
		{

			/*SET THE VIDEO_LIST RESULTS SORTED BY MOST VIEWED*/
			video_list = sort_by_most_recent(recommended_search_svc.lastResult.video);
			
			

			if ((video_list) && (video_list.video.length() > 0))
			{			
				
				//REMOVE 3DWALL DUE TO BUG
				landing_page_view.wall.unloadAndStop();
							
				//current_video = video_list.video[0];
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
	public function get_most_recent(event:MouseEvent):void
	{
		
		/*POP UP SEARCHING VIEW*/
		main_view_stack.selectedIndex = 2;

		/*SET CURRENT SEARCH TERM (FOR DISPLAY ON VIDEO PLAYER PAGE)*/
		current_search_term = "Most Recent";

		/*SEARCHING MESSAGE*/
		current_search_message = "Getting The Most Recent Videos";
		
		/*CALL THE SERVICES TO GET ALL VIDEOS SO WE CAN SORT THEM*/
		recent_videos_svc.send();
		
	}
	
	
	
	/* =============================================== */
	/* = FUNCTION CALLED WHEN RECENT VIDEOS RETURNED = */
	/* =============================================== */
	public function recentVideosResultHandler():void
	{
		
		video_list = sort_by_most_recent(recent_videos_svc.lastResult.video);
		
		current_video = video_list.children()[0];
			
		//REMOVE 3DWALL DUE TO BUG
		landing_page_view.wall.unloadAndStop();
		
		search_type = "most_recent";
 		current_search_term = "Showing Most Recent";
		
	    main_view_stack.selectedIndex = 1;
	}
        
	/* =============================== */
	/* = FUNCTION TO GET MOST VIEWED = */
	/* =============================== */
	private function get_most_viewed(event:MouseEvent=null):void
	{
		/*POP UP SEARCHING VIEW*/
		main_view_stack.selectedIndex = 2;
		
		//most_viewed_videos_svc.send();
		
		/*SET CURRENT SEARCH TERM (FOR DISPLAY ON VIDEO PLAYER PAGE)*/
		current_search_term = "Most Viewed";
		
		/*SEARCHING MESSAGE*/
		current_search_message = "Getting The Most Viewed Videos";
		
		
		//REMOVE 3DWALL DUE TO BUG
		landing_page_view.wall.unloadAndStop();

		search_type = "most_viewed";
		current_search_term = "Showing Most Viewed";
		
	}
	
	
	/* =============================================== */
	/* = FUNCTION CALLED WHEN FIRST MOST VIEWED VIDEOS RETURNED = */
	/* =============================================== */
	public function mostViewedVideosResultHandler():void
	{
		
		//SET VIDEO LIST TO MOST_VIEWED_VIDEOS
		//video_list = sort_by_most_viewed(most_viewed_videos_svc.lastResult.video)
		
		current_video = video_list.children()[0];
			
		//REMOVE 3DWALL DUE TO BUG
		landing_page_view.wall.unloadAndStop();
		
		//search_type = "most_recent";
 		current_search_term = "Showing Most Viewed";
		
	    main_view_stack.selectedIndex = 1;
	}
	
	
	

	
	/* ==================================================== */
	/* = FUNCTION TO GET THE VIDEO SELECTED ON THE 3DWALL = */
	/* ==================================================== */
	public function getWallVideo():void
	{

		/*SEARCHING MESSAGE*/
		current_search_message = "Retrieving Selected Video";
		
		main_view_stack.selectedIndex = 2;
		wall_video_svc.send();
	}
	
	/* ================================================= */
	/* = FUNCTION CALLED WHEN WALL VIDEO CALL RETURNED = */
	/* ================================================= */
	public function wallVideoResultHandler():void
	{
		
		var all_videos:XMLList = wall_video_svc.lastResult.video;
		var wall_video:XMLList =  all_videos.(@id==selectedWallVideoID);
		
		//RETURN VIDEO LIST SORTED BY MOST RECENT
		video_list = sort_by_most_recent(all_videos);

		//SET CURRENT VIDEO
		current_video = wall_video[0];
		
		/*SET CURRENT SEARCH TERM (FOR DISPLAY ON VIDEO PLAYER PAGE)*/
		current_search_term = "All Videos";
		
		//REMOVE 3DWALL DUE TO BUG
		landing_page_view.wall.unloadAndStop();
		
		search_type = "wall_video";
		
		main_view_stack.selectedIndex = 1;
	}
	
		/* ======================================== */
		/* = FUNCTION TO POP UP SEND EMAIL WINDOW = */
		/* ======================================== */
		public function sendEmail(title:String):void
		{
			var emailWindow:SendEmailPage = new components.views.SendEmailPage();
	        PopUpManager.addPopUp(emailWindow, this, true);
			//emailWindow.title = "Send \""+title+"\" to a Friend";
			emailWindow.y = 100;
			emailWindow.x = 100;
		}
		
		/* ======================================== */
		/* = FUNCTION TO POP UP EMBED WINDOW = */
		/* ======================================== */
		public function embedVideo(title:String):void
		{
			var embedWindow:EmbedVideoPage = new components.views.EmbedVideoPage();
	        PopUpManager.addPopUp(embedWindow, this, true);
			embedWindow.title = "Embed \""+title+"\"";
			embedWindow.y = 100;
			embedWindow.x = 228;
		}
		
		/* ======================================== */
		/* = FUNCTION TO DOWNLOAD VIDEO = */
		/* ======================================== */
		public function downloadVideo(id:String):void
		{
			var urlRequest:URLRequest = new URLRequest("http://www.usanamedia.com/downloads/?id=" + id +"&lan="+ LANGUAGE);
                navigateToURL(urlRequest, "_blank");

		}
		
		
 

		/* ==================================================================== */
		/* = SEARCH AN ARRAY COLLECTION FOR A PROPERTY ON AN OBJECT = */
		/* ==================================================================== */
	 public function getItemIndexByProperty(array:ArrayCollection, property:String, value:String):Number
		{
		   for (var i:Number = 0; i < array.length; i++)
		   {
		      var obj:Object = Object(array[i])
		      if (obj[property].search(value) > -1)
		      return i;
		   }
		   return -1;
		}
		



		/* ===================== */
		/* = SET UP PAGINATION = */
		/* ===================== */ 
		public function pagination_setup(videoPage:Object):void
		{
			
			videoPage.rp.startingIndex = 0;
			//SET UP FIRST VIDEO THAT WILL PLAY
			video_title = current_video.title;
			video_short_description = current_video.shortdescription;
			video_long_description = current_video.longdescription;
			results_for = "Results For \"" + search_txt.text +"\"";
			videoPage.previous_btn.enabled=false;
		 	
			 
			//CLEAR EXISTING DP
			search_results_dp.removeAll();
			// Convert XML to ArrayCollection
              for each(var s:XML in parentDocument.video_list.video){
                  search_results_dp.addItem(s);
              }
			
			pagedDataProvider=new ArrayCollection();
			  	pageCount=(search_results_dp.length/PERPAGE)+1;
			    currentPage=1;
			    if(pageCount > 1){
   			     videoPage.next_btn.enabled=true;
					pageCountDummyArray = new Array(pageCount);
   			    }
				else
				{			   
				 	videoPage.next_btn.enabled=false;
					pageCountDummyArray = new Array(pageCount);
				}
			    if(search_results_dp.length >= PERPAGE){
			        for(var i:int=0;i<PERPAGE;i++){
			            pagedDataProvider.addItem(search_results_dp.getItemAt(i));
			        }
			    }else{
			        pagedDataProvider=search_results_dp;
			    }
			
			
				//IF MORE THAN 6 PAGES, SHOW THE CONTINUATION DOTS :) 
				if(pageCount > 6)
				{
						videoPage.lastTen_btn.visible=true;
				}
				else
				{
					videoPage.lastTen_btn.visible=false;
				}
				
				underlineFirstRecord(videoPage);
			
			
				
			
		}
		
	     
		/* ======================================= */
		/* = FUNCTION TO GET NEXT PAGE OF VIDEOS = */
		/* ======================================= */
		public function getNextPage(videoPage:Object):void{
		    var start:int=PERPAGE*currentPage;
		    var end:int=0;
		
			
			var lastPageNum:int = ((currentPage - videoPage.rp.startingIndex)-1);
			var selectedPageNum:int = currentPage - videoPage.rp.startingIndex;
			
			if(lastPageNum > -1)
			{
				
				videoPage.pageNumber_lbl[lastPageNum].setStyle('textDecoration','none');
			}
		
			if(videoPage.pageNumber_lbl[selectedPageNum])
			{
				videoPage.pageNumber_lbl[selectedPageNum].setStyle('textDecoration','underline');
			}
		
			
			//SET LAST PAGE BUTTON
			lastPageSelectedButton = videoPage.pageNumber_lbl[lastPageNum + 1];
			
			
		    //BE SURE WE HAVE ENOUGH VIDEOS IN DP
		    if((search_results_dp.length-start)>PERPAGE)
			{
		        end=start+PERPAGE;
		    }
			else
			{
		        end=search_results_dp.length;
		    }
		    pagedDataProvider=new ArrayCollection();
		    for(var i:int=start;i<end;i++)
			{
		        pagedDataProvider.addItem(search_results_dp.getItemAt(i));
		    }
			
			if(currentPage == pageCount -1)
			{
				videoPage.next_btn.enabled = false;
				videoPage.lastTen_btn.enabled = false;
			}
			
		    if(currentPage == 6 ||currentPage == 12 ||currentPage == 18 ||currentPage == 24 ||currentPage == 30 ||currentPage == 36 ||currentPage == 42 ||currentPage == 48 ||currentPage == 54 ||currentPage == 60) {
				//GET NEXT TEN PAGES
				getNextTen(videoPage);
		    }
			else
			{
				currentPage++; //INCREMENT PAGE
			    
			}
			videoPage.previous_btn.enabled=true;
		    videoPage.firstTen_btn.enabled = true;
		
				
			
	
		}
	
	
	
	
		/* =============================================== */
		/* = FUNCTION TO GET THE PREVIOUS PAGE OF VIDEOS = */
		/* =============================================== */
		public function getPreviousPage(videoPage:Object):void{
		
		    	videoPage.next_btn.enabled=true;
		
				//NEED TO FIND BETTER WAY TO DO THIS - 
			    if(currentPage == 7 ||currentPage == 13 ||currentPage == 19 ||currentPage == 25 ||currentPage == 31 ||currentPage == 37 ||currentPage == 43 ||currentPage == 49 ||currentPage == 55 ||currentPage == 61){
					//GET PREVIOUS TEN PAGES
					getPreviousTen(videoPage);
				}
				else  
				{
		
				var lastPageNum:int = (currentPage - videoPage.rp.startingIndex);
				var selectedPageNum:int = ((currentPage - videoPage.rp.startingIndex) -2);
				
				if(lastPageNum > -1 && videoPage.pageNumber_lbl[lastPageNum -1])
				{
					videoPage.pageNumber_lbl[lastPageNum - 1].setStyle('textDecoration','none');
				}
				if(videoPage.pageNumber_lbl[selectedPageNum])
				{
					videoPage.pageNumber_lbl[selectedPageNum].setStyle('textDecoration','underline');
				}

		
		
			
			//SET LAST PAGE BUTTON
			lastPageSelectedButton = videoPage.pageNumber_lbl[lastPageNum -1];
			
		
				currentPage --; //DECREMENT PAGE
			    
			}
			if(currentPage == 1)
			{
			 	videoPage.previous_btn.enabled=false;
			 	videoPage.firstTen_btn.enabled=false;
				videoPage.lastTen_btn.enabled = true;
				videoPage.next_btn.enabled = true;
	    	}
		    var start:int=PERPAGE*(currentPage -1);
		    var end:int=start+PERPAGE;
		    pagedDataProvider=new ArrayCollection();
		    for(var i:int=start;i<end;i++){
			
					pagedDataProvider.addItem(search_results_dp.getItemAt(i));
	    	}
	
		
		
		}
	
	
	
			/* ======================================= */
			/* = FUNCTION TO GET SELECTED PAGE OF VIDEOS = */
			/* ======================================= */
				public function getSelectedPage(pageNum:String,videoPage:Object,event_target:LinkButton = null):void{
				var pageNumber:int = parseInt(pageNum);
			    var start:int=PERPAGE*pageNumber;
			    var end:int=0;
			
				
				
				//REMOVE UNDERLINE FROM ALL PAGE NUMBERS
				if(videoPage.pageNumber_lbl[0]) { videoPage.pageNumber_lbl[0].setStyle('textDecoration','none'); }
				if(videoPage.pageNumber_lbl[1]) { videoPage.pageNumber_lbl[1].setStyle('textDecoration','none'); }
				if(videoPage.pageNumber_lbl[2]) { videoPage.pageNumber_lbl[2].setStyle('textDecoration','none'); }
				if(videoPage.pageNumber_lbl[3]) { videoPage.pageNumber_lbl[3].setStyle('textDecoration','none'); }
				if(videoPage.pageNumber_lbl[4]) { videoPage.pageNumber_lbl[4].setStyle('textDecoration','none'); }
				if(videoPage.pageNumber_lbl[5]) { videoPage.pageNumber_lbl[5].setStyle('textDecoration','none'); }
			
		
				
			    //BE SURE WE HAVE ENOUGH VIDEOS IN DP
			   if((search_results_dp.length-start)>PERPAGE)
 				{
 			        end=start+PERPAGE;
 			    }
 				else
 				{
 			        end=search_results_dp.length;
 			    }
 			    pagedDataProvider=new ArrayCollection();
 			    for(var i:int=start;i<end;i++)
 				{
					try
					{
						pagedDataProvider.addItem(search_results_dp.getItemAt(i));
					} 
					catch (e:Error)
					{
						
					}
 			    }
				currentPage = pageNumber;
				
				
				//DISABLE NEXT AND PREV BUTTONS DEPENDING ON CURRENT PAGE
 		   		if(currentPage <= 1)
				{
				 	videoPage.previous_btn.enabled=false;
					videoPage.firstTen_btn.enabled=false;
		    	}
				else
				{
					videoPage.previous_btn.enabled=true;
					videoPage.firstTen_btn.enabled=true;
				}
				
 			    if(currentPage==pageCount){
 			     videoPage.next_btn.enabled=false;
				 videoPage.lastTen_btn.enabled=false;
 			    }

				//UNDERLINE CURRENT PAGE 
				if(event_target)
 			    {
					event_target.setStyle('textDecoration','underline');
				}


				/*if(currentPage == 6 ||currentPage == 12 ||currentPage == 18 ||currentPage == 24 ||currentPage == 30 ||currentPage == 36 ||currentPage == 42 ||currentPage == 48 ||currentPage == 54 ||currentPage == 60)
							{
								videoPage.pageNumber_lbl[0].setStyle('textDecoration','underline');
							}
							if(currentPage == 13 ||currentPage == 19 ||currentPage == 25 ||currentPage == 31 ||currentPage == 37 ||currentPage == 43 ||currentPage == 49 ||currentPage == 55 ||currentPage == 61)
							{
								
								videoPage.pageNumber_lbl[5].setStyle('textDecoration','underline');
							}
				*/		
				
				//SET LAST PAGE BUTTON
				lastPageSelectedButton = event_target;
			}


	/* =================================================== */
	/* = FUNCTION TO GET THE NEXT 10 PAGES OF THUMBNAILS = */
	/* =================================================== */
	public function getNextTen(videoPage:Object):void
	{
		videoPage.rp.startingIndex = currentPage;
		getSelectedPage((currentPage).toString(),videoPage);
		currentPage++; //INCREMENT PAGE
		//UNDERLINE FIRST PAGE NUMBER 
		videoPage.pageNumber_lbl[0].setStyle('textDecoration','underline');
	}
	
			
	/* ======================================================= */
	/* = FUNCTION TO GET THE PREVIOUS 10 PAGES OF THUMBNAILS = */
	/* ======================================================= */
	public function getPreviousTen(videoPage:Object):void
	{
		videoPage.rp.startingIndex = currentPage - 7;
		getSelectedPage((currentPage).toString(),videoPage);
		currentPage--; //DECREMENT PAGE
		videoPage.next_btn.enabled=true;
		//UNDERLINE LAST PAGE NUMBER
		videoPage.pageNumber_lbl[5].setStyle('textDecoration','underline');
	}
	
	/* =================================================== */
	/* = FUNCTION TO GET THE LAST 10 PAGES OF THUMBNAILS = */
	/* =================================================== */
	public function getFirstTen(videoPage:Object):void
	{
		videoPage.rp.startingIndex = 0;
		currentPage = videoPage.rp.startingIndex;
		getSelectedPage(videoPage.rp.startingIndex,videoPage);
		underlineFirstRecord(videoPage);
		videoPage.next_btn.enabled=true;
		videoPage.lastTen_btn.enabled = true;
	}	
	
	/* =================================================== */
	/* = FUNCTION TO GET THE LAST 10 PAGES OF THUMBNAILS = */
	/* =================================================== */
	public function getLastTen(videoPage:Object):void
	{
		videoPage.rp.startingIndex = pageCount - 6;
		currentPage = videoPage.rp.startingIndex;
		getSelectedPage(videoPage.rp.startingIndex,videoPage);
		underlineFirstRecord(videoPage);
		videoPage.lastTen_btn.enabled = false;
		videoPage.previous_btn.enabled=true;
	    videoPage.firstTen_btn.enabled = true;
	}
	
	/* =============================================================== */
	/* = FUNCTIONC CALLED WHEN VIDEOS FOR AUTO COMPLETE ARE RETURNED = */
	/* =============================================================== */
	public function setUpAutoComplete():void
	{
		var myXMLList:XMLListCollection = new XMLListCollection();
		myXMLList.source = auto_complete_svc.lastResult.video;
		myDP = myXMLList;
	//	search_txt.enabled = true;
	}
	
	<!-- ================================================= -->
	<!-- = FUNCTION TO UNDERLINE FIRST RECORD            = -->
	<!-- ================================================= -->		
	public function underlineFirstRecord(videoPage:Object):void
	{
		if(videoPage.pageNumber_lbl)
		{
		 if (videoPage.pageNumber_lbl[0])
 		   {
 			   //UNDERLINE FIRST PAGE NUMBER
 		   		if(videoPage.pageNumber_lbl[0])
 				{
 					videoPage.pageNumber_lbl[0].setStyle('textDecoration','underline');
 				}
 		   }
		}
		   
		
	}
	
    
/* =================================== */
/* = FUNCTION TO SHOW SELECTED VIDEO = */
/* =================================== */
public function showVideo(video:XML,videoPage:Object):void {
	
	    //CLEAR VIDEO THUMBNAIL OVERLAY (VIDEO PLAYS INSTANTLY)
		videoPage.large_thumbnail_overlay.source = "";
		
		//CLEAR PLAY BUTTON OVERLAY
		videoPage.play_overlay_btn.visible = false;
		
		// PLACE THE LOADING IMAGE OVER THE TOP WHILE VIDEO LOADS
		videoPage.loading_overlay.visible = true;
		
	//SET CURRENT VIDEO BASED ON CLICKED THUMBNAIL
	current_video = video;
	// Cast the ModuleLoader's child to the interface.
	// This child is an instance of the module.
	// We can now call methods on that instance.
	var vpchild:* = videoPage.video_player.child as VideoPlayerInterface;                
		if (videoPage.video_player.child != null) {                    
		     // Call setters in the module to adjust its
		     // appearance when it loads.
		vpchild.setVideo(video.@id,true);
		videoPage.video_title_txt.text = video.title;
		videoPage.video_short_description_txt.text = video.shortdescription;
		videoPage.video_long_description_txt.htmlText = video.longdescription;
		      } else {                
		          trace("Uh oh. The video_player.child property is null");                 
		      }
		
		//PREVENT VOLUME FROM RESETTING
		vpchild.changeVolume();
		
		
}



	
/* =================================== */
/* = 2ND FUNCTION TO SHOW SELECTED VIDEO = */
/* =================================== */
public function showVideo2(video_id:String,videoPage:Object):void {
	
	//SET CURRENT VIDEO BASED ON CLICKED THUMBNAIL
	//current_video = evt.currentTarget.selectedItem;
		// Cast the ModuleLoader's child to the interface.
       // This child is an instance of the module.
       // We can now call methods on that instance.
       var vpchild:* = videoPage.video_player.child as VideoPlayerInterface;                
         if (videoPage.video_player.child != null) {                    
             // Call setters in the module to adjust its
             // appearance when it loads.
           vpchild.setVideo(video_id,false);
	  videoPage.video_title_txt.text = parentDocument.current_video.title;
	  videoPage.video_short_description_txt.text = parentDocument.current_video.shortdescription;
	  videoPage.video_long_description_txt.htmlText = parentDocument.current_video.longdescription;
         } else {                
             trace("Uh oh. The video_player.child property is null");                 
         }
                                                   

}




/* =============================== */
/* = SORT RESULTS BY MOST RECENT = */
/* =============================== */
public function sort_by_most_recent(serviceResult:XMLList):XML
{
	
	
	var videoArray:ArrayCollection = new ArrayCollection();
	
	for each (var video:XML in serviceResult)
	{
		
		videoArray.addItem({"id":video.@id.substring(3),"title":video.title,"shortdescription":video.shortdescription,"longdescription":video.longdescription});
	}
	
	/*BELOW WE SORT THE RESULTS DESCENDING BASED ON STREAMHITS*/
	var dataSortField:SortField = new SortField();
	dataSortField.name = "id";
	dataSortField.numeric = true;
	dataSortField.descending = true;
	var numericDataSort:Sort = new Sort();
	numericDataSort.fields = [dataSortField];
	videoArray.sort = numericDataSort;
	videoArray.refresh();
	
	
	
	/*REBUILD THE XML*/
	var xmlstr:String = "<mediacenter>"; 
		for each (var finalVideo:Object in videoArray)
		{
			
			xmlstr += "<video id=\"ven"+finalVideo.id+"\">\n";
			xmlstr += "<title>"+finalVideo.title+"</title>\n"; 
			xmlstr += "<shortdescription>"+finalVideo.shortdescription+"</shortdescription>\n"; 
			xmlstr += "<longdescription>"+finalVideo.longdescription+"</longdescription>\n"; 
			xmlstr += "</video>";
		
			}
			
		
			xmlstr += "</mediacenter>";
			 
		
			/*SET THE VIDEO_LIST RESULTS*/
			video_list = new XML(xmlstr);
			
			
			return video_list
		
}



public function sort_by_most_viewed(serviceResult:XMLList):XML
{
	
	
	
	// Convert XML to ArrayCollection
	  var videoArray:ArrayCollection = new ArrayCollection();
	  var finalArray:ArrayCollection = new ArrayCollection();
      for each(var video:XML in serviceResult)
	  {
          videoArray.addItem(video);
      }
	
	
	/*LOOP OVER THE AKAMAI DATA AND GET THE VIDEO INFO FOR EACH*/
	for each (var newVideo:Object in videoArray)
	{
		var indexOfVideo:int  = parentDocument.getItemIndexByProperty(akamaiArray,"url",newVideo.@id);
		if(indexOfVideo >= 0)
		{
		finalArray.addItem({"streamhits":akamaiArray[indexOfVideo].streamhits,"id":newVideo.@id,"title":newVideo.title,"shortdescription":newVideo.shortdescription,"longdescription":newVideo.longdescription});
		}

	/*BELOW WE SORT THE RESULTS DESCENDING BASED ON STREAMHITS*/
	var dataSortField:SortField = new SortField();
	dataSortField.name = "streamhits";
	dataSortField.numeric = true;
	dataSortField.descending = true;
	var numericDataSort:Sort = new Sort();
	numericDataSort.fields = [dataSortField];
	finalArray.sort = numericDataSort;
	finalArray.refresh();
		
	}
	
    
	/*REBUILD THE XML*/
	var xmlstr:String = "<mediacenter>";
	for each (var finalVideo:Object in finalArray)
	{
		trace('test');
		xmlstr += "<video id=\""+finalVideo.id+"\">\n";
		xmlstr += "<title>"+finalVideo.title+"</title>\n"; 
		xmlstr += "<shortdescription>"+finalVideo.shortdescription+"</shortdescription>\n"; 
		xmlstr += "<longdescription>"+finalVideo.longdescription+"</longdescription>\n"; 
		xmlstr += "<streamhits>"+finalVideo.streamhits+"</streamhits>\n"; 
		xmlstr += "</video>";
		
	}
	xmlstr += "</mediacenter>";
	video_list = new XML(xmlstr);
	
	return video_list;
}




/* ====================================== */
/* = AKAMAI (MOST RECENT)RESULT HANDLER = */
/* ====================================== */
/*public function akamaiResultHandler():void
{
	
	  // Convert XML to ArrayCollection
      for each(var clip:XML in akamai_svc.lastResult.clips.clipent)
	  {
          akamaiArray.addItem(clip);
      }
      
	
	//RE-ENABLE MOST VIEWED BUTTON
	//mostViewed_btn.enabled = true;
	
		//IF VIDEO_ID PASSED IN URL, GO DIRECTLY TO VIDEO PLAYER PAGE
		//WE RE-USE THE WALL VIDEO CLICK FUNCTIONS FOR THIS 
		if (FlexGlobals.topLevelApplication.parameters.video_id != "null")
		{
			selectedWallVideoID = FlexGlobals.topLevelApplication.parameters.video_id;
		    getWallVideo();
		}

	
}	*/







      
	}
	
}