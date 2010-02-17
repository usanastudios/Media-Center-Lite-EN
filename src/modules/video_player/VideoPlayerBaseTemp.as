
import com.akamai.net.*;


import components.controls.VideoControls;

import flash.events.FullScreenEvent;
import flash.events.HTTPStatusEvent;
import flash.events.TimerEvent;
import flash.geom.*;

import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.core.UIComponent;
import mx.events.SliderEvent;
import mx.utils.*;

import org.openvideoplayer.cc.*;
import org.openvideoplayer.events.*;
import org.openvideoplayer.net.*;



/*Define private variables*/
private var _nc:AkamaiConnection;
private var _ns:OvpNetStream;

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
private var loadingOverlayTimer:Timer;
public var _controls:VideoControls;


[Bindable]
private var video_id:String;
[BINDABLE]
public var _DOWNLOADURL:String = "http://www.usanamedia.com/downloads/zip/" +FlexGlobals.topLevelApplication.current_video.@id+".zip";
public var VIDEO_URL:String = FlexGlobals.topLevelApplication.current_video.@videoUrl;
public var _CAPTION_URL_:String = "http://www.usana.com/media/File/mediaCenter/closed_caption/"+FlexGlobals.topLevelApplication.current_video.@id+".xml";
public var HOST_NAME:String = FlexGlobals.topLevelApplication._hostname;



/* =================================================== */
/* = FUNCTION TO CHANGE VIDEO URL AND START PLAYBACK = */
/* =================================================== */
public function setVideo(id:String,playNow:Boolean):void {
	if(_ns)
	{
		_ns.pause(); 
	}
	 
	
	 VIDEO_URL = FlexGlobals.topLevelApplication.current_video.@videoUrl;
	_CAPTION_URL_ = "http://www.usana.com/media/File/mediaCenter/closed_caption/"+FlexGlobals.topLevelApplication.current_video.@id+".xml";
	_DOWNLOADURL = "http://www.usanamedia.com/downloads/zip/" +FlexGlobals.topLevelApplication.current_video.@id+".zip";
	
	
	//CHECK FOR CLOSE CAPTIONED & DOWNLOADABLE FILES
	var loader:URLLoader = new URLLoader();
	var DLloader:URLLoader = new URLLoader();
	
	loader.addEventListener(IOErrorEvent.IO_ERROR,ccNotFound);
	loader.addEventListener(Event.COMPLETE,ccFound);
	DLloader.addEventListener(IOErrorEvent.IO_ERROR,DLNotFound);
	DLloader.addEventListener(Event.COMPLETE,DLFound);
	
	var request:URLRequest = new URLRequest("http://www.usana.com/media/File/mediaCenter/closed_caption/"+FlexGlobals.topLevelApplication.current_video.@id+".xml");
	var DLrequest:URLRequest = new URLRequest("http://www.usanamedia.com/downloads/zip/" +FlexGlobals.topLevelApplication.current_video.@id+".zip");
	
	try {
		loader.load(request);
		DLloader.load(DLrequest);
	} 
	catch (error:HTTPStatusEvent) {
		mx.controls.Alert.show("Unable to load File.");
	}
	
	if(playNow == true)
	{
		parentDocument.play_overlay_btn.visible=false;
		parentDocument.large_thumbnail_overlay.visible=false;
		startPlayback("on_demand");
	}
	else
	{
		parentDocument.play_overlay_btn.visible=true;
		parentDocument.large_thumbnail_overlay.visible=true;
		
		startPlayback();
	}
	
	write("video set");
}


public function setIsPausedVar(isPaused:Boolean):void{
	_isPaused = isPaused;
	trace('testing');
	doPlayPause();
	
}




// Define functions
private function init():void {
	stage.addEventListener(FullScreenEvent.FULL_SCREEN, handleReturnFromFullScreen);
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
	_ccOn = false;
	_ccPositioned = false;
	_captionTimer = new Timer(10000);
	_captionTimer.addEventListener(TimerEvent.TIMER, onCaptionTimer);
	
	// This inititates the video playback
   //startPlayback();
	
	write("module initiated");
	
}	


// Once a good connection is found, this handler will be called
private function connectedHandler():void {
	
	_ns = new OvpNetStream(_nc);
	
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
	_ccMgr.parse(_CAPTION_URL_); 
	videoControls.bClosedcaption.styleName = "ccBtnOn";				
	
	_ns.maxBufferLength = 2;
	//_ns.liveStreamAuthParams = _bossMetafile.playAuthParams;
	
	_video.attachNetStream(_ns);
	
	//HIDE REPLAY BUTTON
	parentDocument.replay_btn.visible=false;
	parentDocument.play_overlay_btn.visible=false;
	parentDocument.large_thumbnail_overlay.visible=false;
	
	
	currentState = "";
	write("Successfully connected to: " + _nc.netConnection.uri);
	//write("Port: " + _nc.actualPort);
	//write("Protocol: " + _nc.actualProtocol);
	//write("Server IP address: " + _nc.serverIPaddress);
	
	// If an ondemand stream, start the asynchronous process of requesting the stream length 
	_nc.requestStreamLength(VIDEO_URL);
	
	// start the asynchronous process of estimating bandwidth if it hasn't already been esimated
	if (_bandwidthMeasured) {
		playVideo(VIDEO_URL); 
	} else {
	write("Measuring bandwidth ... ");
		_nc.detectBandwidth();
	}
	
	
}

// Handles all error events
private function errorHandler(e:OvpEvent):void {
	switch(e.data.errorNumber) {
		case OvpError.STREAM_NOT_FOUND:
			Alert.show("Connected to the server at " + _nc.serverIPaddress + " but timed-out trying to locate the live stream " + VIDEO_URL, "UNABLE TO FIND STREAM ", Alert.OK);
			break;
		default:
			//Alert.show("Error #" + e.data.errorNumber+": " + e.data.errorDescription, "ERROR", Alert.OK);
			break;
	}
}
// Handles the result of the bandwidth estimate
private function bandwidthHandler(e:OvpEvent):void {
	_bandwidthMeasured  = true;
	write("Bandwidth measured at " + e.data.bandwidth+ " kbps and latency is " + e.data.latency + " ms.");
	// At this stage you would use the bandwidth result in order to choose
	// the appropriate file for the user.

	playVideo(VIDEO_URL);
}
// Receives all status events dispatched by the active NetConnection
private function netStatusHandler(e:NetStatusEvent):void {
	//write(e.info.code);
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
	write(name);
	//trace("calling"+_ns);
      _ns.play(name);
	
	// Removes the loading image after 1 second (to be safe)
	loadingOverlayTimer = new Timer(1000);
	loadingOverlayTimer.addEventListener(TimerEvent.TIMER, onLoadingOverlayTimer);
	loadingOverlayTimer.start();
	//parentDocument.loading_overlay.visible = false;
	
	videoControls.bPlayPause.styleName = "vpPauseBtn";  
	changeVolume();
	
}

private function onLoadingOverlayTimer(event:TimerEvent):void {
	parentDocument.loading_overlay.visible = false;
	loadingOverlayTimer.reset();
	loadingOverlayTimer.stop();
}

// Updates the time display and slider
private function update(e:OvpEvent):void {
	videoControls.timeDisplay.text =  _ns.timeAsTimeCode + "/"+ _nc.streamLengthAsTimeCode(_streamLength);
	
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
private function startPlayback(mode:String = null):void {
	
	//write("Attempting to connect to " + HOST_NAME + " ...");
	videoControls.bPlayPause.enabled = false;
	videoControls.bFullscreen.enabled = false;
	_hasEnded = false;
	// Clean up from previous session, if it exists
	if (_nc.netConnection is NetConnection) {
		_ns.useFastStartBuffer = false;
		_nc.close();
	}
	
	_nc.connect(currentState == "progressive" ? null:HOST_NAME);
	
	
	//IF CLICKING VIDEO OR PLAY BUTTON, PLAY VIDEO (OTHERWISE DO NOT AUTO PLAY)
	if(mode == "on_demand")
	{
		write("Thumbnail");
		playVideo(VIDEO_URL);
		
	}
	
	/*IF COMING FROM A WALL VIDEO, PLAY VIDEO NOW*/
	if(FlexGlobals.topLevelApplication.search_type == "wall_video")
	{
		write("Wall Video");
		playVideo(VIDEO_URL);
		parentDocument.play_overlay_btn.visible=true;
		parentDocument.large_thumbnail_overlay.visible=true;
		
	}
	_isPaused = false;
	
	
}



// Handles play and pause
public function doPlayPause():void {
	switch (_isPaused){
		
		case false:
			videoControls.bPlayPause.styleName = "vpPlayBtn";
			if(_ns)
			{
				_ns.pause();
			}
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
public function changeVolume(event:SliderEvent=null):void {
	
	
	//if (_ns is AkamaiConnection) 
	if(event)
	{
		_ns.volume = event.value;
	}
	else
	{
		try
		{
			_ns.volume = videoControls.volumeSlider.value;
		} 
		catch (e:Error)
		{
			
		}
		
	}
	
}

// Writes trace statements to the output display
private function write(msg:String):void {
	//FlexGlobals.topLevelApplication.output.text += msg + "\n";
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
	
	//var popup:VideoPlayerFullScreen = new VideoPlayerFullScreen();
	//PopUpManager.addPopUp(popup, this, true);
	//PopUpManager.centerPopUp(popup);
	
	
	videoWindow.removeChild(_videoHolder);
	addChild(_videoHolder);
	
	
	
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
	
	/*
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
	
	*/
	
	if (_ccOn == true) {
		captionLabel.visible = true; }
	
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

public function onClickCC(e:Event):void {
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
private function ccFound(event:Event):void
{
	videoControls.bClosedcaption.enabled = true;
	//mx.controls.Alert.show("CC Found.");
}


/* =============================================== */
/* = FUNCTIONC CALLED IF CC FILE DOES NOT EXISTS = */
/* =============================================== */
private function ccNotFound(event:IOErrorEvent):void
{
	videoControls.bClosedcaption.enabled = false;
	//mx.controls.Alert.show("Unable to load CC File.");
}

/* ========================================== */
/* = FUNCTION CALLED  IF DOWNLOAD FILE EXISTS = */
/* ========================================== */
private function DLFound(event:Event):void
{
	// Alert.show("Downloadable File Found.");
}


/* =============================================== */
/* = FUNCTIONC CALLED IF DOWNLOAD FILE DOES NOT EXISTS = */
/* =============================================== */
private function DLNotFound(event:IOErrorEvent):void
{
	// Alert.show("Downloadable File Not Found.");
}




