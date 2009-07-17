package components.views
{
	
	import flash.events.MouseEvent;
	
	import modules.video_player.VideoPlayerInterface;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.controls.Alert;
	import mx.controls.Menu;
	import mx.controls.Text;
	import mx.controls.TileList;
	import mx.modules.ModuleLoader;
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
		public var shareMenuData:XML;
		public var sortMenuData:XML;
		public var share_menu_btn:Button;
		public var sort_menu_btn:Button;
		public var video_title_txt:Text;
		public var video_short_description_txt:Text;
		public var video_long_description_txt:Text;
		public var video_player:ModuleLoader;
		public var video_tile_list:TileList;
		[Bindable] public var current_video:XML;
		[Bindable] public var currentModuleName:String;

		/* =================================== */
		/* = VARS FOR PAGINATION OF TILELIST = */
		/* =================================== */
		[Bindable] public var search_results_dp:ArrayCollection = new ArrayCollection();
		[Bindable] public var pagedDataProvider:ArrayCollection;
		[Bindable] private var currentPage:int=1;
		[Bindable] private var pageCount:int=0;
		private var PERPAGE:int=10;
		public var next_btn:Button;
		public var previous_btn:Button;
		public var results_for_txt:Text;
		
		
		/* ======================================== */
		/* = INITIALIZE BASIC VIDEO PLAYER SCREEN = */
		/* ======================================== */
		public function recommended_video_init():void
		{
			
			
			/*EVENT LISTENERS*/
			share_menu_btn.addEventListener(MouseEvent.CLICK,createAndShowShareMenu);
			sort_menu_btn.addEventListener(MouseEvent.CLICK,createAndShowSortMenu);
			
			/*SET UP PAGINATION*/
			pagination_setup()
			
			
			//SET UP VARS IF RELOADING VIDEO PAGE WITHOUT SEARCH
			if(parentDocument.current_video == null)
			{
				parentDocument.current_video = video_tile_list.dataProvider.getItemAt(0);
				parentDocument.current_search_term = "No Search Term";
				
			}
			
				//SET UP FIRST VIDEO THAT WILL PLAY
				video_title_txt.text = parentDocument.current_video.title;
				video_short_description_txt.text = parentDocument.current_video.shortdescription;
				video_long_description_txt.htmlText = parentDocument.current_video.longdescription;
				results_for_txt.text = "Results For \"" + parentDocument.current_search_term +"\"";
				video_player.url="modules/video_player/VideoPlayer.swf?video_id={parentDocument.current_video.@id}";
			    
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
		
		
		
		/* ===================== */
		/* = SET UP PAGINATION = */
		/* ===================== */ 
		public function pagination_setup():void
		{
			 
			// Convert XML to ArrayCollection
			  var ii:int = 0;
              for each(var s:XML in parentDocument.video_list.video){
				  if (ii > 5)
				  {
                  	search_results_dp.addItem(s);
				  }	
				  ii++
              }
			
	
			pagedDataProvider=new ArrayCollection();
			  	pageCount=(search_results_dp.length/PERPAGE)+1;
			    currentPage=1;
			    if(pageCount > 1){
			        next_btn.enabled=true;
			    }
			    if(search_results_dp.length >= PERPAGE){
			        for(var i:int=0;i<PERPAGE;i++){
			            pagedDataProvider.addItem(search_results_dp.getItemAt(i));
			        }
			    }else{
			        pagedDataProvider=search_results_dp;
			    }
		}
		
	     
		/* ======================================= */
		/* = FUNCTION TO GET NEXT PAGE OF VIDEOS = */
		/* ======================================= */
		public function getNextPage():void{
		    var start:int=PERPAGE*currentPage;
		    var end:int=0;
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
		    currentPage++; //INCREMENT PAGE
		    previous_btn.enabled=true;
		    if(currentPage==pageCount){
		        next_btn.enabled=false;
		    }
		}
	
		/* =============================================== */
		/* = FUNCTION TO GET THE PREVIOUS PAGE OF VIDEOS = */
		/* =============================================== */
		public function getPreviousPage():void{
		    currentPage--; //DECREMENT PAGE
		    next_btn.enabled=true;
		    if(currentPage==1){
		        previous_btn.enabled=false;
		    }
		    var start:int=PERPAGE*(currentPage-1);
		    var end:int=start+PERPAGE;
		    pagedDataProvider=new ArrayCollection();
		    for(var i:int=start;i<end;i++){
		        pagedDataProvider.addItem(search_results_dp.getItemAt(i));
		    }
		}
	
	
		/* =================================== */
		/* = FUNCTION TO SHOW SELECTED VIDEO = */
		/* =================================== */
		public function showVideo(evt:MouseEvent):void {
			
			//SET CURRENT VIDEO BASED ON CLICKED THUMBNAIL
			current_video = evt.currentTarget.selectedItem;
	 		// Cast the ModuleLoader's child to the interface.
            // This child is an instance of the module.
            // We can now call methods on that instance.
            var vpchild:* = video_player.child as VideoPlayerInterface;                
            if (video_player.child != null) {                    
                // Call setters in the module to adjust its
                // appearance when it loads.
               vpchild.setVideo(current_video.@id);
			   video_title_txt.text = current_video.title;
			   video_short_description_txt.text = current_video.shortdescription;
			   video_long_description_txt.htmlText = current_video.longdescription;
            } else {                
                trace("Uh oh. The video_player.child property is null");                 
            }
           
	
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
	        shareMenu.show(565, share_menu_btn.y + 97);
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
	        sortMenu.show(sort_menu_btn.x + 5, 460);  
          }
       
 

	}
}