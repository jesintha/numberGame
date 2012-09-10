noOfItems = 6
parent = ""
htmlTop = ""
htmlLeft = ""
htmlWidth = ""
htmlHeight = ""

Array::remove = (e) -> @[t..t] = [] if (t = @indexOf(e)) > -1

Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  value for key, value of output


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
		ctx.fillText(@data, @x + @w / 4 , @y + @h / 2)
		
class CanvasState 
	constructor: (@canvas) ->
		@width = canvas.width
		@height = canvas.height
		@ctx = canvas.getContext('2d')
		myState = this
		@Cells = []
		@Dcells = []
		@playAgainBox = new Box @width - 120, 10, 100, 30, "green", "Play Again"
		@resetBox = new Box @width - 250, 10, 70, 30, "green", "Reset"
		@stylePaddingLeft
		@stylePaddingTop
		@styleBorderLeft
		@styleBorderTop
		
		if (document.defaultView && document.defaultView.getComputedStyle) 
			@stylePaddingLeft = parseInt(document.defaultView.getComputedStyle(canvas, null)['paddingLeft'], 10)      || 0;
			@stylePaddingTop  = parseInt(document.defaultView.getComputedStyle(canvas, null)['paddingTop'], 10)       || 0;
			@styleBorderLeft  = parseInt(document.defaultView.getComputedStyle(canvas, null)['borderLeftWidth'], 10)  || 0;
			@styleBorderTop   = parseInt(document.defaultView.getComputedStyle(canvas, null)['borderTopWidth'], 10)   || 0;
		
		@complete = "false"
		@selectionColor = '#CC0000';
		@selectionWidth = 2;  
		@interval  = 30
		setInterval(
			->
				myState.draw()
		,myState.interval)
		

		
		canvas.addEventListener('mousedown',
		(e)->
			mouse = myState.getMouse(e)
			mx = mouse.x
			my = mouse.y
			dcells = myState.Dcells
			for i in [dcells.length-1 .. 0] by -1
				dcell = dcells[i]
				if(dcell.contains(mx,my))
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
 					
		, true)
		
		canvas.addEventListener('mousemove',
		(e)->
			if myState.dragging
				mouse = myState.getMouse(e)
				myState.selection.x = mouse.x - myState.dragoffx;
				myState.selection.y = mouse.y - myState.dragoffy;   
				myState.valid = false;
		, true)
		
		canvas.addEventListener('mouseup',
		(e)->
			myState.dragging = false
			mouse = myState.getMouse(e)
			mx = mouse.x
			my = mouse.y
			if (myState.playAgainBox.contains(mx,my))
				return myState.reloadGame()
			if (myState.resetBox.contains(mx,my))
				return myState.resetGame()
				
			
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
			myState.checkAscending(myState.Cells)
					
					
		, true)
		
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
		
		ctx.fillStyle = @resetBox.colour
		ctx.fillRect(@resetBox.x,@resetBox.y,@resetBox.w,@resetBox.h)
		ctx.font = "15pt Calibri";
		ctx.fillStyle = 'white'
		
		ctx.fillText(@resetBox.data,@resetBox.x + 10, @resetBox.h)
		
		
		if(@complete == "true")
			for cell in @Cells
				if ((cell.x - 1 + @width) > 0) 
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
		
	
	checkifIn: (box1,box2) ->
		Math.abs(box1.x - box2.x) <= 30 and Math.abs(box1.y - box2.y) <=30
	
	getCellValues: (Cells) ->
		values = []
		index = 0
		for cell in Cells
			if(cell.Dcell != undefined and cell.Dcell != "")
				
				values[index] = cell.Dcell.data
				index++
		return values
	
	checkSort: (values) ->
		isSorted = false
		for i in [0 .. values.length-2]
			if (parseInt(values[i]) < parseInt(values[i+1]))
				isSorted = true
			else
				isSorted = false
				break
		if(isSorted)
			@complete = "true"
		else
			alert "Wrong. Try Again"
		return isSorted
			
		
	checkAscending: (Cells) ->
		values = @getCellValues(Cells)
		if values.length == noOfItems
			return @checkSort(values)
		return false
	
	resetGame: () ->
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
		0 <= randomNum < 100

		if(randomNum != 'undefined')
			randomNums[index] = randomNum
			index++
			randomNums.unique()
				
	return randomNums
	
init =() ->
	parent = document.getElementById('canvas1')
	htmlTop = parent.offsetTop
	htmlLeft = parent.offsetLeft
	htmlWidth = parent.offsetWidth
	htmlHeight = parent.offsetHeight
	
	randomNums = getRamdomNumbers(noOfItems)

	cs = new CanvasState document.getElementById('canvas1')
	x = 20
	for i in [0..noOfItems - 1]
		cs.addCell new Cell x, htmlHeight - 100,60,60,'grey'
		cs.addDCell new Dcell x , htmlHeight - 200,50,50,'brown', randomNums[i]
		x+=100
	

	return