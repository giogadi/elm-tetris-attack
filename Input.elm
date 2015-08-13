module Input where

import Keyboard
import List
import Signal exposing (..)
import Time exposing (..)

onTrue : Signal Bool -> Signal ()
onTrue = map (\_ -> ()) << filter identity False << dropRepeats

onFalse : Signal Bool -> Signal ()
onFalse = map (\_ -> ()) << filter not False << dropRepeats

onPressed : Keyboard.KeyCode -> Signal ()
onPressed = onTrue << Keyboard.isDown

onReleased : Keyboard.KeyCode -> Signal ()
onReleased = onFalse << Keyboard.isDown

type Input = None |
             LeftArrow |
             RightArrow |
             UpArrow |
             DownArrow |
             Spacebar |
             NewTimeStep Time

keyPressed : Keyboard.KeyCode -> Input -> Signal Input
keyPressed key action = merge (constant None) <| always action <~ onPressed key

input : Signal Input
input = let keyPressInput =
              mergeMany <| List.map2 keyPressed
                             [37, 39, 40, 38, 32]
                             [LeftArrow, RightArrow, DownArrow, UpArrow, Spacebar]
        in  merge (NewTimeStep <~ fps 60) keyPressInput
