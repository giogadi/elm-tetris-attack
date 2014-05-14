module Input where

import Keyboard

onUp : Signal Bool -> Signal ()
onUp = lift (\_ -> ()) . keepIf id False . dropRepeats

onDown : Signal Bool -> Signal ()
onDown =  lift (\_ -> ()) . keepIf not False . dropRepeats

onPressed : Keyboard.KeyCode -> Signal ()
onPressed = onUp . Keyboard.isDown

onReleased : Keyboard.KeyCode -> Signal ()
onReleased = onDown . Keyboard.isDown

data Input = None |
             LeftArrow |
             RightArrow |
             UpArrow |
             DownArrow |
             Spacebar |
             NewTimeStep Time

keyPressed : Keyboard.KeyCode -> Input -> Signal Input
keyPressed key action = merge (constant None) <| always action <~ onPressed key

input : Signal Input
input = let keyPressInput = merges <| zipWith keyPressed
                                        [37, 39, 40, 38, 32]
                                        [LeftArrow, RightArrow, DownArrow, UpArrow, Spacebar]
        in  merge keyPressInput <| NewTimeStep <~ fps 60
