module GameState where

import Board (..)
import UpdateBoard
import Input (..)
import Pseudorandom

data GameState = StartScreen |
                 PlayScreen BoardState BoardState |
                 EndScreen

keyInputToBoardInput : KeyInput -> UpdateBoard.GameInput
keyInputToBoardInput keyInput = case keyInput of
                                  None -> UpdateBoard.None
                                  LeftArrow -> UpdateBoard.CursorLeft
                                  RightArrow -> UpdateBoard.CursorRight
                                  UpArrow -> UpdateBoard.CursorUp
                                  DownArrow -> UpdateBoard.CursorDown
                                  Spacebar -> UpdateBoard.Swap

inputToNewBoards : Input -> (BoardState, BoardState) -> (BoardState, BoardState)
inputToNewBoards i (bA, bB) =
  case i of
    Remote (SyncState s) -> (UpdateBoard.stepBoard UpdateBoard.None bA, s)
    Remote (RemoteKey k) -> (UpdateBoard.stepBoard UpdateBoard.None bA,
                             UpdateBoard.stepBoard (keyInputToBoardInput k) bB)
    Local k -> (UpdateBoard.stepBoard (keyInputToBoardInput k) bA,
                UpdateBoard.stepBoard UpdateBoard.None bB)
    NewTimeStep dt -> (UpdateBoard.stepBoard (UpdateBoard.NewTimeStep dt) bA,
                       UpdateBoard.stepBoard (UpdateBoard.NewTimeStep dt) bB)
    otherwise -> (UpdateBoard.stepBoard UpdateBoard.None bA,
                  UpdateBoard.stepBoard UpdateBoard.None bB)

secondsPerStateSync : Time
secondsPerStateSync = 1.0

stepGame : Input -> (GameState, RemoteInput, Time) -> (GameState, RemoteInput, Time)
stepGame gameInput (state, _, tSinceLastSync) =
  case state of
    StartScreen -> case gameInput of
                     Remote (Ready rng) -> (PlayScreen
                                              (mkInitialBoardState rng 4)
                                              (mkInitialBoardState rng 4),
                                            RemoteNone,
                                            0.0)
                     otherwise -> (StartScreen, RemoteNone, 0.0)
    PlayScreen boardStateA boardStateB ->
      if playerHasLost boardStateA.board || gameInput == Remote GameOver
      then (EndScreen, GameOver, 0.0)
      else let (newBoardA, newBoardB) = inputToNewBoards gameInput (boardStateA, boardStateB)
               (remoteOut, newT) = if tSinceLastSync > secondsPerStateSync
                                   then (SyncState newBoardA, 0.0)
                                   else let t = tSinceLastSync + inSeconds newBoardA.dtOld
                                        in  case gameInput of
                                              Local k -> (RemoteKey k, t)
                                              otherwise -> (RemoteNone, t)
           in  (PlayScreen newBoardA newBoardB, remoteOut, newT)
    EndScreen -> case gameInput of
                   Remote (Ready rng) -> (PlayScreen
                                            (mkInitialBoardState rng 4)
                                            (mkInitialBoardState rng 4),
                                          RemoteNone,
                                          0.0)
                   otherwise -> (EndScreen, RemoteNone, 0.0)

mkInitialBoardState : RandSeed -> Int -> BoardState
mkInitialBoardState seed maxInitColHeight =
  let randColFromNumRows n = Pseudorandom.randomRange (0, numColors - 1) n
      (rowsPerCol, rng) = Pseudorandom.randomRange (1, maxInitColHeight) boardColumns seed
      (ints, rng') = Pseudorandom.mapM randColFromNumRows rowsPerCol rng
      randBoard = boardFromRandomInts ints
  in  {board = randBoard, cursorIdx = (0,1), globalScroll = 0.0, rng = rng', dtOld = 0}
