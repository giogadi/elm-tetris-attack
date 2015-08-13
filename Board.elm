module Board where

import List exposing (..)
import Random
import Time exposing (..)
import Util exposing (..)

boardRows = 12
boardColumns = 7

type alias ContinuousPosition = Float
type alias ContinuousSpeed = Float


type alias TileColor = Int

numColors = 6

type State = Stationary |
             SwitchingLeft ContinuousPosition |
             SwitchingRight ContinuousPosition |
             Falling ContinuousPosition ContinuousSpeed |
             Fell ContinuousPosition ContinuousSpeed |
             Matching Float
type alias Tile = (TileColor, State)

mkTile : TileColor -> Tile
mkTile c = (c, Stationary)

type alias Board = List (List (Maybe Tile))

type alias BoardState = { board:Board, cursorIdx:(Int,Int), globalScroll:Float, rng:Random.Seed, dtOld:Time }

mkEmptyColumn : List (Maybe Tile)
mkEmptyColumn = repeat boardRows Nothing

mkEmptyBoard : Board
mkEmptyBoard = repeat boardColumns <| mkEmptyColumn

generateColumnIndices : Int -> List (Maybe Tile) -> List (Maybe Tile, (Int, Int))
generateColumnIndices column tiles =
  map2 (,) tiles (map2 (,) (repeat boardRows column) [0..boardRows-1])

generateBoardIndices : Board -> List (Maybe Tile, (Int, Int))
generateBoardIndices =
  concat << map2 generateColumnIndices [0..boardColumns-1]

listAtIdx : List a -> Int -> a
listAtIdx xs idx = case idx of
                     0 -> badHead xs
                     i -> listAtIdx (badTail xs) (idx - 1)

updateAtIdx : List a -> Int -> a -> List a
updateAtIdx xs idx x =
  let go (xh::xt) idx x proc = case idx of
                                 0 -> proc ++ (x :: xt)
                                 idx -> go xt (idx-1) x (proc ++ [xh])
  in  go xs idx x []

getTileAt : Board -> (Int, Int) -> Maybe Tile
getTileAt b (x,y) = listAtIdx (listAtIdx b x) y

setTileAt : Board -> (Int, Int) -> Maybe Tile -> Board
setTileAt b (x,y) t = updateAtIdx b x <| updateAtIdx (listAtIdx b x) y t

transpose : List (List a) -> List (List a)
transpose matrix = case matrix of
                     [] -> []
                     [] :: xss -> transpose xss
                     (x :: xs) :: xss -> (x :: map badHead xss) :: transpose (xs :: map badTail xss)

liftMaybe : (a -> b) -> Maybe a -> Maybe b
liftMaybe f m = case m of
                  Nothing -> Nothing
                  Just x  -> Just <| f x

intToTile : Int -> Maybe Tile
intToTile = Just << mkTile

columnFromRandomInts : List Int -> List (Maybe Tile)
columnFromRandomInts ints = map intToTile ints ++ repeat (boardRows - length ints) Nothing

boardFromRandomInts : List (List Int) -> Board
boardFromRandomInts ints = map columnFromRandomInts ints

playerHasLost : Board -> Bool
playerHasLost = let isJust x = case x of
                                 Just _ -> True
                                 Nothing -> False
                in  any (isJust << (flip listAtIdx) (boardRows - 1))
