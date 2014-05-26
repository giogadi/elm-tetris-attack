module GameState where

import Board (..)
import UpdateBoard
import Input (..)
import Pseudorandom

data GameState = StartScreen RandSeed |
                 PlayScreen BoardState BoardState |
                 EndScreen RandSeed

keyInputToBoardInput : KeyInput -> UpdateBoard.GameInput
keyInputToBoardInput keyInput = case keyInput of
                                  None -> UpdateBoard.None
                                  LeftArrow -> UpdateBoard.CursorLeft
                                  RightArrow -> UpdateBoard.CursorRight
                                  UpArrow -> UpdateBoard.CursorUp
                                  DownArrow -> UpdateBoard.CursorDown
                                  Spacebar -> UpdateBoard.Swap

inputToBoardInputs : Input -> (UpdateBoard.GameInput, UpdateBoard.GameInput)
inputToBoardInputs i = case i of
                         Local k  -> (keyInputToBoardInput k, UpdateBoard.None)
                         Remote (RemoteKey k) -> (UpdateBoard.None, keyInputToBoardInput k)
                         NewTimeStep dt ->  (UpdateBoard.NewTimeStep dt,
                                             UpdateBoard.NewTimeStep dt)
                         otherwise -> (UpdateBoard.None, UpdateBoard.None)

stepGame : Input -> (GameState, RemoteInput) -> (GameState, RemoteInput)
stepGame gameInput (state, _) =
  case state of
    StartScreen rng -> case gameInput of
                         Remote Ready -> (PlayScreen
                                            (mkInitialBoardState rng 4)
                                            (mkInitialBoardState rng 4),
                                          RemoteNone)
                         otherwise -> (StartScreen rng, RemoteNone)
    PlayScreen boardStateA boardStateB ->
      if playerHasLost boardStateA.board
      then (EndScreen boardStateA.rng, GameOver)
      else let (inputA, inputB) = inputToBoardInputs gameInput
           in  (PlayScreen (UpdateBoard.stepBoard inputA boardStateA)
                           (UpdateBoard.stepBoard inputB boardStateB),
                case gameInput of
                  Local k -> RemoteKey k
                  otherwise -> RemoteNone)
    EndScreen rng -> case gameInput of
                       Remote Ready -> (PlayScreen
                                          (mkInitialBoardState rng 4)
                                          (mkInitialBoardState rng 4),
                                        RemoteNone)
                       otherwise -> (EndScreen rng, RemoteNone)

mkInitialBoardState : RandSeed -> Int -> BoardState
mkInitialBoardState seed maxInitColHeight =
  let randColFromNumRows n = Pseudorandom.randomRange (0, numColors - 1) n
      (rowsPerCol, rng) = Pseudorandom.randomRange (1, maxInitColHeight) boardColumns seed
      (ints, rng') = Pseudorandom.mapM randColFromNumRows rowsPerCol rng
      randBoard = boardFromRandomInts ints
  in  {board = randBoard, cursorIdx = (0,1), globalScroll = 0.0, rng = rng', dtOld = 0}
