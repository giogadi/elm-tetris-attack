module Board where

boardRows = 6
boardColumns = 4

type ContinuousPosition = Float
type ContinuousSpeed = Float

data Color = Red | Blue | Green | Yellow
data State = Stationary |
             SwitchingLeft ContinuousPosition |
             SwitchingRight ContinuousPosition |
             Falling ContinuousPosition ContinuousSpeed |
             Fell ContinuousSpeed
type Tile = (Color, State)

colorToString : Color -> String
colorToString c = case c of
                    Red -> "red"
                    Blue -> "blue"
                    Green -> "green"
                    yellow -> "yellow"

mkTile : Color -> Tile
mkTile c = (c, Stationary)

type Board = [[Maybe Tile]]

type GameState = { board:Board, cursorIdx:(Int,Int), dtOld:Time }

mkEmptyColumn : [Maybe Tile]
mkEmptyColumn = repeat boardRows Nothing

mkEmptyBoard : Board
mkEmptyBoard = repeat boardColumns <| mkEmptyColumn

generateColumnIndices : Int -> [Maybe Tile] -> [(Maybe Tile, (Int, Int))]
generateColumnIndices column tiles = zip tiles (zip (repeat boardRows column) [0..boardRows-1])

generateBoardIndices : Board -> [(Maybe Tile, (Int, Int))]
generateBoardIndices = concat . zipWith generateColumnIndices [0..boardColumns-1]

listAtIdx : [a] -> Int -> a
listAtIdx xs idx = case idx of
                     0 -> head xs
                     i -> listAtIdx (tail xs) (idx - 1)

updateAtIdx : [a] -> Int -> a -> [a]
updateAtIdx xs idx x =
  let go (xh::xt) idx x proc = case idx of
                                 0 -> proc ++ (x :: xt)
                                 idx -> go xt (idx-1) x (proc ++ [xh])
  in  go xs idx x []

getTileAt : Board -> (Int, Int) -> Maybe Tile
getTileAt b (x,y) = listAtIdx (listAtIdx b x) y

setTileAt : Board -> (Int, Int) -> Maybe Tile -> Board
setTileAt b (x,y) t = updateAtIdx b x <| updateAtIdx (listAtIdx b x) y t

liftMaybe : (a -> b) -> Maybe a -> Maybe b
liftMaybe f m = case m of
                  Nothing -> Nothing
                  Just x  -> Just <| f x
