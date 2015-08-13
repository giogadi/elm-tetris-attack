module Util where

import Debug

badHead : List a -> a
badHead xs = case xs of
               (x :: _) -> x
               _ -> Debug.crash "called badHead on empty list!"

badTail : List a -> List a
badTail xs = case xs of
               (_ :: xt) -> xt
               _ -> Debug.crash "called badTail on empty list!"
