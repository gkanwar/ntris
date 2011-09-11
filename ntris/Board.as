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
		private var boardState:int;
		private var preview:Array = new Array();
		private var previewOffset:int;
		private var isKeyExecuted:Array = new Array(Input.NUM_KEYS);
		private var previewAnim:int;
		private var holdUsed:Boolean;
		private var boardChanged:Boolean = false;
		private var $blockData:Array;
		private var score:int;
		private var combo:int;
		private var frame:int;
		
		private const OK:int = 0;
		private const TOPEDGE:int = 1;
		private const RIGHTEDGE:int = 2;
		private const BOTTOMEDGE:int = 3;
		private const LEFTEDGE:int = 4;
		private const OVERLAP:int = 5;
		
		private const MAXSHOVEAWAYS:int = 2;
		
		private const PREVIEW:int = 5;
		private const PREVIEWANIMFRAMES:int = 3;
		private var numBlockTypes:Array;
		
		private var difficultyLevels:int;
		
		public function Board($refBlockData:Array, iDifficultyLevels:int, iNumBlockTypes:Array)
		{
			frame = 0;
			$blockData = $refBlockData;
			numBlockTypes = iNumBlockTypes;
			difficultyLevels = iDifficultyLevels;
			for (var i:int = 0; i < Constants.NUMCOLS; i++)
			{
				boardBlocks[i] = new Array();
				for (var j:int = 0; j < Constants.NUMROWS; j++)
				{
					blocksInRow[j] = 0;
					boardBlocks[i][j] = 0;
				}
			}
			resetBoard();
			
			//DEBUG
			curBlockType = 1001
			curBlock = new Block();
			curBlock.x = $blockData[curBlockType].x;
			curBlock.y = $blockData[curBlockType].y;
			curBlock.numSquares = $blockData[curBlockType].numSquares;
			for (var k:int = 0; k < curBlock.numSquares; k++)
			{
				curBlock.squares[k].x = $blockData[curBlockType].squares[k].x;
				curBlock.squares[k].y = $blockData[curBlockType].squares[k].y;
			}
			curBlock.color = $blockData[curBlockType].color;
			curBlock.rotates = $blockData[curBlockType].rotates;
			curBlock.height = $blockData[curBlockType].height;
			curBlock.rowsDropped = calculateRowsDropped(curBlock);
		}
		
		private function resetBoard():void
		{
			for (var i:int = 0; i < Input.NUM_KEYS; i++)
			{
				isKeyExecuted[i] = false;
			}
			
			for (var y:int = 0; y < Constants.NUMROWS; y++)
			{
				for (var x:int = 0; x < Constants.NUMCOLS; x++)
				{
					boardBlocks[x][y] = 0;
				}
				blocksInRow[y] = 0;
			}
			boardChanged = true;
			
			preview = new Array();
			previewAnim = 0;
			previewOffset = 0;
			heldBlockType = -1;
			curBlockType = -1;
			curBlock = null;
			
			playTetrisGod();
			getNextBlock();
			
			score = 0;
			combo = 0;
			boardState = PLAYING;
		}
		
		private function playTetrisGod():void
		{
			var type:int;
			var level:int;
			
			while (preview.length < PREVIEW)
			{
				level = difficultyLevel(score);
				type = Math.floor(Math.random() * numBlockTypes[level]);
				preview.push(type);
			}
		}
		
		private function difficultyLevel(s:int):int
		{
			if (difficultyLevels == 1)
			{
				return 0;
			}
			
			var x: Number;
			var prob: Number;
			var ratio: Number;
			prob = Math.random();
			if (prob < 0)
			{
				prob += 1;
			}
			
			// calculate the ratio r between the probability of different levels
			x = 2.0 * (s - Constants.HALFRSCORE) / Constants.HALFRSCORE;
			ratio = (Constants.MAXR - Constants.MINR) * (x / Math.sqrt(1 + x * x) + 1) / 2 + Constants.MINR;
			
			// run through difficulty levels and compare p to a sigmoid for each level
			for (var i:int = 1; i < difficultyLevels; i++)
			{
				x = 2.0 * (s - (Constants.SCOREINTERVAL * i)) / Constants.SCOREINTERVAL;
				if (prob > Math.pow(ratio, i) * (x / Math.sqrt(1 + x * x) + 1) / 2)
				{
					return i - 1;
				}
			}
			
			return difficultyLevels - 1;
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
				playTetrisGod();
				var trans:Point = new Point(0, 0);
				var deltaAngle:int = 0;
				
				for (var i:int = 0; i < firedKeys.length; i++)
				{
					var key:int = firedKeys[i];
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
					else if (key == Input.HOLD && !isKeyExecuted[key] && !holdUsed)
					{
						getNextBlock(true);
						isKeyExecuted[key] = true;
						return;
					}
				}
				
				for (var j:int = 0; j < releasedKeys.length; j++)
				{
					isKeyExecuted[releasedKeys[j]] = false;
				}
				
				frame = (frame + 1) % Constants.GRAVITY;
				if (frame == 0)
				{
					trans.y = 1;
				}
				moveBlock(curBlock, trans, deltaAngle);
			}
		}
		
		private function moveBlock(block:Block, trans:Point, deltaAngle:int):void
		{
			var moved:Boolean;
			
			if (trans.x != 0)
			{
				curBlock.x += trans.x;
				if (checkBlock(curBlock) != OK)
				{
					curBlock.x -= trans.x;
				}
				else
				{
					moved = true;
				}
			}
			
			if (deltaAngle != 0)
			{
				curBlock.angle += deltaAngle;
				trans.x = 0;
				while ((checkBlock(curBlock) % OVERLAP == LEFTEDGE) || (checkBlock(curBlock) % OVERLAP == RIGHTEDGE))
				{
					if (checkBlock(curBlock) % OVERLAP == LEFTEDGE)
					{
						curBlock.x++;
						trans.x++;
					}
					else
					{
						curBlock.x--;
						trans.x--;
					}
				}
				
				var check:int = checkBlock(curBlock);
				if ((check != OK) && (check % OVERLAP != TOPEDGE))
				{
					if ((curBlock.shoveaways >= MAXSHOVEAWAYS) || !shoveaway(curBlock))
					{
						curBlock.angle -= deltaAngle;
						curBlock.x -= trans.x;
					}
					else
					{
						curBlock.shoveaways++;
						moved = true;
					}
				}
				else if (check % OVERLAP == TOPEDGE)
				{
					var deltaY:int = 1;
					curBlock.y++;
					while (checkBlock(curBlock) % OVERLAP == TOPEDGE)
					{
						deltaY++;
						curBlock.y++;
					}
					if (checkBlock(curBlock) == OK)
					{
						moved = true;
					}
					else
					{
						curBlock.angle -= deltaAngle;
						curBlock.x -= trans.x;
						curBlock.y -= deltaY;
					}
				}
				else
				{
					moved = true;
				}
			}
			
			if (moved)
			{
				curBlock.localStickFrames = Constants.MAXLOCALSTICKFRAMES;
				curBlock.rowsDropped = calculateRowsDropped(curBlock);
			}
			
			if (curBlock.rowsDropped <= 0)
			{
				curBlock.globalStickFrames--;
				if (!moved)
				{
					curBlock.localStickFrames--;
				}
				if ((curBlock.globalStickFrames <= 0) || (curBlock.localStickFrames <= 0))
				{
					placeBlock(curBlock);
					getNextBlock();
				}
			}
			else
			{
				curBlock.globalStickFrames = Constants.MAXGLOBALSTICKFRAMES;
				curBlock.localStickFrames = Constants.MAXLOCALSTICKFRAMES;
				curBlock.y += trans.y;
				curBlock.rowsDropped -= trans.y;
			}
		}
		
		private function checkBlock(block:Block):int
		{
			var point:Point = new Point();
			var illegality:int = 0;
			var overlapsFound:int = 0;
			
			for (var i:int = 0; i < block.numSquares; i++)
			{
				if (block.angle % 2 == 0)
				{
					point.x = block.x + block.squares[i].x * (1 - (block.angle % 4));
					point.y = block.y + block.squares[i].y * (1 - (block.angle % 4));
				}
				else
				{
					point.x = block.x + block.squares[i].y * ((block.angle % 4) - 2);
					point.y = block.y + block.squares[i].x * (2 - (block.angle % 4));
				}
				
				if (point.y < 0)
				{
					if (illegality == 0)
					{
						illegality = TOPEDGE;
					}
				}
				else if (point.y >= Constants.NUMROWS)
				{
					if (illegality == 0)
					{
						illegality = BOTTOMEDGE;
					}
				}
				else if (point.x < 0)
				{
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
				else if (boardBlocks[point.x][point.y] > 0)
				{
					overlapsFound++;
				}
			}
			
			// the flag returned contains all the information found
			// flag%OVERLAP gives any edges the block strayed over
			// flag/OVERLAP gives the number of overlaps
			// if flag == OK (OK = 0) then the position is legal
			return illegality + OVERLAP * overlapsFound;
		}
		
		private function shoveaway(block:Block):Boolean
		{
			for (var i:int = 0; i < 4; i++)
			{
				if (checkBlock(block) == OK)
				{
					return true;
				}
				else
				{
					block.x -= 1;
					if (checkBlock(block) == OK)
					{
						return true;
					}
					block.x += 2;
					if (checkBlock(block) == OK)
					{
						return true;
					}
					block.x -= 1;
					
					if (i == 0)
					{
						block.y++;
					}
					else if (i == 1)
					{
						block.y -= 2;
					}
					else
					{
						block.y--;
					}
				}
			}
			block.y += 3;
			return false;
		}
		
		private function calculateRowsDropped(block:Block):int
		{
			for (var i:int = 0; i < Constants.NUMROWS + 1; i++)
			{
				if (checkBlock(block) == OK)
				{
					block.y++;
				}
				else
				{
					block.y -= i;
					return i - 1;
				}
			}
			return Constants.NUMROWS;
		}
		
		private function placeBlock(block:Block):void
		{
			var point:Point = new Point();
			
			for (var i:int = 0; i < block.numSquares; i++)
			{
				if (block.angle % 2 == 0)
				{
					point.x = block.x + block.squares[i].x * (1 - (block.angle % 4));
					point.y = block.y + block.squares[i].y * (1 - (block.angle % 4));
				}
				else
				{
					point.x = block.x + block.squares[i].y * ((block.angle % 4) - 2);
					point.y = block.y + block.squares[i].x * (2 - (block.angle % 4));
				}
				boardBlocks[point.x][point.y] = block.color;
				blocksInRow[point.y]++;
				boardChanged = true;
			}
			
			removeRows();
		}
		
		private function removeRows():int
		{
			var numRowsRemoved:int = 0;
			
			for (var y:int = Constants.NUMROWS - 1; y >= 0; y--)
			{
				if (blocksInRow[y] == Constants.NUMCOLS)
				{
					numRowsRemoved++;
				}
				else if (numRowsRemoved > 0)
				{
					for (var x:int = 0; x < Constants.NUMCOLS; x++)
					{
						boardBlocks[x][y + numRowsRemoved] = boardBlocks[x][y];
						boardBlocks[x][y] = 0;
					}
					blocksInRow[y + numRowsRemoved] = blocksInRow[y];
					blocksInRow[y] = 0;
				}
			}
			if (numRowsRemoved > 0)
			{
				score += ((1 << numRowsRemoved) - 1);
				combo++;
			}
			else
			{
				combo = 0;
			}
			
			return numRowsRemoved;
		}
		
		private function getNextBlock(swap:Boolean = false):void
		{
			var blockType:int;
			
			if ((!swap) || (heldBlockType == -1))
			{
				blockType = preview.shift();
				if (swap)
				{
					heldBlockType = curBlockType;
				}
				previewAnim = PREVIEWANIMFRAMES;
				previewOffset = ($blockData[blockType].height + 1) * Constants.SQUAREWIDTH / 2;
			}
			else
			{
				blockType = heldBlockType;
				heldBlockType = curBlockType;
			}
			
			curBlockType = blockType;
			curBlock = new Block();
			curBlock.x = $blockData[blockType].x;
			curBlock.y = $blockData[blockType].y;
			curBlock.numSquares = $blockData[blockType].numSquares;
			for (var i:int = 0; i < curBlock.numSquares; i++)
			{
				curBlock.squares[i].x = $blockData[blockType].squares[i].x;
				curBlock.squares[i].y = $blockData[blockType].squares[i].y;
			}
			curBlock.color = $blockData[blockType].color;
			curBlock.rotates = $blockData[blockType].rotates;
			curBlock.height = $blockData[blockType].height;
			
			curBlock.rowsDropped = calculateRowsDropped(curBlock);
			if (curBlock.rowsDropped < 0)
			{
				boardState = GAMEOVER;
			}
			
			holdUsed = swap;
		}
		
		public function draw():void
		{
			drawBase();
			drawBoardState();
			drawBlock(curBlock, true);
			drawBlock(curBlock);
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
		
		private function drawBoardState():void
		{
			for (var i:int = 0; i < Constants.NUMCOLS; i++)
			{
				for (var j:int = Constants.MAXBLOCKSIZE - 1; j < Constants.NUMROWS; j++)
				{
					if (boardBlocks[i][j] > 0)
					{
						drawSquare(i, j, boardBlocks[i][j]);
					}
				}
			}
		}
		
		private function drawBlock(block:Block, isShadow:Boolean = false):void
		{
			var point:Point = new Point();
			for (var i:int = 0; i < block.numSquares; i++)
			{
				if ((block.angle) % 2 == 0)
				{
					point.x = block.x + block.squares[i].x * (1 - ((block.angle) % 4));
					point.y = block.y + block.squares[i].y * (1 - ((block.angle) % 4));
				}
				else
				{
					point.x = block.x + block.squares[i].y * (((block.angle) % 4) - 2);
					point.y = block.y + block.squares[i].x * (2 - ((block.angle) % 4));
				}
				if (isShadow)
				{
					drawSquare(point.x, point.y + block.rowsDropped, block.color, true);
				}
				else
				{
					drawSquare(point.x, point.y, block.color);
				}
			}
		}
		
		private function drawSquare(i:int, j:int, color:uint, isShadow:Boolean = false):void
		{
			if (j < Constants.MAXBLOCKSIZE - 1)
			{
				return;
			}
			var pos:Point = new Point(Constants.SQUAREWIDTH * i, Constants.SQUAREWIDTH * (j - Constants.MAXBLOCKSIZE + 1));
			
			if (isShadow)
			{
				drawSquare(i, j, Color.BLACK);
				graphics.lineStyle(1, color);
				graphics.endFill();
				
				for (var k:int = 0; k < 2 * Constants.SQUAREWIDTH - 1; k++)
				{
					if ((pos.x + pos.y + k) % 4 == 0)
					{
						if (k < Constants.SQUAREWIDTH)
						{
							drawLineOffset(pos.x, pos.y + k, pos.x + k, pos.y);
						}
						else
						{
							drawLineOffset(pos.x + Constants.SQUAREWIDTH, pos.y - Constants.SQUAREWIDTH + k, pos.x - Constants.SQUAREWIDTH + k, pos.y + Constants.SQUAREWIDTH);
						}
					}
				}
			}
			else
			{
				graphics.lineStyle(1, Color.mixedColor(Color.WHITE, color, Color.LAMBDA));
				graphics.beginFill(color);
				drawRectOffset(pos.x, pos.y, Constants.SQUAREWIDTH - 1, Constants.SQUAREWIDTH - 1);
			}
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