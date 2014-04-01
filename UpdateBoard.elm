module UpdateBoard where

import Board (..)
import Keyboard

switchingSpeed = 1.0

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
      --newBoard = updateBoard 
      newBoard = board
  in  {board = newBoard, cursorIdx = newCursorIdx, dtOld = newTimeStep}
