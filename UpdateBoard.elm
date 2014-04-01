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

data Action = None | CursorLeft | CursorRight | CursorDown | CursorUp | Swap

onUp : Signal Bool -> Signal ()
onUp = lift (\_ -> ()) . keepIf id False . dropRepeats

onDown : Signal Bool -> Signal ()
onDown =  lift (\_ -> ()) . keepIf not False . dropRepeats

-- 
onPressed : Keyboard.KeyCode -> Signal ()
onPressed = onUp . Keyboard.isDown

onReleased : Keyboard.KeyCode -> Signal ()
onReleased = onDown . Keyboard.isDown

--
-- Signal that is False until the given keycode is pressed, 
-- but then is only True for one "frame" before returning to False.
--
-- Note the ugly fps call...
keyPressed : Keyboard.KeyCode -> Signal Bool
keyPressed key = merge (sampleOn (onPressed key) (constant True)) (sampleOn (fps 60) (constant False))

type KeyboardInputs = {left:Bool, right:Bool, down:Bool, up:Bool, space:Bool}

keyboardInputs : Signal KeyboardInputs
keyboardInputs = KeyboardInputs <~ (keyPressed 37)
                                 ~ (keyPressed 39)
                                 ~ (keyPressed 40)
                                 ~ (keyPressed 38)
                                 ~ (keyPressed 32)

action : KeyboardInputs -> Action
action {left,right,down,up,space} = if | left && not right -> CursorLeft
                                       | right && not left -> CursorRight
                                       | up && not down -> CursorUp
                                       | down && not up -> CursorDown
                                       | space -> Swap
                                       | otherwise -> None

type Input = { action:Action, dt:Time }

timeStep : Signal Time
timeStep = inSeconds <~ fps 60

input = sampleOn timeStep <| Input <~ (lift action keyboardInputs)
                                    ~ timeStep

stepGame : Input -> GameState -> GameState
stepGame {action, dt} {board, cursorIdx} =
  let newCursorIdx = case action of
                       CursorLeft -> moveCursorLeft cursorIdx
                       CursorRight -> moveCursorRight cursorIdx
                       CursorDown -> moveCursorDown cursorIdx
                       CursorUp -> moveCursorUp cursorIdx
                       _ -> cursorIdx
      --newBoard = updateBoard 
      newBoard = board
  in  {board = newBoard, cursorIdx = newCursorIdx}
