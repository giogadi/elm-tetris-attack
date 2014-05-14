module GameState where

import Board (..)
import UpdateBoard
import Input (..)

data GameState = StartScreen | PlayScreen BoardState | EndScreen

mkInitialBoardState : BoardState
mkInitialBoardState = {board=mkEmptyBoard, cursorIdx=(0,1), globalScroll=0.0, rng=1, dtOld=0}
-- mkInitialBoardState =
--   let (randomIntList, rng') = Pseudorandom.randomRange (0,numColors-1) (boardRows*boardColumns) <| 1
--       randomBoard = boardFromRandomInts randomIntList
--   in  {board=randomBoard, cursorIdx = (0,1), globalScroll=0.0, rng=rng', dtOld=0}

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
                     Spacebar -> PlayScreen mkInitialBoardState
                     otherwise -> StartScreen
    PlayScreen boardState ->
      let {board, cursorIdx, globalScroll, rng, dtOld} = boardState
      in  if playerHasLost board
          then EndScreen
          else PlayScreen <| UpdateBoard.stepBoard (inputToGameInput input) boardState
    EndScreen -> case input of
                   Spacebar -> PlayScreen mkInitialBoardState
                   otherwise -> EndScreen
