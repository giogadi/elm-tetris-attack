module Board where

boardRows = 4
boardColumns = 4

type ContinuousPosition = Float

data Color = Red | Blue | Green | Yellow
data State = Stationary |
             SwitchingLeft ContinuousPosition |
             SwitchingRight ContinuousPosition
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

getTileAt : Board -> (Int, Int) -> Maybe Tile
getTileAt b (x,y) = listAtIdx (listAtIdx b x) y

liftMaybe : (a -> b) -> Maybe a -> Maybe b
liftMaybe f m = case m of
                  Nothing -> Nothing
                  Just x  -> Just <| f x
