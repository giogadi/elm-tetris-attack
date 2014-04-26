module DrawBoard ( bpiFromCanvasElem
                 , drawGame
                 ) where

import Board
import Haste.Graphics.Canvas
import Haste.App

import Control.Monad (liftM, liftM2)

areaW = 800
areaH = 600

loadImgData :: MonadIO m => m Bitmap
loadImgData = loadBitmap "resources/tileset.png"

drawTileColor :: Bitmap -> Int -> TileColor -> Picture ()
drawTileColor img size c = let colorIx = fromEnum c
                               clipRect = Rect (64 * fromIntegral colorIx) 0 64 64
                               scaleFactor = fromIntegral size / 64
                           in  scale (scaleFactor, scaleFactor) $ drawClipped img (0,0) clipRect

-- board placement info
data BPI = BPI
           { _lowerLeftX :: Int
           , _lowerLeftY :: Int
           , _tileSize :: Int }

getBPI :: (Int, Int) -> BPI
getBPI (w, h) =
  let heightRatio = 0.9
      tSize = truncate $ heightRatio * (fromIntegral h) / (fromIntegral boardRows)
      llX = 0
      llY = h
  in  BPI llX llY tSize

-- [0,1] -> [0,1] with f'(0) = f'(1) = f''(0) = f''(1) = 0
smoothStep :: Time -> Time
smoothStep t = 6*t^5 - 15*t^4 + 10*t^3

tileScreenPosition :: BPI -> (Int,Int) -> TileState -> (Double, Double)
tileScreenPosition (BPI lowerLeftX lowerLeftY tileSize) (x,y) tileState =
  let halfSize = tileSize `div` 2
      offsetX = case tileState of
                  SwitchingLeft p -> tileSize - (truncate $ (smoothStep p)*(fromIntegral tileSize))
                  SwitchingRight p -> -tileSize + (truncate $ (smoothStep p)*(fromIntegral tileSize))
                  _ -> 0
      offsetY = case tileState of
                  Falling p v -> -tileSize + (truncate $ p*(fromIntegral tileSize))
                  Fell p v -> -tileSize + (truncate $ p*(fromIntegral tileSize))
                  _ -> 0
  in  (fromIntegral $ lowerLeftX + x * tileSize + offsetX,
       fromIntegral $ lowerLeftY - tileSize - y * tileSize + offsetY)

drawTile :: BPI -> Bitmap -> (Int,Int) -> Tile -> Picture ()
drawTile bpi@(BPI _ _ tSize) img tileIx (color, state) =
  let screenPos = tileScreenPosition bpi tileIx state
  in  translate screenPos $ drawTileColor img tSize color

drawBoard :: BPI -> Bitmap -> Board -> Picture ()
drawBoard bpi img b =
  let ts = generateBoardIndices b
      drawMaybe (mt, ix) = maybe (return ()) (drawTile bpi img ix) mt
  in  sequence_ $ map drawMaybe ts

cursorPositionFromIx :: BPI -> (Int,Int) -> (Double, Double)
cursorPositionFromIx (BPI lowerLeftX lowerLeftY tileSize) (leftX, leftY) =
  (fromIntegral $ lowerLeftX + leftX * tileSize,
   fromIntegral $ lowerLeftY - tileSize - leftY * tileSize)

drawCursor :: BPI -> Bitmap -> (Int, Int) -> Picture ()
drawCursor bpi img ix = (translate $ cursorPositionFromIx bpi ix) $ drawCursorAux
  where drawCursorAux :: Picture ()
        drawCursorAux =
          let clipRect = Rect (4*64) 0 128 64
              scaleF = fromIntegral (_tileSize bpi) / 64
          in  scale (scaleF, scaleF) $ drawClipped img (0,0) clipRect

drawGame :: BPI -> Bitmap -> GameState -> Picture ()
drawGame bpi img (GameState b cIx) = drawBoard bpi img b >> drawCursor bpi img cIx

bpiFromCanvasElem :: MonadIO m => Elem -> m BPI
bpiFromCanvasElem e = do
  Just c <- getCanvas e
  wStr <- getProp e "width"
  hStr <- getProp e "height"
  return $ getBPI (read wStr, read hStr)
