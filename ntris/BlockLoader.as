package ntris
{
	import ntris.Main;
	import flash.events.Event;
	import flash.net.navigateToURL;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.geom.Point;
	
	public class BlockLoader
	{
		private var loader:URLLoader;
		private var blockDataLoaded:Boolean = false;
		private var difficultyLevels:uint;
		private var numBlockTypes:Array;
		private var blockData:Array;
		private var $mainRef:Main;
		public function BlockLoader($mainRefIncoming:Main)
		{
			$mainRef = $mainRefIncoming;
		}
		
		public function openBlockData():void
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
			$mainRef.finishMain();
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
		
		private function doesBlockRotate(block:Block):Boolean
		{
			var lowest:Point = new Point(0, 0);
			var highest:Point = new Point(0, 0);
			
			for (var i:int = 0; i < block.numSquares; i++)
			{
				if (block.squares[i].x < lowest.x)
				{
					lowest.x = block.squares[i].x;
				}
				else if (block.squares[i].x > highest.x)
				{
					highest.x = block.squares[i].x;
				}
				if (block.squares[i].y < lowest.y)
				{
					lowest.y = block.squares[i].y;
				}
				else if (block.squares[i].y > highest.y)
				{
					highest.y = block.squares[i].y;
				}
			}
			
			if (highest.x - lowest.x != highest.y - lowest.y)
			{
				return true;
			}
			
			var rotated:Point = new Point(0, 0);
			for (i = 0; i < block.numSquares; i++)
			{
				rotated.x = lowest.x + highest.y - block.squares[i].y;
				rotated.y = lowest.y + block.squares[i].x - lowest.x;
				var found:Boolean = false;
				for (var j:int = 0; j < block.numSquares; j++)
				{
					found = found || (rotated.x == block.squares[j].x && rotated.y == block.squares[j].y);
				}
				if (!found)
				{
					return true;
				}
			}
			
			return false;
		}
	}
}