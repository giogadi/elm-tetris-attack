module DrawBoard where

import Board (..)
import Debug

areaW = 800
areaH = 600

type BoardPlacementInfo = { lowerLeftX:Int, lowerLeftY:Int, tileSize:Int }

getBoardPlacementInfo : (Int, Int) -> Float -> BoardPlacementInfo
getBoardPlacementInfo (w,h) scroll =
  let heightRatio = 0.9
      tSize = truncate <| heightRatio * (toFloat h) / (toFloat boardRows)
      llX = -(truncate <| (toFloat boardColumns / 2) * toFloat tSize)
      llY = (-h `div` 2) + round (scroll * (toFloat tSize))
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
                  Fell p v -> tileSize - (truncate <| p*(toFloat tileSize))
                  _ -> 0
  in  (toFloat <| lowerLeftX + halfSize + x * tileSize + offsetX,
       toFloat <| lowerLeftY + halfSize + y * tileSize + offsetY)

formFromTile : BoardPlacementInfo -> (Int,Int) -> Tile -> Form
formFromTile ({lowerLeftX, lowerLeftY, tileSize} as bpi) tileIdx (c,s) =
  -- let tileImgForm = toForm . image tileSize tileSize <| "resources/" ++ colorToString c ++ ".bmp"
  let tileImgForm = case c of
                      Red -> filled red <| square (toFloat tileSize)
                      Blue -> filled blue <| square (toFloat tileSize)
                      Green -> filled green <| square (toFloat tileSize)
                      Yellow -> filled yellow <| square (toFloat tileSize)
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
  let imgForm = toForm <| image (bpi.tileSize * 2) (bpi.tileSize) "resources/cursor.png"
  in  move (cursorPositionFromIdx bpi leftIdx) imgForm

displayGame : (Int, Int) -> GameState -> Element
displayGame (windowW, windowH) game =
  let bpi = getBoardPlacementInfo (areaW, areaH) game.globalScroll
  in container windowW windowH middle . collage areaW areaH <|
       [rect areaW areaH |> filled (rgb 0 0 0)] ++
       formsFromBoard bpi game.board ++ [cursorForm bpi game.cursorIdx]
