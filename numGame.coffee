noOfItems = 6
htmlHeight=""
Array::remove = (e) -> @[t..t] = [] if (t = @indexOf(e)) > -1

Array::pushUnique = (a,e) ->
  if e not in a
    a.push(e)
	
class Box
	constructor: (@x,@y,@w,@h,@colour,@data) ->
		@active = false
		
	contains:(mx,my) ->
		@x <= mx <= (@x + @w) and @y <= my <= (@y  + @h)
	
class Cell extends Box
	@Dcell
	draw:(ctx) ->
		ctx.fillStyle = @colour
		ctx.fillRect(@x, @y, @w, @h)
		ctx.lineWidth = 3
		ctx.strokeStyle = 'green'
		ctx.strokeRect(@x,@y,@w,@h);
		
class Dcell extends Box
	draw:(ctx) ->
		ctx.fillStyle = @colour
		ctx.fillRect(@x, @y, @w, @h)
		ctx.font = "20pt Calibri";
		ctx.fillStyle = 'white'
		ctx.fillText(@data, @x + @w / 4 , @y + 35)
		
class CanvasState 
	constructor: (@canvas) ->
		@width = canvas.width
		@height = canvas.height
		@ctx = canvas.getContext('2d')
		myState = this
		@Cells = []
		@Dcells = []
		@playAgainBox = new Box @width - 120, 10, 100, 30, "green", "Play Again"
		@resetBox = new Box @width - 220, 10, 70, 30, "green", "Reset"
		@sortBox = new Box @width - 400, 10, 120, 30, "Red", "Acending"
		@stylePaddingLeft
		@stylePaddingTop
		@styleBorderLeft
		@styleBorderTop
		myState.dragging = false
		myState.sort = "Acending"
		
		if (document.defaultView && document.defaultView.getComputedStyle) 
			@stylePaddingLeft = parseInt(document.defaultView.getComputedStyle(canvas, null)['paddingLeft'], 10)      || 0;
			@stylePaddingTop  = parseInt(document.defaultView.getComputedStyle(canvas, null)['paddingTop'], 10)       || 0;
			@styleBorderLeft  = parseInt(document.defaultView.getComputedStyle(canvas, null)['borderLeftWidth'], 10)  || 0;
			@styleBorderTop   = parseInt(document.defaultView.getComputedStyle(canvas, null)['borderTopWidth'], 10)   || 0;
		
		@complete = "false"
		@tryAgain = "false"
		@selectionColor = '#CC0000'
		@selectionWidth = 2;  
		@interval  = 30
		setInterval(
			->
				myState.draw()
		,myState.interval)
	
		canvas.addEventListener('mousedown',
		(e)->
			myState.pressAction(myState,e,"mouse")
		, true)
		
		canvas.addEventListener('mousemove',
		(e)->
			myState.moveAction(myState,e,"mouse")
		, true)
		
		canvas.addEventListener('mouseup',
		(e)->
			myState.releaseAction(myState,e,"mouse")
		, true)
		
		canvas.addEventListener('mouseout',
		(e)->
			myState.releaseAction(myState,e,"mouse")
		, true)
		
		canvas.addEventListener('touchstart',
		(e)->
 			myState.pressAction(myState,e,"touch")	
		, true)
		
		canvas.addEventListener('touchmove',
		(e)->
			myState.moveAction(myState,e,"touch")
		, true)
		
		canvas.addEventListener('touchend',
		(e)->
			myState.releaseAction(myState,e,"touch")
		, true)
		
		canvas.addEventListener('touchcancel',
		(e)->
			myState.releaseAction(myState,e,"touch")
		, true)

	pressAction:(myState,e,moveBy) ->
		mouse = if(moveBy == "mouse")
					myState.getMouse(e)
				else
					myState.getTouch(e)
		mx = mouse.x
		my = mouse.y
		dcells = myState.Dcells
		for i in [dcells.length-1 .. 0] by -1
			dcell = dcells[i]
			if(dcell.contains(mx,my))
				myState.tryAgain = "false"
				seletedBox = dcell
				dcells.remove(dcell)
				dcells.push(dcell)
				myState.dragoffx = mx - seletedBox.x;
				myState.dragoffy = my - seletedBox.y;
				myState.dragging = true;
				myState.selection = seletedBox;
				myState.valid = false;
				
				return;
		
		if myState.selection 
			myState.selection = null;
			myState.valid = false;
		
	moveAction:(myState,e,moveBy) ->
		if myState.dragging
			mouse =if(moveBy == "mouse")
						myState.getMouse(e)
					else
						myState.getTouch(e)
			myState.selection.x = mouse.x - myState.dragoffx;
			myState.selection.y = mouse.y - myState.dragoffy;   
			myState.valid = false;
		
	releaseAction:(myState,e,moveBy) ->
		myState.dragging = false
		mouse = if(moveBy == "mouse")
					myState.getMouse(e)
				else
					myState.getTouch(e)
		mx = mouse.x
		my = mouse.y
		if (myState.playAgainBox.contains(mx,my))
			return myState.reloadGame()
		if (myState.resetBox.contains(mx,my))
			return myState.resetGame()
		if (myState.sortBox.contains(mx,my))
			return myState.changeSortOrder(myState)
			
		flag = true
		dcells = myState.Dcells
		cells = myState.Cells
		
		for i in [cells.length-1 .. 0] by -1
			flag = true
			cell = cells[i]
			for j in [0 .. dcells.length-1]
				dcell = dcells[j]
				
				if (myState.checkifIn(cell,dcell)) 
					if(cell.Dcell)
						cell.Dcell.y = cell.Dcell.y - 70	
					dcell.x = cell.x + 5
					dcell.y = cell.y + 5
					myState.Cells[i].Dcell = dcell
					flag = false
			 
			if(flag and cell.Dcell)
				myState.Cells[i].Dcell = "";
		myState.checkAscending(myState.Cells,myState)
			
	clear:() ->
		@ctx.clearRect(0, 0, @width, @height)
		return
	
	addCell:(Cell) ->
		@Cells.push(Cell)
		@valid = false
		return
		
	addDCell:(Dcell) ->
		@Dcells.push(Dcell)
		@valid = false
		return
	
	draw:() ->
		ctx = @ctx
		@clear()
		gradient1 = ctx.createLinearGradient(0, 0, 0, 300);
		gradient1.addColorStop(0, "#00ABEB");
		gradient1.addColorStop(1, "white");
		ctx.fillStyle = gradient1;
		ctx.fillRect(0, 0, @width, @height)
		
		ctx.fillStyle = @playAgainBox.colour
		ctx.fillRect(@playAgainBox.x,@playAgainBox.y,@playAgainBox.w,@playAgainBox.h)
		ctx.font = "15pt Calibri";
		ctx.fillStyle = 'white'
		ctx.fillText(@playAgainBox.data,@playAgainBox.x + 10, @playAgainBox.h)
		
		if(@complete == "false")
			ctx.fillStyle = @resetBox.colour
			ctx.fillRect(@resetBox.x,@resetBox.y,@resetBox.w,@resetBox.h)
			ctx.font = "15pt Calibri";
			ctx.fillStyle = 'white'
			ctx.fillText(@resetBox.data,@resetBox.x + 10, @resetBox.h)
			
		ctx.fillStyle = @sortBox.colour
		ctx.fillRect(@sortBox.x,@sortBox.y,@sortBox.w,@sortBox.h)
		ctx.font = "15pt Calibri";
		ctx.fillStyle = 'white'
		ctx.fillText(@sortBox.data,@sortBox.x + 10, @sortBox.h)
		
		if(@complete == "true")
			for cell in @Cells
				if ((cell.x - 1 + @width) > @canvas.offsetLeft) 
					cell.x  = 	cell.x - 1 
					cell.Dcell.x = cell.Dcell.x - 1	
				cell.draw(ctx)
				cell.Dcell.draw(ctx)
				
				ctx.fillStyle = "yellow"
				ctx.font = "25pt Calibri";
				ctx.fillText("Congrats you won !!", 20, 130)
		else
			for cell in @Cells
				cell.draw(ctx)
			for dcell in @Dcells
				dcell.draw(ctx)
			if(@selection)
				ctx.strokeStyle = this.selectionColor;
				ctx.lineWidth = this.selectionWidth;
				mySel = @selection;
				ctx.strokeRect(mySel.x,mySel.y,mySel.w,mySel.h);
				
		if (@tryAgain == "true")
			ctx.fillStyle = "yellow"
			ctx.font = "25pt Calibri";
			ctx.fillText("Wrong Try Again", 20, 130)

	getMouse: (e) ->
		element = @canvas 
		offsetX = 0
		offsetY = 0
		if (element.offsetParent != undefined) 
			loop
				offsetX += element.offsetLeft;
				offsetY += element.offsetTop;
				break if((element = element.offsetParent));

		offsetX += this.stylePaddingLeft + this.styleBorderLeft;
		offsetY += this.stylePaddingTop + this.styleBorderTop;

		mx = e.pageX - offsetX;
		my = e.pageY - offsetY;
		return {x: mx, y: my};
		
	getTouch: (e) ->
		e.preventDefault()
		element = @canvas 
		offsetX = 0
		offsetY = 0
		if (element.offsetParent != undefined) 
			loop
				offsetX += element.offsetLeft;
				offsetY += element.offsetTop;
				break if((element = element.offsetParent));

		offsetX += this.stylePaddingLeft + this.styleBorderLeft;
		offsetY += this.stylePaddingTop + this.styleBorderTop;
		
		mx = e.targetTouches[0].pageX - offsetX;
		my = e.targetTouches[0].pageY - offsetY;
		return {x: mx, y: my};
		
	
	checkifIn: (box1,box2) ->
		Math.abs(box1.x - box2.x) <= 30 and Math.abs(box1.y - box2.y) <=30
	
	getCellValues: (Cells) ->
		values = []
		for cell in Cells
			if(cell.Dcell != undefined and cell.Dcell != "")
				values.push cell.Dcell.data
				
		return values
	
	checkSort: (values,myState) ->
		isSorted = false
		for i in [0 .. values.length-2]
			if (myState.sort == "Acending" and parseInt(values[i]) < parseInt(values[i+1]))
				isSorted = true
			else if (myState.sort == "Decending" and parseInt(values[i]) > parseInt(values[i+1]))
				isSorted = true
			else
				isSorted = false
				break
		if(isSorted)
			@complete = "true"
		else
			@tryAgain = "true"
		return isSorted
	
	checkAscending: (Cells,myState) ->
		values = @getCellValues(Cells)
		if values.length == noOfItems
			return @checkSort(values,myState)
		return false
		
	changeSortOrder: (myState) ->
		@tryAgain = "false"
		if(myState.sort == "Acending")
			myState.sort = "Decending"
			myState.sortBox.data = "Decending"
			myState.checkAscending(myState.Cells,myState)
		else
			myState.sort = "Acending"
			myState.sortBox.data = "Acending"
			myState.checkAscending(myState.Cells,myState)

	resetGame: () ->
		@tryAgain = "false"
		if(@complete == "false")
			x = 20
			for i in [0..noOfItems - 1]
				@Cells[i].x = x
				@Cells[i].y = htmlHeight - 100
				@Dcells[i].x =  x 
				@Dcells[i].y = htmlHeight - 200
				@Cells.Dcell = ""
				x+=100
				
	reloadGame: () ->
		x = 20
		@complete = "false"
		@tryAgain = "false"
		randomNums = getRamdomNumbers(noOfItems)
		for i in [0..noOfItems - 1]
			@Cells[i].x = x
			@Cells[i].y = htmlHeight - 100
			@Dcells[i].x =  x 
			@Dcells[i].y = htmlHeight - 200
			@Dcells[i].data =  randomNums[i] 
			@Cells.Dcell = ""
			x+=100

getRamdomNumbers =(count) ->	
	randomNums = []
	index = 0
	flag = true

	while randomNums.length < count
		randomNum = Math.floor(Math.random() * 100)
		if(randomNum != 'undefined' and 0 < randomNum < 100)
			randomNums.push randomNum
			randomNums.pushUnique(randomNums,randomNum)
				
	return randomNums
	
init =() ->
	parent = document.getElementById('canvas1')
	htmlHeight = parent.offsetHeight
	
	randomNums = getRamdomNumbers(noOfItems)

	cs = new CanvasState document.getElementById('canvas1')

	x = 20
	for i in [0..noOfItems - 1]
		cs.addCell new Cell x, htmlHeight - 100,60,60,'grey'
		cs.addDCell new Dcell x , htmlHeight - 200,50,50,'brown', randomNums[i]
		x+=100
	return