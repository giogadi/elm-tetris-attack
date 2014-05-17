module Slave where

import Board (..)
import GameState (..)
import DrawGame (..)
import PortableBoard (..)
import Window
import WebSocket

stateSignal : Signal GameState
stateSignal =
  foldp stepGame StartScreen <| lift stringToInput <| WebSocket.connect "ws://0.0.0.0:9160/slave" <| constant ""

-- inStateSignal : Signal (Maybe GameState)
-- inStateSignal = lift stringToState <| WebSocket.connect "ws://0.0.0.0:9160/slave" <| constant ""

-- displayMaybeGame : (Int, Int) -> Maybe GameState -> Element
-- displayMaybeGame w ms = case ms of
--                           Just s -> displayGame w s
--                           Nothing -> asText "Just a sec..."

main : Signal Element
-- main = lift2 displayMaybeGame Window.dimensions inStateSignal
main = lift2 displayGame Window.dimensions <| stateSignal
