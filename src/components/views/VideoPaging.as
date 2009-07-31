	import mx.controls.Alert;

	<!-- ============================================================== -->
	<!-- = FUNCTION CALLED WHEN BUTTON TO GET NEXT PAGE OF THUMBNAILS = -->
	<!-- ============================================================== -->
	public function nextButtonHandler():void
	{
	
	//IF NOT ON THE FIRST 10 PAGES
	if(rp.startingIndex > 1){
		var lastPageNum:int = ((parentDocument.currentPage - rp.startingIndex)-1);
		var selectedPageNum:int = parentDocument.currentPage - rp.startingIndex;
		if(lastPageNum > -1)
		{
		pageNumber_lbl[lastPageNum].setStyle('textDecoration','none');
		}
		pageNumber_lbl[selectedPageNum].setStyle('textDecoration','underline');
		
	}
	//IF FIRST 10 PAGES
	else
	{
		pageNumber_lbl[parentDocument.currentPage - 1].setStyle('textDecoration','none');
		pageNumber_lbl[parentDocument.currentPage].setStyle('textDecoration','underline');
	
	}
	
	 
	

	parentDocument.getNextPage(this);
	}


	<!-- ============================================================== -->
	<!-- = FUNCTION CALLED WHEN BUTTON TO GET PREVIOUS PAGE OF THUMBNAILS = -->
	<!-- ============================================================== -->
	public function previousButtonHandler():void
	{
	
	//IF NOT ON THE FIRST 10 PAGES
	if(rp.startingIndex > 1){
		var lastPageNum:int = (parentDocument.currentPage - rp.startingIndex) ;
		var selectedPageNum:int = ((parentDocument.currentPage - rp.startingIndex) -1);
		if(lastPageNum > -1 && pageNumber_lbl[lastPageNum])
		{
			pageNumber_lbl[lastPageNum].setStyle('textDecoration','none');
		}
		if(pageNumber_lbl[selectedPageNum])
		{
			pageNumber_lbl[selectedPageNum].setStyle('textDecoration','underline');
		}
		
		}
	//IF FIRST 10 PAGES
	else
	{
		pageNumber_lbl[parentDocument.currentPage -1].setStyle('textDecoration','none');
		pageNumber_lbl[parentDocument.currentPage - 2].setStyle('textDecoration','underline');		
	
	}

	parentDocument.getPreviousPage(this)
	}
	
	
	<!-- ================================================= -->
	<!-- = FUNCTION CALLED WHEN A PAGE NUMBER IS CLICKED = -->
	<!-- ================================================= -->
	public function pageNumberHandler():void
	{
		//IF NOT ON THE FIRST 10 PAGES
		if(rp.startingIndex > 1)
		{
			var lastPageNum:int = ((parentDocument.currentPage - rp.startingIndex));
			if(lastPageNum > -1)
			{
				pageNumber_lbl[lastPageNum].setStyle('textDecoration','none');
			}
		}
		else
		{
			pageNumber_lbl[parentDocument.currentPage - 1].setStyle('textDecoration','none');
		}
		
	}
