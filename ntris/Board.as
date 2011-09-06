package ntris
{
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import ntris.Color;
	import ntris.Constants;
	import ntris.Input;
	import ntris.BlockLoader;
	
	public class Board extends Sprite
	{
		private const PLAYING:int = 0;
		private const PAUSED:int = 1;
		private const GAMEOVER:int = 2;
		
		private var curBlock:Block;
		private var curBlockType:int;
		private var heldBlockType:int;
		private var boardBlocks:Array = new Array();
		private var blocksInRow:Array = new Array();
		private var boardState:int = PLAYING;
		private var preview:Array = new Array();
		private var previewOffset:int = 0;
		private var isKeyExecuted:Array = new Array(Input.NUM_KEYS);
		private var previewAnim:int;
		private var holdUsed:Boolean;
		private var boardChanged:Boolean = false;
		private var $blockData:Array;
		private var score:int = 0;
		private var combo:int = 0;
		
		private const OK:int = 0;
		private const TOPEDGE:int = 1;
		private const RIGHTEDGE:int = 2;
		private const BOTTOMEDGE:int = 3;
		private const LEFTEDGE:int = 4;
		private const OVERLAP:int = 5;
		
		private const MAXSHOVEAWAYS:int = 2;
		
		private const PREVIEW : int = 5;
		private const PREVIEWANIMFRAMES : int = 3;
		private const isMultiplayer:Boolean;
		
		public function Board($refBlockData:Array)
		{
			$blockData = $refBlockData;
			for (var i:int = 0; i < Constants.NUMCOLS; i++)
			{
				boardBlocks[i] = new Array();
				for (var j:int = 0; j < Constants.NUMROWS;  j++)
				{
					if ( i == 0 )
					{
						blocksInRow[i] = 0;
					}
					boardBlocks[i][j] = -1;
				}
			}
		}
		
		public function timeStep(inputs:Array):void
		{
			var firedKeys:Array = inputs[0];
			var releasedKeys:Array = inputs[1];
			
			if (firedKeys.indexOf(Input.START) != -1 && !isKeyExecuted[Input.START])
			{
				if (boardState == GAMEOVER)
				{
					resetBoard();
				}
				else if (boardState == PLAYING)
				{
					boardState = PAUSED;
					return;
				}
				else if (boardState == PAUSED)
				{
					boardState = PLAYING;
				}
				isKeyExecuted[Input.START] = true;
			}
			
			if (boardState == PLAYING)
			{
				var trans:Point = new Point(0, 0);
				var deltaAngle:int = 0;
				
				for (var i:int = 0; i < firedKeys.length; i++)
				{
					var key = firedKeys[i];
					if (key == Input.MOVE_LEFT || key == Input.MOVE_RIGHT)
					{
						trans.x += (key == Input.MOVE_LEFT) ? -1 : 1;
					}
					else if ((key == Input.ROTATE_LEFT || key == Input.ROTATE_RIGHT) && !isKeyExecuted[key])
					{
						deltaAngle += (key == Input.ROTATE_LEFT) ? 3 : 1;
						isKeyExecuted[key] = true;
					}
					else if (key == Input.HARD_DROP && !isKeyExecuted[key])
					{
						curBlock.y += curBlock.rowsDropped;
						placeBlock(curBlock);
						getNextBlock();
						isKeyExecuted[key] = true;
						return;
					}
					else if (key == Input.SOFT_DROP)
					{
						trans.y += 1;
					}
					else if (key == Input.HOLD && !isKeyExecuted[key])
					{
						getNextBlock(true);
						isKeyExecuted[key] = true;
						return;
					}
				}
				for ( var j : int = 0; j < releasedKeys.length; j++ )
				{
					isKeyExecuted[releasedKeys[j]] = false;
					trace ( releasedKeys );
				}
				//moveBlock(curBlock, trans, deltaAngle);
			}
		}
		
		private function resetBoard():void
		{
			for (var i:int = 0; i < Input.NUM_KEYS; i++)
			{
				isKeyExecuted[i] = false;
			}
			
			// Clear the board
			for (var y:int = 0; y < Constants.NUMROWS; y++)
			{
				for (var x:int = 0; x < Constants.NUMCOLS; x++)
				{
					boardBlocks[x][y] = -1;
				}
				blocksInRow[y] = 0;
			}
			boardChanged = true;
			
			// Reset the preview, held blocks and current block
			preview = new Array();
			previewAnim = 0;
			previewOffset = 0;
			heldBlockType = -1;
			curBlockType = -1;
			curBlock = null;
			
			score = 0;
			combo = 0;
			boardState = PLAYING;
		}
		
		private function shoveaway(block:Block):Boolean
		{
			var dir:int;
			
			// attempt to rotate the block and possibly translate it
			for (var i:int = 0; i < 3; i++)
			{
				// the block can be shifted up to 2 units up in a shoveaway
				if (checkBlock(block) == OK)
				{
					return true;
				}
				else
				{
					// the block can also be shifted 1 unit left or right
					// to avoid giving preference to either direction, we decide randomly which one
					// to try first
					dir = 1 - 2 * (1); // the 2*(1) should be a 2*(rand()%2)
					block.x += dir;
					// if either direction works, we return the shoveaway
					if (checkBlock(block) == OK)
					{
						return true;
					}
					block.x -= 2 * dir;
					if (checkBlock(block) == OK)
					{
						return true;
					}
					// otherwise, move back to center and shift up again
					block.x += dir;
					block.y--;
				}
			}
			// at the end of the loop, the block has been moved up 3 squares - move it back down
			// no safe position was found, so the shoveaway fails
			block.y += 3;
			return false;
		}
		
		private function moveBlock(block:Block, trans:Point, deltaAngle:int):void
		{
			var moved:Boolean;
			if (trans.x != 0)
			{
				// try to move the block right or left, if it is legal
				curBlock.x += trans.x;
				if (checkBlock(curBlock) != OK)
				{
					// the left and right movement is obstructed - move back
					curBlock.x -= trans.x;
				}
				else
				{
					// record the fact that this block moved
					moved = true;
				}
			}
			
			if (deltaAngle != 0)
			{
				// try to rotate, if needed
				curBlock.angle += deltaAngle;
				// move left or right to make room to rotate
				// trans.x will record how far we move
				trans.x = 0;
				while ((checkBlock(curBlock) % OVERLAP == LEFTEDGE) || (checkBlock(curBlock) % OVERLAP == RIGHTEDGE))
				{
					if (checkBlock(curBlock) % OVERLAP == LEFTEDGE)
					{
						// rotated off the left edge - move right to compensate
						curBlock.x++;
						trans.x++;
					}
					else
					{
						// same on the right edge
						curBlock.x--;
						trans.x--;
					}
				}
				// now the block has been rotated away from the edge
				var check:int = checkBlock(curBlock);
				if ((check != OK) && (check % OVERLAP != TOPEDGE))
				{
					// try to shoveaway from the obstruction, if we have shoveaways left
					if ((curBlock.shoveaways >= MAXSHOVEAWAYS) || !shoveaway(curBlock))
					{
						curBlock.angle -= deltaAngle;
						curBlock.x -= trans.x;
					}
					else
					{
						// we've burned a shoveaway on this block
						curBlock.shoveaways++;
						moved = true;
					}
				}
				else if (check % OVERLAP == TOPEDGE)
				{
					// above the screen - try to move down after rotation
					var deltaY:int = 1;
					curBlock.y++;
					while (checkBlock(curBlock) % OVERLAP == TOPEDGE)
					{
						deltaY++;
						curBlock.y++;
					}
					// now check if the block is in a free position
					if (checkBlock(curBlock) == OK)
					{
						moved = true;
					}
					else
					{
						// revert to the original angle and x position
						curBlock.angle -= deltaAngle;
						curBlock.x -= trans.x;
						curBlock.y -= deltaY;
					}
				}
				else
				{
					// record the fact that this block rotated
					moved = true;
				}
				// if the block moved at all, its local sticking frames are reset
				// also, recalculate the number of squares this block can drop
				if (moved)
				{
					curBlock.localStickFrames = Constants.MAXLOCALSTICKFRAMES;
					curBlock.rowsDropped = calculateRowsDropped(curBlock);
				}
				
				if (curBlock.rowsDropped <= 0)
				{
					// block cannot drop - start to stick
					curBlock.globalStickFrames--;
					if (!moved)
					{
						curBlock.localStickFrames--;
					}
				}
				else
				{
					// the obstacle is no longer there - reset stick frames, and move down if required
					curBlock.globalStickFrames = Constants.MAXGLOBALSTICKFRAMES;
					curBlock.localStickFrames = Constants.MAXLOCALSTICKFRAMES;
					curBlock.y += trans.y;
					curBlock.rowsDropped -= trans.y;
				}
				
				// if the block has no stick frames left, place it down
				if ((curBlock.globalStickFrames <= 0) || (curBlock.localStickFrames <= 0))
				{
					placeBlock(curBlock);
					curBlock = null;
				}
			}
		}
		
		public function draw():void
		{
			drawBase();
			drawBoardState();
			//drawBlock(curBlock, false);
			//drawBlock(curBlockShadow, true);
			//drawGUI();
			boardChanged = false;
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
		
		private function getNextBlock(swap:Boolean = false):void
		{
			var blockType:int;
			
			if ((!swap) || (heldBlockType == -1))
			{
				// get the first element from the preview list - it is the new block
				blockType = preview[0];
				preview.shift();
				
				if (swap)
				{
					heldBlockType = curBlockType;
				}
				// make the preview scroll to the next block
				previewAnim = PREVIEWANIMFRAMES;
				previewOffset = ($blockData[blockType].height + 1) * Constants.SQUAREWIDTH / 2;
			}
			else
			{
				// user swapped out block - do not change the preview list
				blockType = heldBlockType;
				// hold the current block
				heldBlockType = curBlockType;
			}
			
			// record the new block type
			curBlockType = blockType;
			
			curBlock = new Block();
			curBlock.x = $blockData[blockType].x;
			curBlock.y = $blockData[blockType].y - $blockData[blockType].height + Constants.MAXBLOCKSIZE;
			curBlock.height = $blockData[blockType].height;
			curBlock.numSquares = $blockData[blockType].numSquares;
			for (var i = 0; i < curBlock.numSquares; i++)
			{
				curBlock.squares[i].x = $blockData[blockType].squares[i].x;
				curBlock.squares[i].y = $blockData[blockType].squares[i].y;
			}
			curBlock.color = $blockData[blockType].color;
			curBlock.rotates = $blockData[blockType].rotates;
			
			curBlock.rowsDropped = calculateRowsDropped(curBlock);
			if (curBlock.rowsDropped < 0)
			{
				boardState = GAMEOVER;
			}
			
			holdUsed = swap;
		}
		
		private function placeBlock(block:Block):void
		{
			var point:Point = new Point();
			
			if (block == null)
			{
				return;
			}
			
			for (var i:int = 0; i < block.numSquares; i++)
			{
				// change square coordinates, from local coordinates into global
				if (block.angle % 2 == 0)
				{
					// the block is rotated either 0 or 180 degrees
					point.x = block.x + block.squares[i].x * (1 - (block.angle % 4));
					point.y = block.y + block.squares[i].y * (1 - (block.angle % 4));
				}
				else
				{
					// the block is rotated either 90 or 270 degrees
					point.x = block.x + block.squares[i].y * ((block.angle % 4) - 2);
					point.y = block.y + block.squares[i].x * (2 - (block.angle % 4));
				}
				boardBlocks[point.x][point.y] = block.color;
				blocksInRow[point.y]++;
				boardChanged = true;
			}
			
			// check if any rows have to be removed
			removeRows();
		}
		
		function checkBlock(block:Block)
		{
			var point:Point = new Point();
			var illegality:int = 0;
			var overlapsFound:int = 0;
			
			// run through each square to see if the block is in a legal position
			for (var i:int = 0; i < block.numSquares; i++)
			{
				// change square coordinates, from local coordinates into global
				if (block.angle % 2 == 0)
				{
					// the block is rotated either 0 or 180 degrees
					point.x = block.x + block.squares[i].x * (1 - (block.angle % 4));
					point.y = block.y + block.squares[i].y * (1 - (block.angle % 4));
				}
				else
				{
					// the block is rotated either 90 or 270 degrees
					point.x = block.x + block.squares[i].y * ((block.angle % 4) - 2);
					point.y = block.y + block.squares[i].x * (2 - (block.angle % 4));
				}
				
				if (point.y < 0)
				{
					// the highest priority errors are being off the top or bottom edge
					if (illegality == 0)
					{
						illegality = TOPEDGE;
					}
				}
				else if (point.y >= Constants.NUMROWS)
				{
					// bottom edge - this can cause the block to stick
					if (illegality == 0)
					{
						illegality = BOTTOMEDGE;
					}
				}
				else if (point.x < 0)
				{
					// block is off the left edge of the board
					if (illegality == 0)
					{
						illegality = LEFTEDGE;
					}
				}
				else if (point.x >= Constants.NUMCOLS)
				{
					if (illegality == 0)
					{
						illegality = RIGHTEDGE;
					}
				}
				else if (boardBlocks[point.x][point.y] != -1)
				{
					// keep track of the number of overlaps with blocks already placed
					overlapsFound++;
				}
			}
			
			// the flag returned contains all the information found
			// flag%OVERLAP gives any edges the block strayed over
			// flag/OVERLAP gives the number of overlaps
			// if flag == OK (OK = 0) then the position is legal
			return illegality + OVERLAP * overlapsFound;
		}
		
		function calculateRowsDropped(block:Block):int
		{
			for (var i:int = 0; i < Constants.NUMROWS + 1; i++)
			{
				// check if the block is in a legal position
				if (checkBlock(block) == OK)
				{
					// still legal - move the block down 1 unit
					block.y++;
				}
				else
				{
					// the block is in illegal position - move it back, and
					// return the number of squares it can move down legally
					block.y -= i;
					return i - 1;
				}
			}
			return Constants.NUMROWS;
		}
		
		function removeRows():int
		{
			var downShift:int = 0;
			
			for (var y:int = Constants.NUMROWS - 1; y >= 0; y--)
			{
				if (blocksInRow[y] == Constants.NUMCOLS)
				{
					// downShift keeps track of the number of cleared rows up to this point
					downShift++;
				}
				else if (downShift > 0)
				{
					// down shift this row by downShift rows
					for (var x = 0; x < Constants.NUMCOLS; x++)
					{
						boardBlocks[x][y + downShift] = boardBlocks[x][y];
						blocksInRow[y + downShift] = blocksInRow[y];
						boardBlocks[x][y] = -1;
						blocksInRow[y] = 0;
					}
				}
			}
			// if any rows were removed, add empty space to the top of the board
			if (downShift > 0)
			{
				score += ((1 << downShift) - 1);
				combo++;
			}
			else
			{
				combo = 0;
			}
			
			return downShift;
		}
		
		private function drawBoardState():void
		{
			for (var i:int = 0; i < Constants.NUMCOLS; i++)
			{
				for (var j:int = Constants.MAXBLOCKSIZE - 1; j < Constants.NUMROWS; j++)
				{
					if (boardBlocks[i][j] != -1)
					{
						drawSquare(i, j, boardBlocks[i][j]);
						trace ( i, j );
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