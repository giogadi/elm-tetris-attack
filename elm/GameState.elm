module GameState where

import Board (..)
import UpdateBoard
import Input (..)
import Pseudorandom

data GameState = StartScreen | PlayScreen BoardState | EndScreen

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
    StartScreen -> case input of
                     Spacebar -> PlayScreen <| mkInitialBoardState 1 4
                     otherwise -> StartScreen
    PlayScreen boardState ->
      let {board, cursorIdx, globalScroll, rng, dtOld} = boardState
      in  if playerHasLost board
          then EndScreen
          else PlayScreen <| UpdateBoard.stepBoard (inputToGameInput input) boardState
    EndScreen -> case input of
                   Spacebar -> PlayScreen <| mkInitialBoardState 1 4
                   otherwise -> EndScreen

mkInitialBoardState : Int -> Int -> BoardState
mkInitialBoardState randSeed maxInitColHeight =
  let randColFromNumRows n = Pseudorandom.randomRange (0, numColors - 1) n
      (rowsPerCol, rng) = Pseudorandom.randomRange (1, maxInitColHeight) boardColumns randSeed
      (ints, rng') = Pseudorandom.mapM randColFromNumRows rowsPerCol rng
      randBoard = boardFromRandomInts ints
  in  {board = randBoard, cursorIdx = (0,1), globalScroll = 0.0, rng = rng', dtOld = 0}
