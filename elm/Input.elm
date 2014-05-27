module Input where

import Keyboard
import Json (..)
import WebSocket
import Board (RandSeed, BoardState)
import PortableBoard

onUp : Signal Bool -> Signal ()
onUp = lift (\_ -> ()) . keepIf id False . dropRepeats

onDown : Signal Bool -> Signal ()
onDown =  lift (\_ -> ()) . keepIf not False . dropRepeats

onPressed : Keyboard.KeyCode -> Signal ()
onPressed = onUp . Keyboard.isDown

onReleased : Keyboard.KeyCode -> Signal ()
onReleased = onDown . Keyboard.isDown

data KeyInput = None |
                LeftArrow |
                RightArrow |
                UpArrow |
                DownArrow |
                Spacebar

keyPressed : Keyboard.KeyCode -> KeyInput -> Signal KeyInput
keyPressed key action = merge (constant None) <| always action <~ onPressed key

keyPressInput : Signal KeyInput
keyPressInput = merges <| zipWith keyPressed
                            [37, 39, 40, 38, 32]
                            [LeftArrow, RightArrow, DownArrow, UpArrow, Spacebar]

keyInputToJson : KeyInput -> Value
keyInputToJson i = case i of
                     None -> Number 0
                     LeftArrow -> Number 1
                     RightArrow -> Number 2
                     UpArrow -> Number 3
                     DownArrow -> Number 4
                     Spacebar -> Number 5

jsonToKeyInput : Value -> KeyInput
jsonToKeyInput (Number x) = case x of
                              0 -> None
                              1 -> LeftArrow
                              2 -> RightArrow
                              3 -> UpArrow
                              4 -> DownArrow
                              5 -> Spacebar

data RemoteInput = Ready RandSeed |
                   GameOver |
                   RemoteKey KeyInput |
                   RemoteNone |
                   SyncState BoardState

remoteInputToJson : RemoteInput -> Value
remoteInputToJson i = case i of
                        Ready s -> Array [Number 0, Number <| toFloat s]
                        GameOver -> Array [Number 1]
                        RemoteKey k -> Array [Number 2, keyInputToJson k]
                        RemoteNone -> Array [Number 3]
                        SyncState s -> Array [Number 4, PortableBoard.stateToJson s]

jsonToRemoteInput : Value -> RemoteInput
jsonToRemoteInput (Array (Number x :: xs)) = case x of
                                               0 -> let ((Number s) :: []) = xs
                                                    in  Ready <| round s
                                               1 -> GameOver
                                               2 -> let (k :: []) = xs
                                                    in  RemoteKey <| jsonToKeyInput k
                                               3 -> RemoteNone
                                               4 -> let (s :: []) = xs
                                                    in  SyncState <| PortableBoard.jsonToState s

remoteInputToString : RemoteInput -> String
remoteInputToString i = toString "" <| remoteInputToJson i

stringToRemoteInput : String -> RemoteInput
stringToRemoteInput str = case fromString str of
                            Just jsonV -> jsonToRemoteInput jsonV
                            Nothing -> RemoteNone

data Input = Local KeyInput | Remote RemoteInput | NewTimeStep Time

remoteInput : Signal RemoteInput
remoteInput = lift stringToRemoteInput <| WebSocket.connect "ws://0.0.0.0:9160/recv" <| constant ""

input : Signal Input
input = merges [lift Remote remoteInput,
                lift Local keyPressInput,
                lift NewTimeStep <| fps 60]
