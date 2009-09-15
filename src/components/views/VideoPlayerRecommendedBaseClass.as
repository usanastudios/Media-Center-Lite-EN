package components.views
{
	
	
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import modules.video_player.VideoPlayerInterface;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.containers.Canvas;
	import mx.containers.Tile;
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.controls.Image;
	import mx.controls.Menu;
	import mx.controls.Text;
	import mx.controls.Label;
	import mx.controls.TileList;
	import mx.core.Repeater;
	import mx.events.FlexEvent;
	import mx.events.MenuEvent;
	import mx.modules.ModuleLoader;
	import mx.rpc.http.mxml.HTTPService;
	
	import spark.components.Button;

	public class VideoPlayerRecommendedBaseClass extends Canvas
	{
		
		/* ===================== */
		/* = PRIVATE VARIABLES = */
		/* ===================== */
		[Bindable] private var selectedItems:ArrayCollection;
		
		/* ==================== */
		/* = PUBLIC VARIABLES = */
		/* ==================== */
		public var akamai_svc:HTTPService;
		public var next_btn:Button;
		public var previous_btn:Button;
		public var results_for_txt:Text;
		public var shareMenuData:XML;
		public var share_menu_btn:Button;
		public var sortMenuData:XML;
		public var sort_menu_btn:Button;
		public var video_long_description_txt:Text;
		public var video_player:ModuleLoader;
		public var video_short_description_txt:Text;
		public var video_tile_list:TileList;
		public var video_title_txt:Label;
		public var replay_btn:Button;
		public var play_overlay_btn:Button;
		public var rp_thumbnails:Repeater;
		public var recTile:Tile;
		public var recVBox:VBox;
		public var thumbOver:Image;
		public var large_thumbnail_overlay:Image;
		
		


		/* ====================== */
		/* = BINDABLE VARIABLES = */
		/* ====================== */
		[Bindable] public var currentModuleName:String;
		[Bindable] public var current_video:XML;

	

		
		
		/* ======================================== */
		/* = INITIALIZE BASIC VIDEO PLAYER SCREEN = */
		/* ======================================== */
		public function recommended_video_init():void
		{
			
			
			/*EVENT LISTENERS*/
			share_menu_btn.addEventListener(MouseEvent.CLICK,createAndShowShareMenu);
			sort_menu_btn.addEventListener(MouseEvent.CLICK,createAndShowSortMenu);
			replay_btn.addEventListener(MouseEvent.CLICK,replayVideo);
			play_overlay_btn.addEventListener(MouseEvent.CLICK,replayVideo);
		    
			
		
			/*SET UP PAGINATION*/
			parentDocument.pagination_setup(this);
			
			
			//SET UP VARS IF RELOADING VIDEO PAGE WITHOUT SEARCH
			if(parentDocument.current_video == null)
			{
				parentDocument.current_video = video_tile_list.dataProvider.getItemAt(0);
				parentDocument.current_search_term = "No Search Term";
				
			}
			
			
		}
		
	
		 
		
		/* ============================================= */
		/* = FUNCTION CALLED WHEN THIS SCREEN IS SHOWN = */
		/* ============================================= */
		public function onShow():void
		{
			parentDocument.pagination_setup(this);
				if(parentDocument.playNow == true)
				{
						var myTimer:Timer = new Timer(1000, 2);
				         myTimer.addEventListener("timer", 	showRecommendedVideo);
				         myTimer.start();
				
				}
				else
				{
					parentDocument.showVideo2(parentDocument.current_video.@id,this);
				}
				results_for_txt.text = parentDocument.current_search_term;
				// This forces the large thumbnail to change based on new searches etc...
			large_thumbnail_overlay.source = "http://www.usana.com/media/File/mediaCenter/display_frame/" + parentDocument.current_video.@id+ ".jpg";
		}
       
 	
		
		
		 /* =========================== */
		 /* = FUNCTION TO STOP VIDEO  = */
		 /* =========================== */
			public function pauseVideo():void
			{
				var vpchild:* = video_player.child as VideoPlayerInterface;                
	            if (video_player.child != null) {                    
	                // Call setters in the module to adjust its
	                // appearance when it loads.
	               vpchild.setIsPausedVar(false); //should be opposite of desired state
	            } else {                
	                trace("Uh oh. The video_player.child property is null");                 
	            }
			}
		
		
		
	
			
	 	/* ================================================================= */
		/* = FUNCTION TO SHOW SELECTED VIDEO FROM THE 5 RECOMMENDED ON PAGE = */
		/* ================================================================== */
		public function showRecommendedBoxVideo(event:MouseEvent):void {
			   
			 var vpchild:* = video_player.child as VideoPlayerInterface;    

			 if (video_player.child != null) {                    
			             
			  				// Call setters in the module to adjust its
			                // appearance when it loads.
			               
			               parentDocument.current_video = parentDocument.recommended_videos[event.currentTarget.automationName];
		
				  	   vpchild.setVideo(parentDocument.current_video.@id,true);
					   video_title_txt.text = parentDocument.current_video.title;
					   video_short_description_txt.text = parentDocument.current_video.shortdescription;
					   video_long_description_txt.htmlText = parentDocument.current_video.longdescription;
			

			 } else {                
                 mx.controls.Alert.show("Uh oh. The video_player.child property is null");                 
             }


						//PREVENT VOLUME FROM RESETTING
						if(vpchild)
						{
							vpchild.changeVolume();
						}    
	          

		}
		
		/* ================================================================== */
		/* = FUNCTION TO SHOW SELECTED VIDEO FROM THE 5 RECOMMENDED IN POPUP= */
		/* =================================================================== */
		public function showRecommendedVideo(event:TimerEvent = null):void {
			   
			 var vpchild:* = video_player.child as VideoPlayerInterface;    

			 if (video_player.child != null) {                    
			             
			  // Call setters in the module to adjust its
			               // appearance when it loads.
			               
			               
		
				  	   vpchild.setVideo(parentDocument.current_video.@id,true);
					   video_title_txt.text = parentDocument.current_video.title;
					   video_short_description_txt.text = parentDocument.current_video.shortdescription;
					   video_long_description_txt.htmlText = parentDocument.current_video.longdescription;
			

			 } else {                
                 mx.controls.Alert.show("Uh oh. The video_player.child property is null");                 
             }


						//PREVENT VOLUME FROM RESETTING
						if(vpchild)
						{
							vpchild.changeVolume();
						}    
	          

		}

public function test(event:FlexEvent):void
{		
        
}		
		
	
 
		
		
        /* ============================================== */
        /* = Create and display the Share Menu control. = */
        /* ============================================== */
        public function createAndShowShareMenu(event:MouseEvent):void {
	        var shareMenu:Menu = Menu.createMenu(null, shareMenuData, false);
	        shareMenu.labelField="@label";
	        shareMenu.styleName="prospectMenu1";
	        shareMenu.width = 180;
	        shareMenu.rowHeight = 27;
	        shareMenu.show(600, share_menu_btn.y + 165);
			shareMenu.addEventListener(MenuEvent.ITEM_CLICK,shareMenuHandler);
          }

		/* ============================================= */
        /* = Create and display the Sort Menu control. = */
        /* ============================================= */
        public function createAndShowSortMenu(event:MouseEvent):void {
	        var sortMenu:Menu = Menu.createMenu(null, sortMenuData, false);
	        sortMenu.labelField="@label";
	        sortMenu.styleName="prospectMenu1";
	        sortMenu.width = 160;
	        sortMenu.rowHeight = 27;
	        sortMenu.show(sort_menu_btn.x + 5, 500);  
			sortMenu.addEventListener(MenuEvent.ITEM_CLICK,sortSearchResults);
          }
       
 		/* =================================== */
		/* = FUNCTION TO SORT SEARCH RESULTS = */
		/* =================================== */
 		private function sortSearchResults(event:MenuEvent):void
 		{
		   /*SORT BY MOST RECENT*/
		   if(event.label == "Most Recent")
			{
				sortMostRecent();
			}
			/*SORT BY MOST RECENT*/
			else if (event.label == "Most Viewed")
			{
				sortMostViewed();
			}
 		}


		/* =================================== */
		/* = FUNCTION TO SORT BY MOST RECENT = */
		/* =================================== */
		public function sortMostRecent():void
		{

				/*CREATE TEMPORARY ARRAY COLLECTION WITH STRIPPED ID TO SORT*/
				var tempArrayColl:ArrayCollection = new ArrayCollection();
				for each (var video:XML in parentDocument.pagedDataProvider)
				{
					tempArrayColl.addItem({"id":video.@id.substring(3),"title":video.title,"shortdescription":video.shortdescription,"longdescription":video.longdescription});
				}

				/*BELOW WE SORT THE RESULTS DESCENDING BASED ON ID*/
				var dataSortField:SortField = new SortField();
				dataSortField.name = "id";
				dataSortField.numeric = true;
				dataSortField.descending = true;
				var numericDataSort:Sort = new Sort();
				numericDataSort.fields = [dataSortField];
				tempArrayColl.sort = numericDataSort;
				tempArrayColl.refresh();

				/*REBUILD THE XML*/
				var xmlstr:String = "<mediacenter>";
				for each (var finalVideo:Object in tempArrayColl)
				{
					xmlstr += "<video id=\"ven"+finalVideo.id+"\">\n";
					xmlstr += "<title>"+finalVideo.title+"</title>\n"; 
					xmlstr += "<shortdescription>"+finalVideo.shortdescription+"</shortdescription>\n"; 
					xmlstr += "<longdescription>"+finalVideo.longdescription+"</longdescription>\n"; 
					xmlstr += "</video>";
				}
				xmlstr += "</mediacenter>";
				parentDocument.video_list = new XML(xmlstr);
				parentDocument.current_video = parentDocument.video_list.children()[0];
				parentDocument.pagination_setup(this);

				}

		/* =================================== */
		/* = FUNCTION TO SORT BY MOST VIEWED = */
		/* =================================== */
		public function sortMostViewed():void
		{
			/*POP UP SEARCH IN PROGRESS SCREEN*/
			parentDocument.main_view_stack.selectedIndex = 2;

			/*SET CURRENT SEARCH TERM (FOR DISPLAY ON VIDEO PLAYER PAGE)*/

			/*SEARCHING MESSAGE*/
			parentDocument.current_search_message = "Sorting By Most Viewed";

			akamai_svc.send();
		}



		/* ====================================== */
		/* = AKAMAI RESULT HANDLER 				= */
		/* ====================================== */
		public function akamaiResultHandler():void
		{

		  //SET UP SORT BY MOST VIEWED
		  // Convert XML to ArrayCollection
		  var clipentArray:ArrayCollection = new ArrayCollection();
          for each(var clip:XML in akamai_svc.lastResult.clips.clipent)
		  {
              clipentArray.addItem(clip);
          }

			// Convert XML to ArrayCollection
			  var videoArray:ArrayCollection = new ArrayCollection();
			  var finalArray:ArrayCollection = new ArrayCollection();
	          for each(var video:XML in parentDocument.video_list.video)
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
					xmlstr += "<video id=\""+finalVideo.id+"\">\n";
					xmlstr += "<title>"+finalVideo.title+"</title>\n"; 
					xmlstr += "<shortdescription>"+finalVideo.shortdescription+"</shortdescription>\n"; 
					xmlstr += "<longdescription>"+finalVideo.longdescription+"</longdescription>\n"; 
					xmlstr += "<streamhits>"+finalVideo.streamhits+"</streamhits>\n"; 
					xmlstr += "</video>";
				}
				xmlstr += "</mediacenter>";
				parentDocument.video_list = new XML(xmlstr);
				parentDocument.current_video = parentDocument.video_list.children()[0];
				parentDocument.pagination_setup(this);
				parentDocument.main_view_stack.selectedIndex = 3;
		}
		
		/* ====================== */
		/* = SHARE MENU HANDLER = */
		/* ====================== */
		public function shareMenuHandler(event:MenuEvent):void
		{
			if(event.label == "Email")
			{
				parentDocument.sendEmail(parentDocument.current_video.title); 
				
			}
			if(event.label == "Embed")
			{
				parentDocument.embedVideo(parentDocument.current_video.title); 

			}
			
			if(event.label == "Download")
			{
				parentDocument.downloadVideo(parentDocument.current_video.@id); 
				
			}
		}




	/* ============================ */
	/* = FUNCTION TO REPLAY VIDEO = */
	/* ============================ */
	public function replayVideo(evt:MouseEvent=null):void {

		// Cast the ModuleLoader's child to the interface.
          // This child is an instance of the module.
          // We can now call methods on that instance.
          var vpchild:* = video_player.child as VideoPlayerInterface;                
            if (video_player.child != null) {                    
                // Call setters in the module to adjust its
                // appearance when it loads.
			  
              vpchild.setVideo(parentDocument.current_video.@id,true);
			   //video_title_txt.text = evt.currentTarget.selectedItem.title;
			   //video_short_description_txt.text = evt.currentTarget.selectedItem.shortdescription;
			   //video_long_description_txt.htmlText = evt.currentTarget.selectedItem.longdescription;
            } else {                
                trace("Uh oh. The video_player.child property is null");                 
            }
}


/*
	public function recommendedMouseOver(evt:MouseEvent):void {
	var thumbOver:Image = new Image();
	thumbOver.source = "assets/images/thumb_overlay.png";
	thumbOver.x = evt.currentTarget.x;
	thumbOver.y = evt.currentTarget.y;
	thumbOver.width = evt.currentTarget.width;
	thumbOver.height = evt.currentTarget.height;
	recVBox.addChild(thumbOver);


	}
	
	public function recommendedMouseOut(evt:MouseEvent):void {
		removeChild(thumbOver);
	}

*/


	}
}