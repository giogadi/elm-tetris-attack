import Board (..)
import DrawBoard (..)
import UpdateBoard (..)
import Window
import Pseudorandom

mkInitialBoard = boardFromRandomInts . fst <| Pseudorandom.randomRange (0,3) (boardRows*boardColumns) <| 1
mkInitialState = {board=mkInitialBoard, cursorIdx=(0,0), dtOld=0}

main = lift2 displayGame Window.dimensions (foldp stepGame mkInitialState input)
