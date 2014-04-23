module PortableBoard where

import Board (..)

type PortableTile = (Int, Int, Float, Float)
type PortableBoard = [[Maybe (PortableTile)]]
type PortableState = (PortableBoard, (Int,Int))

toPortableTile : Tile -> PortableTile
toPortableTile (c,s) = let i = intFromColor c in
                       case s of
                         Stationary -> (i,0,0,0)
                         SwitchingLeft x -> (i,1,x,0)
                         SwitchingRight x -> (i,2,x,0)
                         Falling x y -> (i,3,x,y)
                         Fell x y -> (i,4,x,y)
                         Matching x -> (i,5,x,0)

fromPortableTile : PortableTile -> Tile
fromPortableTile (i,s,x,y) = let c = colorFromInt i in
                             case s of
                               0 -> (c, Stationary)
                               1 -> (c, SwitchingLeft x)
                               2 -> (c, SwitchingRight x)
                               3 -> (c, Falling x y)
                               4 -> (c, Fell x y)
                               5 -> (c, Matching x)

toPortableBoard : Board -> PortableBoard
toPortableBoard = map (map (liftMaybe toPortableTile))

fromPortableBoard : PortableBoard -> Board
fromPortableBoard = map (map (liftMaybe fromPortableTile))

toPortableState : GameState -> PortableState
toPortableState s = (toPortableBoard s.board, s.cursorIdx)

fromPortableState : PortableState -> GameState
fromPortableState (b, c) = {board = fromPortableBoard b, cursorIdx=c, dtOld=0}
