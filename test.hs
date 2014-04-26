import Haste.Graphics.Canvas
import Haste.DOM
import Haste
import Board
import DrawBoard

main :: IO ()
main = do
  let b = mkRandomBoard $ mkSeed 2
      cIx = (0,0)
  Just ce <- elemById "canvas"
  bpi <- bpiFromCanvasElem ce
  Just c <- getCanvas ce
  img <- loadBitmap "resources/tileset.png"
  bitmapElem img `onEvent` OnLoad $ render c $ drawGame bpi img $ GameState b cIx
  return ()
