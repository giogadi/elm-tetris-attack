module Input where

import Keyboard
import Json (..)
import WebSocket

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

-- TODO maybe have Ready also include a random seed from the server
data RemoteInput = Ready | GameOver | RemoteKey KeyInput | RemoteNone

remoteInputToJson : RemoteInput -> Value
remoteInputToJson i = case i of
                        Ready -> Array [Number 0]
                        GameOver -> Array [Number 1]
                        RemoteKey k -> Array [Number 2, keyInputToJson k]
                        RemoteNone -> Array [Number 3]

jsonToRemoteInput : Value -> RemoteInput
jsonToRemoteInput (Array (Number x :: xs)) = case x of
                                               0 -> Ready
                                               1 -> GameOver
                                               2 -> let (k :: []) = xs
                                                    in  RemoteKey <| jsonToKeyInput k
                                               3 -> RemoteNone

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

-- inOutKeyInput : Signal KeyInput
-- inOutKeyInput = let pair = lift2 (,) keyPressInput <| WebSocket.connect "ws://0.0.0.0:9160" <| lift keyInputToString keyPressInput
--                 in  lift fst pair

-- remoteKeyInput : Signal KeyInput
-- remoteKeyInput = lift stringToKeyInput <| WebSocket.connect "ws://0.0.0.0:9160/slave" <| constant ""

-- input : Signal Input
-- input = merges [lift LocalKey inOutKeyInput,
--                 lift RemoteKey remoteKeyInput,
--                 lift NewTimeStep <| fps 60]
-- input = merge (lift2 Key keyPressInput remoteKeyInput) <| lift NewTimeStep <| fps 60
