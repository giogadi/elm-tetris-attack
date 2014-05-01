module TetrisAttack where

import Board (..)
import DrawBoard (..)
import UpdateBoard (..)
import PortableBoard (..)
import Window
import Pseudorandom
import WebSocket

mkInitialBoard = boardFromRandomInts . fst <| Pseudorandom.randomRange (0,3) (boardRows*boardColumns) <| 1
mkInitialState = {board=mkInitialBoard, cursorIdx=(0,0), dtOld=0}

stateSignal : Signal GameState
stateSignal = foldp stepGame mkInitialState input

outSignal : Signal String
outSignal = lift stateToString <| stateSignal

stateAndInSignal : Signal (GameState, String)
stateAndInSignal = lift2 (,) stateSignal <| WebSocket.connect "ws://0.0.0.0:9160" outSignal

main = lift2 displayGame Window.dimensions <| lift fst stateAndInSignal
