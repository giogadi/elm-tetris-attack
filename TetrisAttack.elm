module TetrisAttack where

import Board exposing (..)
import Window
import GameState exposing (..)
import DrawGame exposing (..)
import Input exposing (..)
import Signal exposing (..)

stateSignal : Signal GameState
stateSignal = foldp stepGame StartScreen input

main = map2 displayGame Window.dimensions <| stateSignal
