noOfItems = 6

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
		@ctx.clearRect(0, 0, @width, @height);
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
		mx = e.pageX - offsetX;
		my = e.pageY - offsetY;
		return {x: mx, y: my};
		
	
	checkifIn: (box1,box2) ->
		Math.abs(box1.x - box2.x) <= 20 and Math.abs(box1.y - box2.y) <=20
	
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
		if(isSorted)
			alert "Correct"
		else
			alert "Wrong. Try Again"
		return isSorted
			
		
	checkAscending: (Cells) ->
		values = @getCellValues(Cells)
		if values.length == noOfItems
			return @checkSort(values)
		return false
			

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
	parent = document.body.parentNode
	htmlTop = parent.offsetTop
	htmlLeft = parent.offsetLeft
	htmlWidth = parent.offsetWidth
	htmlHeight = parent.offsetHeight
	
	randomNums = getRamdomNumbers(noOfItems)

	cs = new CanvasState document.getElementById('canvas1')
	x = 20
	for i in [0..noOfItems - 1]
		cs.addCell new Cell x,htmlTop + htmlHeight - 150,60,60,'grey'
		cs.addDCell new Dcell x ,htmlTop + htmlHeight - 250,50,50,'lightblue', randomNums[i]
		x+=100
	

	return