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

screenPositionFromIdx : BoardPlacementInfo -> (Int,Int) -> (Float, Float)
screenPositionFromIdx { lowerLeftX, lowerLeftY, tileSize } (x,y) =
  let halfSize = tileSize `div` 2
  in  (toFloat <| lowerLeftX + halfSize + x * tileSize, toFloat <| lowerLeftY + halfSize + y * tileSize)

formFromTile : BoardPlacementInfo -> Tile -> Form
formFromTile {lowerLeftX, lowerLeftY, tileSize} (c,_) =
  toForm . image tileSize tileSize <| colorToString c ++ ".bmp"

moveFormFromIdx : BoardPlacementInfo -> (Int, Int) -> Form -> Form
moveFormFromIdx bpi idx = move (screenPositionFromIdx bpi idx)

formsFromBoard : BoardPlacementInfo -> Board -> [Form]
formsFromBoard bpi b =
  let tileIdxs = generateBoardIndices b
      placedForm (t, idx) =
        (liftMaybe <| moveFormFromIdx bpi idx)  <| (liftMaybe <| formFromTile bpi) t
  in  justs <| map placedForm tileIdxs

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
