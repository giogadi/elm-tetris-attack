module DrawBoard where

import Board (..)

areaW = 640
areaH = 480

type BoardPlacementInfo = { lowerLeftX:Int, lowerLeftY:Int, tileSize:Int }

getBoardPlacementInfo : (Int, Int) -> BoardPlacementInfo
getBoardPlacementInfo (w,h) = let heightRatio = 0.9
                                  tSize = truncate <| heightRatio * (toFloat h) / (toFloat boardRows)
                                  llX = -(truncate <| (toFloat boardColumns / 2) * toFloat tSize)
                                  llY = (-h `div` 2)
                              in  { lowerLeftX = llX, lowerLeftY = llY, tileSize = tSize }

-- [0,1] -> [0,1] with f'(0) = f'(1) = f''(0) = f''(1) = 0
smoothStep : Time -> Time
smoothStep t = 6*t^5 - 15*t^4 + 10*t^3

tileScreenPosition : BoardPlacementInfo -> (Int,Int) -> State -> (Float, Float)
tileScreenPosition { lowerLeftX, lowerLeftY, tileSize } (x,y) tileState =
  let halfSize = tileSize `div` 2
      offsetX = case tileState of
                  SwitchingLeft p -> tileSize - (truncate <| (smoothStep p)*(toFloat tileSize))
                  SwitchingRight p -> -tileSize + (truncate <| (smoothStep p)*(toFloat tileSize))
                  _ -> 0
      offsetY = case tileState of
                  Falling p v -> tileSize - (truncate <| p*(toFloat tileSize))
                  _ -> 0
  in  (toFloat <| lowerLeftX + halfSize + x * tileSize + offsetX,
       toFloat <| lowerLeftY + halfSize + y * tileSize + offsetY)

formFromTile : BoardPlacementInfo -> (Int,Int) -> Tile -> Form
formFromTile ({lowerLeftX, lowerLeftY, tileSize} as bpi) tileIdx (c,s) =
  let tileImgForm = toForm . image tileSize tileSize <| colorToString c ++ ".bmp"
  in move (tileScreenPosition bpi tileIdx s) tileImgForm

formsFromBoard : BoardPlacementInfo -> Board -> [Form]
formsFromBoard bpi b =
  let tileIdxs = generateBoardIndices b
      mkTileForm (t, idx) = liftMaybe (formFromTile bpi idx) t
  in  justs <| map mkTileForm tileIdxs

cursorPositionFromIdx : BoardPlacementInfo -> (Int,Int) -> (Float,Float)
cursorPositionFromIdx {lowerLeftX, lowerLeftY, tileSize} (leftX, leftY) =
  let tileHalfSize = tileSize `div` 2
  in  (toFloat <| lowerLeftX + tileSize + leftX * tileSize,
       toFloat <| lowerLeftY + tileHalfSize + leftY * tileSize)

cursorForm : BoardPlacementInfo -> (Int, Int) -> Form
cursorForm bpi leftIdx =
  let imgForm = toForm <| image (bpi.tileSize * 2) (bpi.tileSize) "cursor.png"
  in  move (cursorPositionFromIdx bpi leftIdx) imgForm

displayGame : (Int, Int) -> GameState -> Element
displayGame (windowW, windowH) game =
  let bpi = getBoardPlacementInfo (areaW, areaH)
  in container windowW windowH middle . collage areaW areaH <|
       formsFromBoard bpi game.board ++ [cursorForm bpi game.cursorIdx]
