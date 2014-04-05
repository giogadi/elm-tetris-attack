import Board (..)
import DrawBoard (..)
import UpdateBoard (..)
import Window

mkTestBoard : Board
mkTestBoard = [[Just (mkTile Red), Just (mkTile Blue), Just (mkTile Red), Just (mkTile Blue)],
               [Just (mkTile Green), Nothing, Nothing, Nothing],
               [Just (mkTile Yellow), Nothing, Nothing, Nothing],
               [Just (mkTile Blue), Just (mkTile Yellow), Nothing, Nothing]]

mkInitialState : GameState
mkInitialState = {board=mkTestBoard, cursorIdx=(0,0), dtOld=0}

-- main = lift2 displayGame Window.dimensions (foldp stepGame mkInitialState input)

-- TESTING

mkTestBoardFalling : Board
mkTestBoardFalling = [[Just (mkTile Red), Just (mkTile Blue), Just (mkTile Red), Just (mkTile Blue), Just (mkTile Red), Just (mkTile Blue)],
                      [Nothing, Just (mkTile Green), Nothing, Nothing, Nothing, Nothing],
                      [Just (mkTile Yellow), Nothing, Nothing, Nothing, Nothing, Nothing],
                      [Just (mkTile Blue), Just (mkTile Yellow), Nothing, Nothing, Nothing, Nothing]]

mkInitialStateFalling : GameState
mkInitialStateFalling = {board=mkTestBoardFalling, cursorIdx=(0,0), dtOld=0}

mkTestBoardMatch : Board
mkTestBoardMatch = [[Just (mkTile Red), Just (mkTile Blue), Just (mkTile Blue), Just (mkTile Red), Just (mkTile Red), Just (mkTile Blue)],
                    [Just (mkTile Blue), Just (mkTile Green), Nothing, Nothing, Nothing, Nothing],
                    [Just (mkTile Red), Nothing, Nothing, Nothing, Nothing, Nothing],
                    [Just (mkTile Red), Just (mkTile Yellow), Nothing, Nothing, Nothing, Nothing]]

mkInitialStateMatching = {board=mkTestBoardMatch, cursorIdx=(0,0), dtOld=0}

main = lift2 displayGame Window.dimensions (foldp stepGame mkInitialStateMatching input)
