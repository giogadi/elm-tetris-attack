module TetrisAttack where

import Board (..)
import DrawBoard (..)
import UpdateBoard (..)
import PortableBoard (..)
import Window
import Pseudorandom

port gameStateOut : Signal ([[Maybe (Int, Int, Float, Float)]], (Int, Int))
port gameStateOut = lift toPortableState (foldp stepGame mkInitialState input)

mkInitialBoard = boardFromRandomInts . fst <| Pseudorandom.randomRange (0,3) (boardRows*boardColumns) <| 1
mkInitialState = {board=mkInitialBoard, cursorIdx=(0,0), dtOld=0}

main = lift2 displayGame Window.dimensions ((lift fromPortableState) gameStateOut)
