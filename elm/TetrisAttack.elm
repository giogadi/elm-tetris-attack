module TetrisAttack where

import Board (..)
import Window
import GameState (..)
import DrawGame (..)
import Input (..)
import WebSocket

stateSignal : Signal GameState
stateSignal = let augmentedStateSig = foldp stepGame (StartScreen, RemoteNone, 0.0) input
                  fst3 (x, _, _) = x
                  snd3 (_, x, _) = x
                  out = WebSocket.connect "ws://0.0.0.0:9160/send"
                          (lift remoteInputToString <| dropRepeats <| lift snd3 augmentedStateSig)
              in  lift fst3 augmentedStateSig

main = lift2 displayGame Window.dimensions <| stateSignal
