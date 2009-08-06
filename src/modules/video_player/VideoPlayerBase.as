
			import com.akamai.net.*;
			import com.akamai.rss.AkamaiBOSSParser;
			
			import flash.display.StageDisplayState;
			import flash.events.FullScreenEvent;
			import flash.geom.*;
			
			import mx.controls.Alert;
			import mx.controls.textClasses.TextRange;
			import mx.core.FlexGlobals;
			import mx.core.UIComponent;
			import mx.events.SliderEvent;
			import mx.managers.PopUpManager;
			import mx.utils.*;
			
			import org.openvideoplayer.cc.*;
			import org.openvideoplayer.events.*;
			import org.openvideoplayer.net.*;

;

					
			/*Define private variables*/
			private var _nc:AkamaiConnection;
			private var _ns:AkamaiNetStream;
			private var _bossMetafile:AkamaiBOSSParser;
			private var _sliderDragging:Boolean;
			private var _waitForSeek:Boolean;
			private var _video:Video;
			private var _videoHolder:UIComponent;
			private var _bandwidthMeasured:Boolean;  
			private var _hasEnded:Boolean;
			private var _videoSettings:Object;
			private var _streamLength:Number;
			private var _isPaused:Boolean;
			private var _ccMgr:OvpCCManager;
			private var _captionTimer:Timer;
			private var _ccOn:Boolean;
			private var _ccPositioned:Boolean;


            
            
            [Bindable]
            private var video_id:String;
			[BINDABLE]
			public var VIDEO_URL:String = "http://usana.edgeboss.net/flash/usana/h.264/"+FlexGlobals.topLevelApplication.current_video.@id+".mp4?xmlvers=1";
			public var _CAPTION_URL_:String = "http://www.usana.com/media/File/mediaCenter/closed_caption/"+FlexGlobals.topLevelApplication.current_video.@id+".xml";
	
		
			/* ================================================== */
			/* = FUNCTION TO CHANGE VIDEO URL AND START PLAYBACK = */
			/* ================================================== */
	 		public function setVideo(id:String):void {
			if(_ns)
			{
				_ns.pause(); 
			}
	           VIDEO_URL = "http://usana.edgeboss.net/flash/usana/h.264/"+id+".mp4?xmlvers=1";
	           _CAPTION_URL_ = "http://www.usana.com/media/File/mediaCenter/closed_caption/"+FlexGlobals.topLevelApplication.current_video.@id+".xml";
				//CHECK FOR CLOSE CAPTIONED FILE
				closed_caption_svc.send();
	            startPlayback();
	        }
	    
			 
			public function setIsPausedVar(isPaused:Boolean):void{
				_isPaused = isPaused;
				doPlayPause();
			}
			
			
			// Define functions
			private function init():void {
				
				stage.addEventListener(FullScreenEvent.FULL_SCREEN, handleReturnFromFullScreen);
				//
				_bossMetafile = new AkamaiBOSSParser();
				_bossMetafile.addEventListener(OvpEvent.PARSED,bossParsedHandler);
				_bossMetafile.addEventListener(OvpEvent.LOADED,bossLoadHandler);
				_bossMetafile.addEventListener(OvpEvent.ERROR,errorHandler);
				//
				_nc = new AkamaiConnection();
				
				// This example shows all the possible events that you may subscribe to.
				// In a real project, you would only choose a subset of these. 
				_nc.addEventListener(OvpEvent.ERROR,errorHandler);
				_nc.addEventListener(OvpEvent.BANDWIDTH,bandwidthHandler);
				_nc.addEventListener(OvpEvent.STREAM_LENGTH,streamLengthHandler); 
				_nc.addEventListener(NetStatusEvent.NET_STATUS,netStatusHandler);
				
				_bandwidthMeasured = false;
				addVideoToStage();
				//
				_ccOn = true;
				_ccPositioned = false;
				_captionTimer = new Timer(10000);
				_captionTimer.addEventListener(TimerEvent.TIMER, onCaptionTimer);
				 
		
				// This inititates the video playback
				startPlayback();
			
			}	
			// Handles the notification that the BOSS feed was successfully loaded.
			private function bossLoadHandler(e:OvpEvent):void {
				//write("BOSS loaded successfully");
			}
			// Handles the notification that the BOSS feed was successfully parsed
			private function bossParsedHandler(e:OvpEvent):void {
				 
				// Establish the connection
				trace("requested protocl set to " + _nc.requestedProtocol);
				_nc.connectionAuth = _bossMetafile.connectAuthParams;
				_nc.connect(_bossMetafile.hostName); 
			}
			
			// Once a good connection is found, this handler will be called
			private function connectedHandler():void {
				_ns = new AkamaiNetStream(_nc.netConnection);

				_ns.addEventListener(OvpEvent.COMPLETE,completeHandler); 
				_ns.addEventListener(OvpEvent.PROGRESS,update); 
				_ns.addEventListener(NetStatusEvent.NET_STATUS,streamStatusHandler);
				_ns.addEventListener(OvpEvent.NETSTREAM_PLAYSTATUS,streamPlayStatusHandler);
				_ns.addEventListener(OvpEvent.NETSTREAM_METADATA,metadataHandler);
				_ns.addEventListener(OvpEvent.STREAM_LENGTH,streamLengthHandler);
				
				
				
				// Create the closed captioning object and give it the net stream
				_ccMgr = new OvpCCManager(_ns);
				_ccMgr.addEventListener(OvpEvent.ERROR, errorHandler);		
				_ccMgr.addEventListener(OvpEvent.CAPTION, captionHandler);
//				_ccMgr.parse(_CAPTION_URL_); 
				videoControls.bClosedcaption.styleName = "ccBtnOn";				
				
				_ns.maxBufferLength = 2;
				_ns.liveStreamAuthParams = _bossMetafile.playAuthParams;
				
				_video.attachNetStream(_ns);
				
					//HIDE REPLAY BUTTON
					parentDocument.replay_btn.visible=false;
					
					currentState = "";
					write("Successfully connected to: " + _nc.netConnection.uri);
					write("Port: " + _nc.actualPort);
					write("Protocol: " + _nc.actualProtocol);
					write("Server IP address: " + _nc.serverIPaddress);
					
					// If an ondemand stream, start the asynchronous process of requesting the stream length 
					_nc.requestStreamLength(_bossMetafile.streamName);

					// start the asynchronous process of estimating bandwidth if it hasn't already been esimated
					if (_bandwidthMeasured) {
						playVideo(_bossMetafile.streamName);
					} else {
						write("Measuring bandwidth ... ");
						_nc.detectBandwidth();
					}
					
					
				}

			// Handles all error events
			private function errorHandler(e:OvpEvent):void {
				switch(e.data.errorNumber) {
				case OvpError.STREAM_NOT_FOUND:
					Alert.show("Connected to the server at " + _nc.serverIPaddress + " but timed-out trying to locate the live stream " + _bossMetafile.streamName, "UNABLE TO FIND STREAM ", Alert.OK);
					break;
				default:
					Alert.show("Error #" + e.data.errorNumber+": " + e.data.errorDescription, "ERROR", Alert.OK);
					break;
				}
			}
			// Handles the result of the bandwidth estimate
			private function bandwidthHandler(e:OvpEvent):void {
				_bandwidthMeasured  = true;
				write("Bandwidth measured at " + e.data.bandwidth+ " kbps and latency is " + e.data.latency + " ms.");
				// At this stage you would use the bandwidth result in order to choose
				// the appropriate file for the user.
				playVideo(_bossMetafile.streamName);
			}
			// Receives all status events dispatched by the active NetConnection
			private function netStatusHandler(e:NetStatusEvent):void {
				write(e.info.code);
				switch (e.info.code) {
					case "NetConnection.Connect.Rejected":
						write("Rejected by server. Reason is "+e.info.description);
						break;
					case "NetConnection.Connect.Success":
						connectedHandler();
						break;
				}
			}
			// Receives all status events dispatched by the active NetStream
			private function streamStatusHandler(e:NetStatusEvent):void {
				if (e.info.code == "NetStream.Buffer.Full") {
					// _waitForSeek is used to stop the scrubber from updating
					// while the stream transtions after a seek
					_waitForSeek = false;
				}
			}
			// Receives all onPlayStatus events dispatched by the active NetStream
			private function streamPlayStatusHandler(e:OvpEvent):void {

			}
			// Receives all onMetadata events dispatched by the active NetStream
			private function metadataHandler(e:OvpEvent):void {
				positionCaption();
				
				// Adjust the video dimensions on the stage if they do not match the metadata
				if ((Number(e.data["width"]) != _video.width)  || (Number(e.data["height"]) != _video.height)) {
					scaleVideo(Number(e.data["width"]),Number(e.data["height"]));
				
				} else {
					
					_video.visible = true;
					
				}
				
				
				
			}
			// Scales the video to fit into the 544x306 window while preserving aspect ratio.
			private function scaleVideo(w:Number,h:Number):void {

				if (w/h <= 16/9) {
					_video.width = 306*w/h;
					_video.height = 306;
				} else {
					_video.width = 544;
					_video.height = 544*h/w;
				}
				_video.x = (_videoHolder.width-_video.width)/2;
				_video.y = (_videoHolder.height-_video.height)/2;
				
				_video.visible = true;
				
			}
			
						
			// Handles the stream length response after a request to requestStreamLength
			private function streamLengthHandler(e:OvpEvent):void {
				write("Stream length is " + e.data.streamLength);
				videoControls.slider.maximum = e.data.streamLength;
				videoControls.slider.enabled = true;
				videoControls.bPlayPause.enabled = true;
				videoControls.bFullscreen.enabled = true;
				_streamLength = e.data.streamLength;
			}
			
			// Receives information that stream playback is complete. This notification
			// should not be used when playing back progressive content as the Flash client
			// does not dispatch the NetStream.onPlayStatus event on which this notification is based.
			private function completeHandler(e:OvpEvent):void {
				write("Stream is complete");
				_hasEnded = true;
				videoControls.bPlayPause.styleName = "vpPlayBtn";
				//SHOW REPLAY BUTTON
				parentDocument.replay_btn.visible=true;
			}
			// Attaches the video to the stage
			private function addVideoToStage():void {
				_videoHolder= new UIComponent();
				_video = new Video(544,306);
				_video.smoothing = true;
				_video.visible = false;
				_video.x = (_videoHolder.width-_video.width)/2;
				_video.y = (_videoHolder.height-_video.height)/2;
				_videoHolder.addChild(_video);
        		videoWindow.addChild(_videoHolder);
   			}
   			// Plays the stream 
   			private function playVideo(name:String):void {
   				_ns.play(name);
   				videoControls.bPlayPause.styleName = "vpPauseBtn";  				
   			}
   			// Updates the time display and slider
   			private function update(e:OvpEvent):void {
   				videoControls.timeDisplay.text =  _ns.timeAsTimeCode + "|"+ _nc.streamLengthAsTimeCode(_streamLength);

   					if (!_sliderDragging && !_waitForSeek) {
   						videoControls.slider.value = _ns.time;
   					
   				}
   			}
   			// Seeks the stream after the slider is dropped
   			private function doSeek():void { 
   				hideCaption();
   				write("calling seek to " + videoControls.slider.value);
   				if (_hasEnded) {
   					_hasEnded = false;
   					_ns.play(VIDEO_URL);
   					videoControls.bPlayPause.styleName = "vpPauseBtn";
   				} 
   				_ns.seek(videoControls.slider.value);
   			}
   			// Toggles the dragging state
   			public function toggleDragging(state:Boolean):void {
   				_sliderDragging = state;
   				if (!state) {
   					_waitForSeek = true;
   					doSeek();
   				}
   			}
   			 
   			// Commences connection to a new link
			private function startPlayback():void {
				//output.text = "";
				videoControls.bPlayPause.enabled = false;
				videoControls.bFullscreen.enabled = false;
				_hasEnded = false;
				// Clean up from previous session, if it exists
				if (_nc.netConnection is NetConnection) {
					_ns.useFastStartBuffer = false;
					_nc.close();
				}
				
			//	mx.controls.Alert.show(VIDEO_URL);
				
				_bossMetafile.load(VIDEO_URL)
					_isPaused = false;
				
			}
			
			
			
   			// Handles play and pause
   			public function doPlayPause():void {
   				switch (_isPaused){

   					case false:
   						videoControls.bPlayPause.styleName = "vpPlayBtn";
   						_ns.pause();
   						_isPaused=true;
   					break;
   					case true:
   						videoControls.bPlayPause.styleName = "vpPauseBtn";
   						if (_hasEnded) {
   							_hasEnded = false;
   							_ns.play(VIDEO_URL);
   							_isPaused=false;
   						} else {
   							_ns.resume();
   							_isPaused=false;
   						}
   					break;
   				}
   			}
   			// Formats the slider dataTip 
			public function showVolume(val:String):String {
				return ("Volume: "+Math.round(Number(val)*100)+"%");
			}
			// Converts time to timecode
			public function showScrubTime(val:String):String {
	   			var sec:Number = Number(val); 
				var h:Number = Math.floor(sec/3600);
				var m:Number = Math.floor((sec%3600)/60);
				var s:Number = Math.floor((sec%3600)%60);
				return (h == 0 ? "":(h<10 ? "0"+h.toString()+":" : h.toString()+":"))+(m<10 ? "0"+m.toString() : m.toString())+":"+(s<10 ? "0"+s.toString() : s.toString());
			}
			// Changes the stream volume
			public function changeVolume(event:SliderEvent):void {
				//if (_ns is AkamaiConnection) 
					_ns.volume = event.value;
			}
			// Writes trace statements to the output display
			private function write(msg:String):void {
				//output.text += msg + "\n";
				//output.verticalScrollPosition = output.maxVerticalScrollPosition+1;
			}
			// Switches to full screen mode
			public function switchToFullScreen():void {
				    // when going out of full screen mode 
				    // we use these values
				   
				    _videoSettings = new Object(); 
				    _videoSettings.savedWidth = _videoHolder.width;
				    _videoSettings.savedHeight = _videoHolder.height;
				    _videoSettings.x = _videoHolder.x;
				    _videoSettings.y = _videoHolder.y;
				  
				  	// Creates a rectangle around the video and makes it go fullscreen - need to find a better way to do this
				    stage["fullScreenSourceRect"] = new Rectangle(25, 75, 544, 306);
				    stage["displayState"] = StageDisplayState.FULL_SCREEN;
				    
				    
				    videoWindow.removeChild(_videoHolder);
					addChild(_videoHolder);

					/*
					placing the video in a popup seems to work weel, the only problem is getting the controls in there
				   	PopUpManager.addPopUp(_videoHolder,parentApplication as DisplayObject,true);
					PopUpManager.centerPopUp(_videoHolder);
					*/

					 

					// positions the video
				    _video.width = _videoHolder.width = stage.stageWidth;
				    _video.height = _videoHolder.height = stage.stageWidth*9/16;
				    
				    _video.x = _videoHolder.x = 0;
				   	_video.y = _videoHolder.y = 0;
				   	
				    _video.smoothing = true;
				    

				   
			}
			// Handles the return from fullscreen
			private function handleReturnFromFullScreen(e:FullScreenEvent):void {
				if (!e.fullScreen) {
					//PopUpManager.removePopUp(_videoHolder);
					//removeChild(_videoHolder);
					//_videoHolder.removeChild(videoControls);
					//addChild(videoControls);
					videoWindow.addChild(_videoHolder);
				    _video.smoothing = true;
				    _videoHolder.width = _videoSettings.savedWidth;
				    _videoHolder.height = _videoSettings.savedHeight;
				    _videoHolder.x = _videoSettings.x
				   	_videoHolder.y = _videoSettings.y
				    scaleVideo(_video.videoWidth,_video.videoHeight);
				}
			}
			
			// Handles the displaying of the caption
		private function showCaption(ccObj:Caption):void {
			captionLabel.htmlText = ccObj.text;
			
			// IMPORTANT!  This line causes the LayoutManager to run immediately, allowing us to change the style below.
			captionLabel.validateNow();	
		
			// Formatting within the caption string			
			for (var i:uint = 0; i < ccObj.captionFormatCount(); i++) {
				var ccFormatObj:CaptionFormat = ccObj.getCaptionFormatAt(i);
				var txtRange:TextRange = new TextRange(captionLabel, false, ccFormatObj.startIndex, ccFormatObj.endIndex);
				var styleObj:Style = ccFormatObj.styleObj;
				
				if (styleObj) {
					if (styleObj.backgroundColor != "") {
						// FYI: setStyle is one of the most expensive calls, performance-wise, in the Flex SDK!
						captionLabel.setStyle("backgroundColor", styleObj.backgroundColor);
					}
					
					//callLater(changeTextRange, [txtRange, styleObj]);
					
					if (captionLabel.wordWrap != styleObj.wrapOption) {
						captionLabel.wordWrap = styleObj.wrapOption;
					}
				}
			}
				
			captionLabel.visible = true;
			
			if (ccObj.endTime > 0) {
				_captionTimer.delay = (ccObj.endTime - ccObj.startTime)*1000;
				_captionTimer.start();
			}
		}
		
		
		
		// Handles the hiding of the caption
		private function hideCaption():void {
			_captionTimer.stop();
			captionLabel.visible = false;
		}
		
		private function onCaptionTimer(e:TimerEvent):void {
			trace("******* onCaptionTimer *********");
			this.hideCaption();
		}
		
		// Receives caption events dispatched by OvpCCManager class
		private function captionHandler(e:OvpEvent):void {
			if (e && e.data && (e.data is Caption)) {
				hideCaption();
				showCaption(Caption(e.data));				
			}
		}
		
		private function positionCaption():void {
			// only need to do this once
			

			if (!_ccPositioned) {
				_ccPositioned = true;
				var pt:Point = videoContainer.contentToGlobal(new Point(videoContainer.x, videoContainer.y));
				pt = captionLabel.globalToContent(pt);
				captionLabel.x = pt.x;
				captionLabel.y = pt.y + videoWindow.height - captionLabel.height;	
					
			}
			

		}
		
		private function onClickCC(e:Event):void {
			_ccOn = !_ccOn;
			captionLabel.visible = _ccOn;
			_ccMgr.enableCuePoints(_ccOn);
			var color:String = _ccOn ? "#00cc00" : "#cc0000";
			//ccBox.setStyle("borderColor", color);
			if (!_ccOn) {
				captionLabel.htmlText = "";
				videoControls.bClosedcaption.styleName = "ccBtn";
			} else {
				videoControls.bClosedcaption.styleName = "ccBtnOn";
			}
		}
		
		
		/* ========================================== */
		/* = FUNCTION CALLED  IF CC FILE EXISTS = */
		/* ========================================== */
		private function ccFound():void
		{
			videoControls.bClosedcaption.enabled = true;
		}
		
		
		/* =============================================== */
		/* = FUNCTIONC CALLED IF CC FILE DOES NOT EXISTS = */
		/* =============================================== */
		private function ccNotFound():void
		{
			//mx.controls.Alert.show('disabling');
			
			videoControls.bClosedcaption.enabled = false;
		}
		
	


