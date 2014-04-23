module Slave where

import Board (..)
import DrawBoard (..)
import PortableBoard (..)
import Window

port gameStateIn : Signal ([[Maybe (Int, Int, Float, Float)]], (Int, Int))

main : Signal Element
main = lift2 displayGame Window.dimensions (lift fromPortableState gameStateIn)
