package ntris
{
	import flash.display.Sprite;
	import flash.geom.Point;
	import ntris.Color;
	import ntris.Constants;
	
	public class Board extends Sprite
	{
		private var curBlock:Block;
		private var boardState:Array = new Array();
		
		public function Board()
		{
			for (var i:int = 0; i < Constants.BOARDWIDTH; i++)
			{
				boardState[i] = new Array();
				for (var j:int = 0; j < Constants.BOARDHEIGHT; j++)
				{
					boardState[i][j] = -1;
				}
			}
		}
		
		public function timeStep(inputs:Array)
		{
		}
		
		public function draw():void
		{
			drawBase();
			drawBoardState();
			//drawBlock(curBlock, false);
			//drawBlock(curBlockShadow, true);
			//drawGUI();
		}
		
		private function drawBase():void
		{
			graphics.clear();
			graphics.lineStyle();
			graphics.beginFill(Color.BLACK);
			graphics.drawRect(0, 0, Constants.BOARDWIDTH + 2 * Constants.BORDER, Constants.BOARDHEIGHT + 2 * Constants.BORDER);
			
			graphics.lineStyle(2, Color.colorCode(28));
			graphics.endFill();
			graphics.drawRect(Constants.BORDER / 2, Constants.BORDER / 2, Constants.BOARDWIDTH + Constants.BORDER, Constants.BOARDHEIGHT + Constants.BORDER);
			
			graphics.lineStyle(1, Color.mixedColor(Color.WHITE, Color.BLACK, Color.LAMBDA));
			var height:uint = Constants.SQUAREWIDTH * (Constants.NUMROWS - Constants.MAXBLOCKSIZE + 1);
			for (var i:int = 0; i < Constants.NUMCOLS; i++)
			{
				drawLineOffset(Constants.SQUAREWIDTH * i, 0, Constants.SQUAREWIDTH * i, height);
				drawLineOffset(Constants.SQUAREWIDTH * (i + 1) - 1, 0, Constants.SQUAREWIDTH * (i + 1) - 1, height);
			}
			var width:uint = Constants.SQUAREWIDTH * Constants.NUMCOLS;
			for (var j:int = 0; j < Constants.NUMROWS - Constants.MAXBLOCKSIZE + 1; j++)
			{
				drawLineOffset(0, Constants.SQUAREWIDTH * j, width, Constants.SQUAREWIDTH * j);
				drawLineOffset(0, Constants.SQUAREWIDTH * (j + 1) - 1, width, Constants.SQUAREWIDTH * (j + 1) - 1);
			}
		}
		
		private function drawBoardState():void
		{
			for (var i:int = 0; i < Constants.NUMCOLS; i++)
			{
				for (var j:int = Constants.MAXBLOCKSIZE - 1; j < Constants.NUMROWS; j++)
				{
					if (boardState[i][j] != -1)
					{
						drawSquare(i, j, boardState[i][j]);
					}
				}
			}
		}
		
		private function drawSquare(i:int, j:int, color:uint):void
		{
			var pos:Point = new Point(Constants.SQUAREWIDTH * i, Constants.SQUAREWIDTH * (j - Constants.MAXBLOCKSIZE + 1));
			graphics.lineStyle(1, Color.mixedColor(Color.WHITE, Color.RAINBOWCODE[color], Color.LAMBDA));
			graphics.beginFill(Color.RAINBOWCODE[color]);
			drawRectOffset(pos.x, pos.y, Constants.SQUAREWIDTH - 1, Constants.SQUAREWIDTH - 1);
		}
		
		private function drawLineOffset(x1:int, y1:int, x2:int, y2:int):void
		{
			graphics.moveTo(x1 + Constants.BORDER, y1 + Constants.BORDER);
			graphics.lineTo(x2 + Constants.BORDER, y2 + Constants.BORDER);
		}
		
		private function drawRectOffset(x:int, y:int, w:int, h:int):void
		{
			graphics.drawRect(x + Constants.BORDER, y + Constants.BORDER, w, h);
		}
	}
}