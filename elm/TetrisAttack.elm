module TetrisAttack where

import Board exposing (..)
-- import PortableBoard exposing (..)
import Window
import GameState exposing (..)
import DrawGame exposing (..)
-- import WebSocket
import Input exposing (..)
import Signal exposing (..)

stateSignal : Signal GameState
stateSignal = foldp stepGame StartScreen input

-- outSignal : Signal String
-- outSignal = lift stateToString <| stateSignal

-- stateAndInSignal : Signal (GameState, String)
-- stateAndInSignal = lift2 (,) stateSignal <| WebSocket.connect "ws://0.0.0.0:9160" outSignal

-- main = lift2 displayGame Window.dimensions <| lift fst stateAndInSignal
main = map2 displayGame Window.dimensions <| stateSignal
