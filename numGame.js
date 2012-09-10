// Generated by CoffeeScript 1.3.3
var Box, CanvasState, Cell, Dcell, getRamdomNumbers, htmlHeight, htmlLeft, htmlTop, htmlWidth, init, noOfItems, parent,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

noOfItems = 6;

parent = "";

htmlTop = "";

htmlLeft = "";

htmlWidth = "";

htmlHeight = "";

Array.prototype.remove = function(e) {
  var t, _ref;
  if ((t = this.indexOf(e)) > -1) {
    return ([].splice.apply(this, [t, t - t + 1].concat(_ref = [])), _ref);
  }
};

Array.prototype.unique = function() {
  var key, output, value, _i, _ref, _results;
  output = {};
  for (key = _i = 0, _ref = this.length; 0 <= _ref ? _i < _ref : _i > _ref; key = 0 <= _ref ? ++_i : --_i) {
    output[this[key]] = this[key];
  }
  _results = [];
  for (key in output) {
    value = output[key];
    _results.push(value);
  }
  return _results;
};

Box = (function() {

  function Box(x, y, w, h, colour, data) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.colour = colour;
    this.data = data;
    this.active = false;
  }

  Box.prototype.contains = function(mx, my) {
    return (this.x <= mx && mx <= (this.x + this.w)) && (this.y <= my && my <= (this.y + this.h));
  };

  return Box;

})();

Cell = (function(_super) {

  __extends(Cell, _super);

  function Cell() {
    return Cell.__super__.constructor.apply(this, arguments);
  }

  Cell.Dcell;

  Cell.prototype.draw = function(ctx) {
    ctx.fillStyle = this.colour;
    ctx.fillRect(this.x, this.y, this.w, this.h);
    ctx.lineWidth = 3;
    ctx.strokeStyle = 'green';
    return ctx.strokeRect(this.x, this.y, this.w, this.h);
  };

  return Cell;

})(Box);

Dcell = (function(_super) {

  __extends(Dcell, _super);

  function Dcell() {
    return Dcell.__super__.constructor.apply(this, arguments);
  }

  Dcell.prototype.draw = function(ctx) {
    ctx.fillStyle = this.colour;
    ctx.fillRect(this.x, this.y, this.w, this.h);
    ctx.font = "20pt Calibri";
    ctx.fillStyle = 'white';
    return ctx.fillText(this.data, this.x + this.w / 4, this.y + this.h / 2);
  };

  return Dcell;

})(Box);

CanvasState = (function() {

  function CanvasState(canvas) {
    var myState;
    this.canvas = canvas;
    this.width = canvas.width;
    this.height = canvas.height;
    this.ctx = canvas.getContext('2d');
    myState = this;
    this.Cells = [];
    this.Dcells = [];
    this.playAgainBox = new Box(this.width - 120, 10, 100, 30, "green", "Play Again");
    this.resetBox = new Box(this.width - 250, 10, 70, 30, "green", "Reset");
    this.stylePaddingLeft;
    this.stylePaddingTop;
    this.styleBorderLeft;
    this.styleBorderTop;
    if (document.defaultView && document.defaultView.getComputedStyle) {
      this.stylePaddingLeft = parseInt(document.defaultView.getComputedStyle(canvas, null)['paddingLeft'], 10) || 0;
      this.stylePaddingTop = parseInt(document.defaultView.getComputedStyle(canvas, null)['paddingTop'], 10) || 0;
      this.styleBorderLeft = parseInt(document.defaultView.getComputedStyle(canvas, null)['borderLeftWidth'], 10) || 0;
      this.styleBorderTop = parseInt(document.defaultView.getComputedStyle(canvas, null)['borderTopWidth'], 10) || 0;
    }
    this.complete = "false";
    this.selectionColor = '#CC0000';
    this.selectionWidth = 2;
    this.interval = 30;
    setInterval(function() {
      return myState.draw();
    }, myState.interval);
    canvas.addEventListener('mousedown', function(e) {
      var dcell, dcells, i, mouse, mx, my, seletedBox, _i, _ref;
      mouse = myState.getMouse(e);
      mx = mouse.x;
      my = mouse.y;
      dcells = myState.Dcells;
      for (i = _i = _ref = dcells.length - 1; _i >= 0; i = _i += -1) {
        dcell = dcells[i];
        if (dcell.contains(mx, my)) {
          seletedBox = dcell;
          dcells.remove(dcell);
          dcells.push(dcell);
          myState.dragoffx = mx - seletedBox.x;
          myState.dragoffy = my - seletedBox.y;
          myState.dragging = true;
          myState.selection = seletedBox;
          myState.valid = false;
          return;
        }
      }
      if (myState.selection) {
        myState.selection = null;
        return myState.valid = false;
      }
    }, true);
    canvas.addEventListener('mousemove', function(e) {
      var mouse;
      if (myState.dragging) {
        mouse = myState.getMouse(e);
        myState.selection.x = mouse.x - myState.dragoffx;
        myState.selection.y = mouse.y - myState.dragoffy;
        return myState.valid = false;
      }
    }, true);
    canvas.addEventListener('mouseup', function(e) {
      var cell, cells, dcell, dcells, flag, i, j, mouse, mx, my, _i, _j, _ref, _ref1;
      myState.dragging = false;
      mouse = myState.getMouse(e);
      mx = mouse.x;
      my = mouse.y;
      if (myState.playAgainBox.contains(mx, my)) {
        return myState.reloadGame();
      }
      if (myState.resetBox.contains(mx, my)) {
        return myState.resetGame();
      }
      flag = true;
      dcells = myState.Dcells;
      cells = myState.Cells;
      for (i = _i = _ref = cells.length - 1; _i >= 0; i = _i += -1) {
        flag = true;
        cell = cells[i];
        for (j = _j = 0, _ref1 = dcells.length - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; j = 0 <= _ref1 ? ++_j : --_j) {
          dcell = dcells[j];
          if (myState.checkifIn(cell, dcell)) {
            if (cell.Dcell) {
              cell.Dcell.y = cell.Dcell.y - 70;
            }
            dcell.x = cell.x + 5;
            dcell.y = cell.y + 5;
            myState.Cells[i].Dcell = dcell;
            flag = false;
          }
        }
        if (flag && cell.Dcell) {
          myState.Cells[i].Dcell = "";
        }
      }
      return myState.checkAscending(myState.Cells);
    }, true);
  }

  CanvasState.prototype.clear = function() {
    this.ctx.clearRect(0, 0, this.width, this.height);
  };

  CanvasState.prototype.addCell = function(Cell) {
    this.Cells.push(Cell);
    this.valid = false;
  };

  CanvasState.prototype.addDCell = function(Dcell) {
    this.Dcells.push(Dcell);
    this.valid = false;
  };

  CanvasState.prototype.draw = function() {
    var cell, ctx, dcell, gradient1, mySel, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2, _results;
    ctx = this.ctx;
    this.clear();
    gradient1 = ctx.createLinearGradient(0, 0, 0, 300);
    gradient1.addColorStop(0, "#00ABEB");
    gradient1.addColorStop(1, "white");
    ctx.fillStyle = gradient1;
    ctx.fillRect(0, 0, this.width, this.height);
    ctx.fillStyle = this.playAgainBox.colour;
    ctx.fillRect(this.playAgainBox.x, this.playAgainBox.y, this.playAgainBox.w, this.playAgainBox.h);
    ctx.font = "15pt Calibri";
    ctx.fillStyle = 'white';
    ctx.fillText(this.playAgainBox.data, this.playAgainBox.x + 10, this.playAgainBox.h);
    if (this.complete === "false") {
      ctx.fillStyle = this.resetBox.colour;
      ctx.fillRect(this.resetBox.x, this.resetBox.y, this.resetBox.w, this.resetBox.h);
      ctx.font = "15pt Calibri";
      ctx.fillStyle = 'white';
      ctx.fillText(this.resetBox.data, this.resetBox.x + 10, this.resetBox.h);
    }
    if (this.complete === "true") {
      _ref = this.Cells;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        cell = _ref[_i];
        if ((cell.x - 1 + this.width) > 0) {
          cell.x = cell.x - 1;
          cell.Dcell.x = cell.Dcell.x - 1;
        }
        cell.draw(ctx);
        cell.Dcell.draw(ctx);
        ctx.fillStyle = "yellow";
        ctx.font = "25pt Calibri";
        _results.push(ctx.fillText("Congrats you won !!", 20, 130));
      }
      return _results;
    } else {
      _ref1 = this.Cells;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        cell = _ref1[_j];
        cell.draw(ctx);
      }
      _ref2 = this.Dcells;
      for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
        dcell = _ref2[_k];
        dcell.draw(ctx);
      }
      if (this.selection) {
        ctx.strokeStyle = this.selectionColor;
        ctx.lineWidth = this.selectionWidth;
        mySel = this.selection;
        return ctx.strokeRect(mySel.x, mySel.y, mySel.w, mySel.h);
      }
    }
  };

  CanvasState.prototype.getMouse = function(e) {
    var element, mx, my, offsetX, offsetY;
    element = this.canvas;
    offsetX = 0;
    offsetY = 0;
    if (element.offsetParent !== void 0) {
      while (true) {
        offsetX += element.offsetLeft;
        offsetY += element.offsetTop;
        if ((element = element.offsetParent)) {
          break;
        }
      }
    }
    offsetX += this.stylePaddingLeft + this.styleBorderLeft;
    offsetY += this.stylePaddingTop + this.styleBorderTop;
    mx = e.pageX - offsetX;
    my = e.pageY - offsetY;
    return {
      x: mx,
      y: my
    };
  };

  CanvasState.prototype.checkifIn = function(box1, box2) {
    return Math.abs(box1.x - box2.x) <= 30 && Math.abs(box1.y - box2.y) <= 30;
  };

  CanvasState.prototype.getCellValues = function(Cells) {
    var cell, index, values, _i, _len;
    values = [];
    index = 0;
    for (_i = 0, _len = Cells.length; _i < _len; _i++) {
      cell = Cells[_i];
      if (cell.Dcell !== void 0 && cell.Dcell !== "") {
        values[index] = cell.Dcell.data;
        index++;
      }
    }
    return values;
  };

  CanvasState.prototype.checkSort = function(values) {
    var i, isSorted, _i, _ref;
    isSorted = false;
    for (i = _i = 0, _ref = values.length - 2; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
      if (parseInt(values[i]) < parseInt(values[i + 1])) {
        isSorted = true;
      } else {
        isSorted = false;
        break;
      }
    }
    if (isSorted) {
      this.complete = "true";
    } else {
      alert("Wrong. Try Again");
    }
    return isSorted;
  };

  CanvasState.prototype.checkAscending = function(Cells) {
    var values;
    values = this.getCellValues(Cells);
    if (values.length === noOfItems) {
      return this.checkSort(values);
    }
    return false;
  };

  CanvasState.prototype.resetGame = function() {
    var i, x, _i, _ref, _results;
    if (this.complete === "false") {
      x = 20;
      _results = [];
      for (i = _i = 0, _ref = noOfItems - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        this.Cells[i].x = x;
        this.Cells[i].y = htmlHeight - 100;
        this.Dcells[i].x = x;
        this.Dcells[i].y = htmlHeight - 200;
        this.Cells.Dcell = "";
        _results.push(x += 100);
      }
      return _results;
    }
  };

  CanvasState.prototype.reloadGame = function() {
    var i, randomNums, x, _i, _ref, _results;
    x = 20;
    this.complete = "false";
    randomNums = getRamdomNumbers(noOfItems);
    _results = [];
    for (i = _i = 0, _ref = noOfItems - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
      this.Cells[i].x = x;
      this.Cells[i].y = htmlHeight - 100;
      this.Dcells[i].x = x;
      this.Dcells[i].y = htmlHeight - 200;
      this.Dcells[i].data = randomNums[i];
      this.Cells.Dcell = "";
      _results.push(x += 100);
    }
    return _results;
  };

  return CanvasState;

})();

getRamdomNumbers = function(count) {
  var flag, index, randomNum, randomNums;
  randomNums = [];
  index = 0;
  flag = true;
  while (randomNums.length < count) {
    randomNum = Math.floor(Math.random() * 100);
    (0 <= randomNum && randomNum < 100);
    if (randomNum !== 'undefined') {
      randomNums[index] = randomNum;
      index++;
      randomNums.unique();
    }
  }
  return randomNums;
};

init = function() {
  var cs, i, randomNums, x, _i, _ref;
  parent = document.getElementById('canvas1');
  htmlTop = parent.offsetTop;
  htmlLeft = parent.offsetLeft;
  htmlWidth = parent.offsetWidth;
  htmlHeight = parent.offsetHeight;
  randomNums = getRamdomNumbers(noOfItems);
  cs = new CanvasState(document.getElementById('canvas1'));
  x = 20;
  for (i = _i = 0, _ref = noOfItems - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
    cs.addCell(new Cell(x, htmlHeight - 100, 60, 60, 'grey'));
    cs.addDCell(new Dcell(x, htmlHeight - 200, 50, 50, 'brown', randomNums[i]));
    x += 100;
  }
};
