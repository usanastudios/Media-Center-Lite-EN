//AS3///////////////////////////////////////////////////////////////////////////
// 
// Copyright 2009 USANA Health Sciences, Inc.
// 
////////////////////////////////////////////////////////////////////////////////

package components.views
{
	
	import com.adobe.flex.extras.controls.AutoComplete;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import modules.video_player.VideoPlayerInterface;
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.collections.XMLListCollection;
	import mx.containers.ViewStack;
	import mx.controls.Alert;
	import mx.controls.Menu;
	import mx.events.MenuEvent;
	import mx.formatters.DateFormatter;
	import mx.managers.PopUpManager;
	import mx.rpc.http.mxml.HTTPService;
	import mx.validators.Validator;
	import spark.components.Application;
	import spark.components.Button;
	import mx.controls.LinkButton;


	public class MainBaseClass extends Application
	{

		/* ==================== */
		/* = PUBLIC VARIABLES = */
		/* ==================== */
		public var akamai_svc:HTTPService;
		public var all_videos_svc:HTTPService;
		public var wall_video_svc:HTTPService;
		public var clipentArray:ArrayCollection = new ArrayCollection();
		public var current_search_message:String
		public var current_search_term:String;
		public var current_video:XML;
		public var main_view_stack:ViewStack;
		public var mostRecent_btn:Button;
		public var mostViewed_btn:Button;
		public var prospectMenu1_btn:Button;
		public var prospectMenuData:XML;
		public var recent_videos_svc:HTTPService;
		public var recommended_search_svc:HTTPService;
		public var search_svc:HTTPService;
		public var auto_complete_svc:HTTPService;
		public var search_text_validator:Validator;
		public var video_list:XML = new XML;
		public var video_player_basic_view:VideoPlayerBasic;
		public var video_player_recommended_view:VideoPlayerRecommended;
		public var selectedWallVideoID:String;
		public var last_selected_page:Number;
		public var lastPageSelectedButton:LinkButton;
		public var landing_page_view:components.views.LandingPage;
		
		public static const LANGUAGE:String = "en";
		
		/* ====================== */
		/* = BINDABLE VARIABLES = */
		/* ====================== */
		[Bindable] public var dateFormatter:DateFormatter;
		[Bindable] public var akamai_start_date:String;
		[Bindable] public var akamai_stop_date:String;
		[Bindable] public var video_title:String;
		[Bindable] public var video_short_description:String;
		[Bindable] public var video_long_description:String;
		[Bindable] public var results_for:String;
		[Bindable]public var search_txt:AutoComplete;
		[Bindable] public var search_btn:Button;
		[Bindable] public var audio_btn:Button;
		[Bindable] public var search_results_dp:ArrayCollection = new ArrayCollection();
		[Bindable] public var myDP:XMLListCollection;

		
		
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
			auto_complete_svc.send();
			
			/*EVENT LISTENERS*/
			prospectMenu1_btn.addEventListener(MouseEvent.CLICK,createAndShowProspectMenu1);
			search_btn.addEventListener(MouseEvent.CLICK,search);
			mostViewed_btn.addEventListener(MouseEvent.CLICK,get_most_viewed);
			mostRecent_btn.addEventListener(MouseEvent.CLICK,get_most_recent);
			audio_btn.addEventListener(MouseEvent.CLICK, navigateToAudio);
			
			
			/*DEFINE AKAMAI START AND STOP DATES*/
			akamai_start_date = "2009-01-01";
			akamai_stop_date = dateFormatter.format(new Date());
			
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
            prospectMenu1.width = 226;
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
			current_search_term = search_txt.selectedLabel;

			/*SEARCHING MESSAGE*/
			current_search_message = "Searching videos for '" +search_txt.text+ "'";
			
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
				
				/*SET NEW VIDEO */
				if(video_player_basic_view.video_player){
					var vpchild:* = video_player_basic_view.video_player.child as VideoPlayerInterface;                
		            if (video_player_basic_view.video_player.child != null) {                    
		                // Call setters in the module to adjust its
		                // appearance when it loads.
		              vpchild.setVideo(current_video.@id);
		            } else {                
		                trace("Uh oh. The video_player.child property is null");                 
		            }
				}   
			
				
				/*CALL THE WEB SERVICE*/
				var params:Object = new Object;
	 			params['q'] = search_term;
				params['l'] = LANGUAGE;
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
				
				//REMOVE 3DWALL DUE TO BUG
				landing_page_view.wall.unloadAndStop();
							
				current_video = video_list.video[0];
				main_view_stack.selectedIndex = 3;
			
				/*SET NEW VIDEO */
				if(video_player_recommended_view.video_player){
					var vpchild:* = video_player_recommended_view.video_player.child as VideoPlayerInterface;                
		            if (video_player_recommended_view.video_player.child != null) {                    
		                // Call setters in the module to adjust its
		                // appearance when it loads.
		              vpchild.setVideo(current_video.@id);
		            } else {                
		                trace("Uh oh. The video_player.child property is null");                 
		            }
				} 
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
		var videoArray:ArrayCollection = new ArrayCollection();
		for each (var video:XML in recent_videos_svc.lastResult.video)
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
				//xmlstr += "<longdescription>"+finalVideo.longdescription+"</longdescription>\n"; 
				xmlstr += "</video>";
			}
			xmlstr += "</mediacenter>";
			video_list = new XML(xmlstr);
			current_video = video_list.children()[0];
		
		//REMOVE 3DWALL DUE TO BUG
		landing_page_view.wall.unloadAndStop();
		
	    main_view_stack.selectedIndex = 1;
	
	
	}
        
	/* =============================== */
	/* = FUNCTION TO GET MOST VIEWED = */
	/* =============================== */
	private function get_most_viewed(event:MouseEvent):void
	{
		/*POP UP SEARCHING VIEW*/
		main_view_stack.selectedIndex = 2;
		
		/*SET CURRENT SEARCH TERM (FOR DISPLAY ON VIDEO PLAYER PAGE)*/
		current_search_term = "Most Viewed";
		
		/*SEARCHING MESSAGE*/
		current_search_message = "Getting The Most Viewed Videos";
		
		/*CALL SERVICE TO GET AKAMAI RESULTS*/
		akamai_svc.send()
	}
	
	
	
	/* ====================================== */
	/* = AKAMAI (MOST RECENT)RESULT HANDLER = */
	/* ====================================== */
	public function akamaiResultHandler():void
	{
		
		  // Convert XML to ArrayCollection
          for each(var clip:XML in akamai_svc.lastResult.clips.clipent)
		  {
              clipentArray.addItem(clip);
          }
		
		/*CALL TO GET ALL VIDEOS FROM USANA - WE COMPARE THEM IN THE RESULT HANDLER*/
		all_videos_svc.send();
		
	}	
	
	
	/* ================================= */
	/* = ALL_VIDEOS_SVC RESULT HANDLER = */
	/* ================================= */
	public function allVideosResultHandler():void
	{
		// Convert XML to ArrayCollection
		  var videoArray:ArrayCollection = new ArrayCollection();
		  var finalArray:ArrayCollection = new ArrayCollection();
          for each(var video:XML in all_videos_svc.lastResult.video)
		  {
              videoArray.addItem(video);
          }
		
		
		/*LOOP OVER THE AKAMAI DATA AND GET THE VIDEO INFO FOR EACH*/
		for each (var newVideo:Object in videoArray)
		{
			var indexOfVideo:int  = parentDocument.getItemIndexByProperty(clipentArray,"url",newVideo.@id);
			finalArray.addItem({"streamhits":clipentArray[indexOfVideo].streamhits,"id":newVideo.@id,"title":newVideo.title,"shortdescription":newVideo.shortdescription,"longdescription":newVideo.longdescription});
			
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
			//xmlstr += "<longdescription>"+finalVideo.longdescription+"</longdescription>\n"; 
			xmlstr += "<streamhits>"+finalVideo.streamhits+"</streamhits>\n"; 
			xmlstr += "</video>";
			
		}
		xmlstr += "</mediacenter>";
		video_list = new XML(xmlstr);
		current_video = video_list.children()[0];
		
		//REMOVE 3DWALL DUE TO BUG
		landing_page_view.wall.unloadAndStop();
		
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
		current_video = wall_video[0];
		
		/*SET CURRENT SEARCH TERM (FOR DISPLAY ON VIDEO PLAYER PAGE)*/
		current_search_term = current_video.title;
		
		
		/*SET THE VIDEO_LIST RESULTS*/
		video_list = wall_video_svc.lastResult as XML;
	
		//REMOVE 3DWALL DUE TO BUG
		landing_page_view.wall.unloadAndStop();
		
		main_view_stack.selectedIndex = 1;
	}
	
		/* ======================================== */
		/* = FUNCTION TO POP UP SEND EMAIL WINDOW = */
		/* ======================================== */
		public function sendEmail(title:String):void
		{
			var emailWindow:SendEmailPage = new components.views.SendEmailPage();
	        PopUpManager.addPopUp(emailWindow, this, false);
			emailWindow.title = "Send \""+title+"\" to a Friend";
			emailWindow.y = 100;
			emailWindow.x = 100;
		}
		
		/* ======================================== */
		/* = FUNCTION TO POP UP EMBED WINDOW = */
		/* ======================================== */
		public function embedVideo(title:String):void
		{
			var embedWindow:EmbedVideoPage = new components.views.EmbedVideoPage();
	        PopUpManager.addPopUp(embedWindow, this, false);
			embedWindow.title = "Embed \""+title+"\"";
			embedWindow.y = 100;
			embedWindow.x = 100;
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
			
			//SET UP FIRST VIDEO THAT WILL PLAY
			video_title = current_video.title;
			video_short_description = current_video.shortdescription;
			video_long_description = current_video.longdescription;
			results_for = "Results For \"" + current_search_term +"\"";
			
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
			    if(search_results_dp.length >= PERPAGE){
			        for(var i:int=0;i<PERPAGE;i++){
			            pagedDataProvider.addItem(search_results_dp.getItemAt(i));
			        }
			    }else{
			        pagedDataProvider=search_results_dp;
			    }
			
			
				//IF MORE THAN 10 PAGES, SHOW THE CONTINUATION DOTS :) 
				if(pageCount > 10)
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
		    videoPage.previous_btn.enabled=true;
			
		    if(currentPage == 10 ||currentPage == 20 ||currentPage == 30 ||currentPage == 40 ||currentPage == 50 ||currentPage == 60) {
				//GET NEXT TEN PAGES
				getNextTen(videoPage);
		    }
			else
			{
				currentPage++; //INCREMENT PAGE
			    
			}
			
				
			
	
		}
	
	
	
	
		/* =============================================== */
		/* = FUNCTION TO GET THE PREVIOUS PAGE OF VIDEOS = */
		/* =============================================== */
		public function getPreviousPage(videoPage:Object):void{
		
		    	videoPage.next_btn.enabled=true;
		
				//NEED TO FIND BETTER WAY TO DO THIS - 
			    if(currentPage == 11 || currentPage == 21 || currentPage == 31 || currentPage == 41|| currentPage == 51 || currentPage == 61){
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
			    var start:int=PERPAGE*(pageNumber -1);
			    var end:int=0;
			
				videoPage.previous_btn.enabled=true;
				
				//REMOVE UNDERLINE FROM SELECTED LAST PAGE
			 	if(lastPageSelectedButton)
				{
					lastPageSelectedButton.setStyle('textDecoration','none');
				}
				
				else
				{
					videoPage.pageNumber_lbl[0].setStyle('textDecoration','none');
				}
			
		
				
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
				

 		   		if(currentPage <= 1)
				{
				 	videoPage.previous_btn.enabled=false;
					videoPage.firstTen_btn.enabled=false;
		    	}
 			    if(currentPage==pageCount){
 			     videoPage.next_btn.enabled=false;
 			    }

				//UNDERLINE CURRENT PAGE 
				if(event_target)
 			    {
					event_target.setStyle('textDecoration','underline');
				}

				if(currentPage == 0 || currentPage == 10 || currentPage == 20 || currentPage == 30 || currentPage == 40 || currentPage == 50 || currentPage == 60 || currentPage == 70)
				{
					videoPage.pageNumber_lbl[0].setStyle('textDecoration','underline');
				}
				if(currentPage == 11 || currentPage == 21 || currentPage == 31 || currentPage == 41 || currentPage == 51 || currentPage == 61 || currentPage == 71)
				{
					videoPage.pageNumber_lbl[9].setStyle('textDecoration','underline');
				}
			
				
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
	}
	
			
	/* =================================================== */
	/* = FUNCTION TO GET THE NEXT 10 PAGES OF THUMBNAILS = */
	/* =================================================== */
	public function getPreviousTen(videoPage:Object):void
	{
		videoPage.rp.startingIndex = currentPage - 11;
		getSelectedPage((currentPage).toString(),videoPage);
		currentPage--; //DECREMENT PAGE
		
		
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
	}	
	
	/* =================================================== */
	/* = FUNCTION TO GET THE LAST 10 PAGES OF THUMBNAILS = */
	/* =================================================== */
	public function getLastTen(videoPage:Object):void
	{
		videoPage.rp.startingIndex = pageCount - 10;
		currentPage = videoPage.rp.startingIndex;
		getSelectedPage(videoPage.rp.startingIndex,videoPage);
		underlineFirstRecord(videoPage);
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
			   //UNDERLINE CURRENT PAGE NUMBER
			if(videoPage.pageNumber_lbl[0])
			{
				videoPage.pageNumber_lbl[0].setStyle('textDecoration','underline');
			}
	}
	
          
	}
}