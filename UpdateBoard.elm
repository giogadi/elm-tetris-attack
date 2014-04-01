module UpdateBoard where

import Board (..)
import Keyboard

switchingSpeed = 0.005

updateTile : Time -> Tile -> Tile
updateTile dt tile = case tile of
                       (_, Stationary) -> tile
                       (c, SwitchingLeft p) ->
                           if p < 1.0
                           then (c, SwitchingLeft <| p + dt * switchingSpeed)
                           else (c, Stationary)
                       (c, SwitchingRight p) ->
                           if p < 1.0
                           then (c, SwitchingRight <| p + dt * switchingSpeed)
                           else (c, Stationary)

updateColumn : Time -> [Maybe Tile] -> [Maybe Tile]
updateColumn dt = map (liftMaybe <| updateTile dt)

updateBoard : Time -> Board -> Board
updateBoard dt = map <| updateColumn dt

moveCursorLeft : (Int, Int) -> (Int, Int)
moveCursorLeft (currentX, currentY) =
  if currentX == 0
    then (currentX, currentY)
    else (currentX - 1, currentY)

moveCursorRight : (Int, Int) -> (Int, Int)
moveCursorRight (currentX, currentY) =
  if currentX == boardColumns - 2
    then (currentX, currentY)
    else (currentX + 1, currentY)

moveCursorDown : (Int, Int) -> (Int, Int)
moveCursorDown (currentX, currentY) =
  if currentY == 0
    then (currentX, currentY)
    else (currentX, currentY - 1)

moveCursorUp : (Int, Int) -> (Int, Int)
moveCursorUp (currentX, currentY) =
  if currentY == boardRows - 1
    then (currentX, currentY)
    else (currentX, currentY + 1)

switchTileLeft : Tile -> Tile
switchTileLeft (c, _) = (c, SwitchingLeft 0.0)

switchTileRight : Tile -> Tile
switchTileRight (c, _) = (c, SwitchingRight 0.0)

swapTiles : Board -> (Int, Int) -> Board
swapTiles b (x,y) = let left = liftMaybe switchTileRight <| getTileAt b (x,y)
                        right = liftMaybe switchTileLeft <| getTileAt b (x+1,y)
                        b1 = setTileAt b (x,y) right
                    in  setTileAt b1 (x+1,y) left

onUp : Signal Bool -> Signal ()
onUp = lift (\_ -> ()) . keepIf id False . dropRepeats

onDown : Signal Bool -> Signal ()
onDown =  lift (\_ -> ()) . keepIf not False . dropRepeats

-- 
onPressed : Keyboard.KeyCode -> Signal ()
onPressed = onUp . Keyboard.isDown

onReleased : Keyboard.KeyCode -> Signal ()
onReleased = onDown . Keyboard.isDown

data Input = None |
             CursorLeft |
             CursorRight |
             CursorDown |
             CursorUp |
             Swap |
             NewTimeStep Time

keyPressed : Keyboard.KeyCode -> Input -> Signal Input
keyPressed key action = merge (constant None) <| always action <~ onPressed key

input : Signal Input
input = let keyPressInput = merges <| zipWith keyPressed
                                        [37, 39, 40, 38, 32]
                                        [CursorLeft, CursorRight, CursorDown, CursorUp, Swap]
        in  merge keyPressInput <| NewTimeStep <~ fps 30

stepGame : Input -> GameState -> GameState
stepGame input {board, cursorIdx, dtOld} =
  let newCursorIdx = case input of
                       CursorLeft -> moveCursorLeft cursorIdx
                       CursorRight -> moveCursorRight cursorIdx
                       CursorDown -> moveCursorDown cursorIdx
                       CursorUp -> moveCursorUp cursorIdx
                       _ -> cursorIdx
      newTimeStep = case input of
                      NewTimeStep dt -> dt
                      _ -> dtOld
      swappedBoard = case input of
                       Swap -> swapTiles board newCursorIdx
                       _ -> board
      newBoard = updateBoard newTimeStep swappedBoard
  in  {board = newBoard, cursorIdx = newCursorIdx, dtOld = newTimeStep}
