module Slave where

import Board (..)
import DrawBoard (..)
import PortableBoard (..)
import Window
import WebSocket

inStateSignal : Signal (Maybe GameState)
inStateSignal = lift stringToState <| WebSocket.connect "ws://0.0.0.0:9160/slave" <| constant ""

displayMaybeGame : (Int, Int) -> Maybe GameState -> Element
displayMaybeGame w ms = case ms of
                          Just s -> displayGame w s
                          Nothing -> asText "Just a sec..."

main : Signal Element
-- main = lift asText <| WebSocket.connect "ws://0.0.0.0:9160/slave" <| constant ""
main = lift2 displayMaybeGame Window.dimensions inStateSignal
