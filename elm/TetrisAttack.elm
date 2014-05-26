module TetrisAttack where

import Board (..)
import Window
import GameState (..)
import DrawGame (..)
import Input (..)
import WebSocket

stateSignal : Signal GameState
stateSignal = let stateAndOutputPair = foldp stepGame (StartScreen, RemoteNone) input
                  out = WebSocket.connect "ws://0.0.0.0:9160/send"
                          (lift remoteInputToString <| dropRepeats <| lift snd stateAndOutputPair)
              in  lift fst stateAndOutputPair

main = lift2 displayGame Window.dimensions <| stateSignal
