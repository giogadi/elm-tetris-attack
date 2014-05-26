module UpdateBoard where

import Board (..)
import Keyboard
import Pseudorandom
import Debug

switchingTimeInSeconds = 0.25
switchingSpeed = 1.0 / switchingTimeInSeconds

matchingTimeInSeconds = 0.1
matchingSpeed = 1.0 / matchingTimeInSeconds

oneStepScrollTimeInSeconds = 5.0
scrollSpeed = 1.0 / oneStepScrollTimeInSeconds

gravityConstant = 9.81

updateTile : Time -> Maybe Tile -> Maybe Tile
updateTile timeStep maybeTile = let dt = timeStep in -- for easy time compression/dilation
  case maybeTile of
    Nothing -> Nothing
    Just tile -> case tile of
                   (_, Stationary) -> Just tile
                   (c, SwitchingLeft p) ->
                     if p < 1.0
                     then Just (c, SwitchingLeft <| p + dt * switchingSpeed)
                     else Just (c, Stationary)
                   (c, SwitchingRight p) ->
                     if p < 1.0
                     then Just (c, SwitchingRight <| p + dt * switchingSpeed)
                     else Just (c, Stationary)
                   (c, Falling p v) ->
                     if p < 1.0
                     then Just (c, Falling (p + dt * v) (v + dt * gravityConstant))
                     else Just (c, Fell (p + dt * v) (v + dt * gravityConstant))
                   (c, Matching t) ->
                     if t < 1.0
                     then Just (c, Matching (t + dt * matchingSpeed))
                     else Nothing
                   whatever -> Just <| Debug.log "updateTile:" whatever

updateColumn : Time -> [Maybe Tile] -> [Maybe Tile]
updateColumn dt = map <| updateTile dt

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
  if currentY <= 1
    then (currentX, currentY)
    else (currentX, currentY - 1)

moveCursorUp : (Int, Int) -> (Int, Int)
moveCursorUp (currentX, currentY) =
  if currentY == boardRows - 2
    then (currentX, currentY)
    else (currentX, currentY + 1)

switchable : Maybe Tile -> Bool
switchable t = case t of
                 Nothing -> True
                 Just (_, Stationary) -> True
                 _ -> False

switchTileLeft : Tile -> Tile
switchTileLeft (c, _) = (c, SwitchingLeft 0.0)

switchTileRight : Tile -> Tile
switchTileRight (c, _) = (c, SwitchingRight 0.0)

-- TODO: in real Tetris Attack, you can swap falling tiles with stationary ones.
swapTiles : Board -> (Int, Int) -> Board
swapTiles b (x,y) = let left = getTileAt b (x,y)
                        right = getTileAt b (x+1,y)
                    in  if switchable left && switchable right
                        then let b1 = setTileAt b (x,y) (liftMaybe switchTileLeft right)
                             in  setTileAt b1 (x+1,y) (liftMaybe switchTileRight left)
                        else b

-- TODO: look into why some "fells" are getting through here
updateFallColumn : [Maybe Tile] -> [Maybe Tile]
updateFallColumn c =
  let go ts falling proc =
        case ts of
          (th::tn::tt) ->
            if falling
            then case th of
                   Nothing -> case tn of
                                Just (c, Stationary) ->
                                  go (th::tt) True <| proc ++ [Just (c, Falling 0.0 0.0)]
                                Just (c, Fell p v) ->
                                  go (th::tt) True <| proc ++ [Just (c, Falling (p-1.0) v)]
                                _ -> go (th::tt) True <| proc ++ [tn]
            else case th of
                   Nothing -> case tn of
                                Just (c, Stationary) ->
                                  go (th::tt) True <| proc ++ [Just (c, Falling 0.0 0.0)]
                                Just (c, Fell p v) ->
                                  go (th::tt) True <| proc ++ [Just (c, Falling (p-1.0) v)]
                                _ -> go (tn::tt) False <| proc ++ [th]
                   Just (c, Fell _ _) -> go (tn::tt) False <| proc ++ [Just (c, Stationary)]
                   _ -> go (tn::tt) False <| proc ++ [th]
          (th::_) -> proc ++ [th]
  in  go c False []

updateFalls : Board -> Board
updateFalls = map updateFallColumn

updateMatchesInList : [Maybe Tile] -> [Maybe Tile]
updateMatchesInList tileList =
  let match stack numMatches =
        case numMatches of
          0 -> stack
          n -> case head stack of
                 Just (c,_) -> Just (c, Matching 0.0) :: match (tail stack) (n-1)
                 -- _ -> error
      tryMatch stack numMatches = if numMatches >= 3
                                  then match stack numMatches
                                  else stack
      go newList numInARow ts =
          case ts of
            [] -> tryMatch newList numInARow
            Just (tc, Stationary) :: tl ->
              case newList of
                [] -> go [Just (tc, Stationary)] 1 tl
                Just (cn, Stationary) :: _  -> if tc == cn
                                               then go (head ts :: newList) (numInARow+1) tl
                                               else go (head ts :: tryMatch newList numInARow) 1 tl
                _ -> go (head ts :: tryMatch newList numInARow) 1 tl
            t :: tl -> go (t :: tryMatch newList numInARow) 0 tl
  in  reverse <| go [] 0 tileList

combineMatches : Board -> Board -> Board
combineMatches =
  let tileOr t1 t2 = case (t1,t2) of
                       (Just (c, Matching t), Just (c, _)) -> Just (c, Matching t)
                       (Just (c, _), Just (c, Matching t)) -> Just (c, Matching t)
                       (t, t) -> t
                       -- _ -> error
  in  zipWith (zipWith tileOr)

-- Does not update matches for 0th row because that one is still coming up from below
updateMatches : Board -> Board
updateMatches b = let subBoard = map tail b
                      columnMatched = map updateMatchesInList subBoard
                      rowMatched = transpose <| map updateMatchesInList <| transpose subBoard
                      allMatched = combineMatches columnMatched rowMatched
                  in  zipWith (::) (map head b) allMatched

scrollBoard : Board -> RandSeed -> (Board, Int)
scrollBoard b rng = let (randInts, rng') = Pseudorandom.randomRange (0,numColors-1) boardColumns <| rng
                        tailless = map (take (boardRows - 1)) b
                    in  (zipWith (::) (map intToTile randInts) tailless, rng')

data GameInput = None |
                 CursorLeft |
                 CursorRight |
                 CursorDown |
                 CursorUp |
                 Swap |
                 NewTimeStep Time

stepBoard : GameInput -> BoardState -> BoardState
stepBoard input {board, cursorIdx, globalScroll, rng, dtOld} =
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
      fallingBoard = updateFalls swappedBoard
      matchedBoard = updateMatches fallingBoard
      stepScroll = globalScroll + (inSeconds newTimeStep) * scrollSpeed
      (scrolledBoard, scrolledCursor, newScroll, newRNG) =
        if stepScroll >= 1.0
        then let (scrolled, rng') = scrollBoard matchedBoard rng
             in  (scrolled, moveCursorUp newCursorIdx, stepScroll - 1.0, rng')
        else (matchedBoard, newCursorIdx, stepScroll, rng)
      newBoard = updateBoard (inSeconds newTimeStep) scrolledBoard
  in  {board = newBoard, cursorIdx = scrolledCursor, globalScroll = newScroll, rng = newRNG, dtOld = newTimeStep}
