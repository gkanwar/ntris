package ntris
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.navigateToURL;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import ntris.Board;
	//import ntris.BlockData;
	import ntris.Color;
	
	// Width is BOARDWIDTH + 2*BORDER, height is BOARDHEIGHT + 2*BORDER
	[SWF(width='367',height='546')]
	
	public class Main extends Sprite
	{
		private var loader:URLLoader;
		private var blockDataLoaded:Boolean = false;
		private var difficultyLevels:uint;
		private var numBlockTypes:Array;
		private var blockData:Array;
		
		public function Main():void
		{
			// The rest of the initialization code is in finishMain(), called after the blockData.dat file is loaded
			openBlockData();
		}
		
		private function openBlockData():void
		{
			var url:String = "blockData.dat";
			var request:URLRequest = new URLRequest(url);
			
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, readBlockData);
			loader.load(request);
		}
		
		private function readBlockData(event:Event):void
		{
			var data:Array = loader.data.split(',');
			var streamCounter:int = 0;
			difficultyLevels = data[streamCounter++];
			numBlockTypes = new Array();
			blockData = new Array();
			
			for (var j:int = 0; j < difficultyLevels; j++)
			{
				numBlockTypes.push(data[streamCounter++]);
			}
			
			for (var k:int = 0; k < numBlockTypes[difficultyLevels - 1]; k++)
			{
				var tempBlock:Block = new Block();
				tempBlock.x = data[streamCounter++];
				tempBlock.y = data[streamCounter++];
				tempBlock.numSquares = data[streamCounter++];
				for (var i:int = 0; i < tempBlock.numSquares; i++)
				{
					tempBlock.squares[i].x = data[streamCounter++];
					tempBlock.squares[i].y = data[streamCounter++];
				}
				tempBlock.color = Color.mixedColor(Color.BLACK, data[streamCounter++], 0.2);
				tempBlock.height = calculateBlockHeight(tempBlock);
				blockData.push(tempBlock);
			}
			
			if (streamCounter != data.length)
			{
				trace("Incorrectly formatted blockData.dat file");
			}
			finishMain();
		}
		
		private function calculateBlockHeight(block:Block):uint
		{
			var highest:int = 0;
			var lowest:int = 0;
			
			for (var i:int = 0; i < block.numSquares; i++)
			{
				if (block.squares[i].y < lowest)
					lowest = block.squares[i].y;
				if (block.squares[i].y > highest)
					highest = block.squares[i].y;
			}
			return highest - lowest + 1;
		}
		
		private function finishMain():void
		{
			var board:Board = new Board();
			addChild(board);
			board.redraw();
		}
	}
}