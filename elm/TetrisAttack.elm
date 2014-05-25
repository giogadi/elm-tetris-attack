module TetrisAttack where

import Board (..)
import PortableBoard (..)
import Window
import GameState (..)
import DrawGame (..)
import WebSocket
import Input (..)

stateSignal : Signal GameState
stateSignal = foldp stepGame (StartScreen 1) input

-- outSignal : Signal String
-- outSignal = lift stateToString <| stateSignal

-- stateAndInSignal : Signal (GameState, String)
-- stateAndInSignal = lift2 (,) stateSignal <| WebSocket.connect "ws://0.0.0.0:9160" outSignal

-- main = lift2 displayGame Window.dimensions <| lift fst stateAndInSignal
main = lift2 displayGame Window.dimensions <| stateSignal
