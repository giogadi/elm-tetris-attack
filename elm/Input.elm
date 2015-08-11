module Input where

import Keyboard
import List
import Signal (..)
import Time (..)

onUp : Signal Bool -> Signal ()
onUp = map (\_ -> ()) << keepIf identity False << dropRepeats

onDown : Signal Bool -> Signal ()
onDown =  map (\_ -> ()) << keepIf not False << dropRepeats

onPressed : Keyboard.KeyCode -> Signal ()
onPressed = onUp << Keyboard.isDown

onReleased : Keyboard.KeyCode -> Signal ()
onReleased = onDown << Keyboard.isDown

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
        --in  merge keyPressInput <| NewTimeStep <~ fps 60
        in  merge (NewTimeStep <~ fps 60) keyPressInput
