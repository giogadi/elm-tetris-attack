module GameState where

import Board (..)
import UpdateBoard
import Input (..)
import Pseudorandom

data GameState = StartScreen RandSeed |
                 PlayScreen BoardState |
                 EndScreen RandSeed

inputToGameInput : Input -> UpdateBoard.GameInput
inputToGameInput input = case input of
                           None -> UpdateBoard.None
                           LeftArrow -> UpdateBoard.CursorLeft
                           RightArrow -> UpdateBoard.CursorRight
                           UpArrow -> UpdateBoard.CursorUp
                           DownArrow -> UpdateBoard.CursorDown
                           Spacebar -> UpdateBoard.Swap
                           NewTimeStep t -> UpdateBoard.NewTimeStep t

stepGame : Input -> GameState -> GameState
stepGame input state =
  case state of
    StartScreen rng -> case input of
                         Spacebar -> PlayScreen <| mkInitialBoardState rng 4
                         otherwise -> StartScreen rng
    PlayScreen boardState ->
      let {board, cursorIdx, globalScroll, rng, dtOld} = boardState
      in  if playerHasLost board
          then EndScreen rng
          else PlayScreen <| UpdateBoard.stepBoard (inputToGameInput input) boardState
    EndScreen rng -> case input of
                       Spacebar -> PlayScreen <| mkInitialBoardState rng 4
                       otherwise -> EndScreen rng

mkInitialBoardState : RandSeed -> Int -> BoardState
mkInitialBoardState seed maxInitColHeight =
  let randColFromNumRows n = Pseudorandom.randomRange (0, numColors - 1) n
      (rowsPerCol, rng) = Pseudorandom.randomRange (1, maxInitColHeight) boardColumns seed
      (ints, rng') = Pseudorandom.mapM randColFromNumRows rowsPerCol rng
      randBoard = boardFromRandomInts ints
  in  {board = randBoard, cursorIdx = (0,1), globalScroll = 0.0, rng = rng', dtOld = 0}
