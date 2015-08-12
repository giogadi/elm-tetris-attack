module GameState where

import Board exposing (..)
import Input exposing (..)
import List exposing (..)
import Random
import UpdateBoard

type GameState = StartScreen | PlayScreen BoardState | EndScreen

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
                     Spacebar -> PlayScreen <| mkInitialBoardState (Random.initialSeed 1) 4
                     otherwise -> StartScreen
    PlayScreen boardState ->
      let {board, cursorIdx, globalScroll, rng, dtOld} = boardState
      in  if playerHasLost board
          then EndScreen
          else PlayScreen <| UpdateBoard.stepBoard (inputToGameInput input) boardState
    EndScreen -> case input of
                   Spacebar -> PlayScreen <| mkInitialBoardState (Random.initialSeed 1) 4
                   otherwise -> EndScreen

mkInitialBoardState : Random.Seed -> Int -> BoardState
mkInitialBoardState seed maxInitColHeight =
  let tileRng : Random.Generator Int
      tileRng = Random.int 0 (numColors - 1)
      tileListRng : Int -> Random.Generator (List Int)
      tileListRng n = Random.list n tileRng
      randTileList : Int -> Random.Seed -> (List Int, Random.Seed)
      randTileList n s = Random.generate (tileListRng n) s
      numRowsRng : Random.Generator Int
      numRowsRng = Random.int 1 maxInitColHeight
      (randInitColHeights, seed') =
        Random.generate (Random.list boardColumns numRowsRng) seed
      f : Int -> (List (List Int), Random.Seed) -> (List (List Int), Random.Seed)
      f numRows (cols, currentSeed) =
        let result : (List Int, Random.Seed)
            result = randTileList numRows currentSeed
            (randCol, currentSeed') = result
        in  (randCol :: cols, currentSeed')
      (randBoardInts, seed'') = foldr f ([], seed') randInitColHeights
      randBoard = boardFromRandomInts randBoardInts
  in  {board = randBoard, cursorIdx = (0,1), globalScroll = 0.0, rng = seed'', dtOld = 0}
