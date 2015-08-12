module PortableBoard where

import Board exposing (..)
import Json exposing (..)

tileToJson : Maybe Tile -> Value
tileToJson mt = case mt of
                  Nothing -> Null
                  Just (c,s) -> let i = Number <| toFloat c in
                                case s of
                                  Stationary -> Array [i, Number 0]
                                  SwitchingLeft x -> Array [i, Number 1, Number x]
                                  SwitchingRight x -> Array [i, Number 2, Number x]
                                  Falling x y -> Array [i, Number 3, Number x, Number y]
                                  Fell x y -> Array [i, Number 4, Number x, Number y]
                                  Matching x -> Array [i, Number 5, Number x]

jsonToTile : Value -> Maybe Tile
jsonToTile jsonV = case jsonV of
                     Null -> Nothing
                     Array (Number cNum :: Number sFloat :: xs) ->
                       let c = round cNum
                           s = round sFloat in
                       case s of
                         0 -> Just (c, Stationary)
                         -- TODO report: why doesn't "let (Number x) = head xs" work?
                         1 -> let (Number x :: []) = xs in Just (c, SwitchingLeft x)
                         2 -> let (Number x :: []) = xs in Just (c, SwitchingRight x)
                         3 -> let (Number x :: Number y :: []) = xs in
                              Just (c, Falling x y)
                         4 -> let (Number x :: Number y :: []) = xs in
                              Just (c, Fell x y)
                         5 -> let (Number x :: []) = xs in Just (c, Matching x)

boardToJson : Board -> Value
boardToJson = Array . concatMap (map tileToJson)

jsonToBoard : Value -> Board
jsonToBoard (Array jsonVs) = let mts = map jsonToTile jsonVs
                                 go proc ts colsLeft =
                                   case colsLeft of
                                     0 -> proc
                                     _ -> let (ts1, ts2) = (take boardRows ts, drop boardRows ts)
                                          in  go (ts1 :: proc) ts2 (colsLeft - 1)
                             in  reverse <| go [] mts boardColumns

cursorToJson : (Int, Int) -> Value
cursorToJson (x,y) = Array [Number <| toFloat x, Number <| toFloat y]

jsonToCursor : Value -> (Int, Int)
jsonToCursor (Array (Number x :: Number y :: [])) = (round x, round y)

stateToJson : BoardState -> Value
stateToJson s = Array [boardToJson s.board, cursorToJson s.cursorIdx, Number s.globalScroll]

jsonToState : Value -> BoardState
jsonToState (Array (boardJson :: cursorJson :: (Number scroll) :: [])) =
  {board = jsonToBoard boardJson,
   cursorIdx = jsonToCursor cursorJson,
   globalScroll = scroll,
   rng = 0,
   dtOld = 0}


stateToString : BoardState -> String
stateToString s = toString "" <| stateToJson s

stringToState : String -> Maybe BoardState
stringToState str = liftMaybe jsonToState <| fromString str
