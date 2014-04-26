module Board ( boardRows
             , boardColumns
             , TileColor (..)
             , TileState (..)
             , Tile
             , Board
             , GameState (..)
             , generateBoardIndices
             , Time
             , mkTile
             , mkRandomBoard
             , randomTiles
             ) where

import Haste

boardRows = 11
boardColumns = 7

type ContinuousPosition = Double
type ContinuousSpeed = Double
type Time = Double

data TileColor = Red | Blue | Green | Yellow deriving (Enum, Show)
data TileState = Stationary |
                 SwitchingLeft ContinuousPosition |
                 SwitchingRight ContinuousPosition |
                 Falling ContinuousPosition ContinuousSpeed |
                 Fell ContinuousPosition ContinuousSpeed |
                 Matching Double
type Tile = (TileColor, TileState)

mkTile :: TileColor -> Tile
mkTile c = (c, Stationary)

type Board = [[Maybe Tile]]

data GameState = GameState
                 { _board :: Board
                 , _cursorIdx :: (Int, Int) }

mkEmptyColumn :: [Maybe Tile]
mkEmptyColumn = replicate boardRows Nothing

mkEmptyBoard :: Board
mkEmptyBoard = replicate boardColumns $ mkEmptyColumn

generateColumnIndices :: Int -> [Maybe Tile] -> [(Maybe Tile, (Int, Int))]
generateColumnIndices column tiles = zip tiles (zip (replicate boardRows column) [0..boardRows-1])

generateBoardIndices :: Board -> [(Maybe Tile, (Int, Int))]
generateBoardIndices = concat . zipWith generateColumnIndices [0..boardColumns-1]

updateAtIdx :: [a] -> Int -> a -> [a]
updateAtIdx xs idx x = let (xs1, _:xs2) = splitAt idx xs
                       in  xs1 ++ (x : xs2)

getTileAt :: Board -> (Int, Int) -> Maybe Tile
getTileAt b (x,y) = (b !! x) !! y

setTileAt :: Board -> (Int, Int) -> Maybe Tile -> Board
setTileAt b (x,y) t = updateAtIdx b x $ updateAtIdx (b !! x) y t

instance Random TileColor where
  randomR (t1, t2) s = let (i, s') = randomR (fromEnum t1, fromEnum t2) s
                       in  (toEnum i, s')

randomTiles :: Seed -> [Tile]
randomTiles s = map mkTile $ randomRs (Red, Yellow) s

mkRandomBoard :: Seed -> Board
mkRandomBoard s = let tiles = take (boardColumns * boardRows) $ randomTiles s
                      go procd [] 0 = procd
                      go procd ts colsLeft = let (ts1, ts2) = splitAt boardRows ts
                                             in  go (map Just ts1 : procd) ts2 (colsLeft - 1)
                  in go [] tiles boardColumns
