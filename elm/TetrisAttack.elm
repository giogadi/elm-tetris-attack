module TetrisAttack where

import Board (..)
import DrawBoard (..)
import UpdateBoard (..)
import PortableBoard (..)
import Window
import Pseudorandom
import WebSocket

mkInitialBoard = boardFromRandomInts . fst <| Pseudorandom.randomRange (0,3) (boardRows*boardColumns) <| 1
mkInitialState =
  let (randomIntList, rng') = Pseudorandom.randomRange (0,3) (boardRows*boardColumns) <| 1
      randomBoard = boardFromRandomInts randomIntList
  in  {board=randomBoard, cursorIdx = (0,1), globalScroll=0.0, rng=rng', dtOld=0}

stateSignal : Signal GameState
stateSignal = foldp stepGame mkInitialState input

outSignal : Signal String
outSignal = lift stateToString <| stateSignal

stateAndInSignal : Signal (GameState, String)
stateAndInSignal = lift2 (,) stateSignal <| WebSocket.connect "ws://0.0.0.0:9160" outSignal

main = lift2 displayGame Window.dimensions <| lift fst stateAndInSignal
