{-# LANGUAGE OverloadedStrings #-}
import Data.Char (isPunctuation, isSpace)
import Data.Monoid (mappend, mconcat)
import Data.Text (Text)
import Control.Exception (finally)
import Control.Monad (forM_, forever, (=<<), liftM, when)
import Control.Concurrent (MVar, newMVar, modifyMVar_, modifyMVar, readMVar, putMVar)
import Control.Monad.IO.Class (liftIO)
import qualified Data.Text as T
import qualified Data.Text.IO as T
import Data.ByteString.Char8 (unpack)
import Data.Maybe (isJust, fromJust)
import Control.Concurrent (forkIO)
import System.Random

import qualified Network.Wai
import qualified Network.WebSockets as WS
import qualified Network.Wai.Handler.WebSockets as WaiWS
import Web.Scotty
import qualified Network.Wai.Handler.Warp as Warp

type ServerState = ((Maybe WS.Connection, Maybe WS.Connection),
                    (Maybe WS.Connection, Maybe WS.Connection))

data WhichConn = FromConnA | ToConnA | FromConnB | ToConnB

disconnect :: MVar ServerState -> WhichConn -> IO ()
disconnect state whichConn = modifyMVar_ state (return . discon whichConn)
  where discon FromConnA ((_, tca), cb) = ((Nothing,tca), cb)
        discon ToConnA ((fca, _), cb) = ((fca, Nothing), cb)
        discon FromConnB (ca, (_, tcb)) = (ca, (Nothing, tcb))
        discon ToConnB (ca, (fca, _)) = (ca, (fca, Nothing))

serveLoop :: MVar ServerState -> WhichConn -> IO ()
-- Apparently the connecting must always be receiving or sending data to stay alive?
serveLoop s ToConnA = flip finally (disconnect s ToConnA) $ forever $ do
                        ((_, tca), _) <- readMVar s
                        when (isJust tca) ((WS.receiveData (fromJust tca) :: IO Text) >> return ())
serveLoop s ToConnB = flip finally (disconnect s ToConnA) $ forever $ do
                        (_, (_,tcb)) <- readMVar s
                        when (isJust tcb) ((WS.receiveData (fromJust tcb) :: IO Text) >> return ())

serveLoop state which = flip finally (disconnect state which) $ forever $ do
  ((fca, tca), (fcb, tcb)) <- readMVar state
  when (isJust fca && isJust tca &&
        isJust fcb && isJust tcb) $
    let (Just cFrom, Just cTo) = case which of
                                   FromConnA -> (fca, tcb)
                                   FromConnB -> (fcb, tca)
    in  do msg <- WS.receiveData cFrom :: IO Text
           WS.sendTextData cTo msg

tryConnect :: WS.PendingConnection -> ServerState -> IO (ServerState, Maybe WhichConn)
tryConnect pending s = let service = WS.pendingRequest pending
                       in  print (unpack $ WS.requestPath service) >>
                           if (unpack $ WS.requestPath service) == "/recv"
                           then case s of
                                  ((fca, Nothing), cb) -> do
                                    liftIO $ print "to conn a"
                                    c <- WS.acceptRequest pending
                                    return (((fca, Just c), cb), Just ToConnA)
                                  (ca, (fcb, Nothing)) -> do
                                    liftIO $ print "to conn b"
                                    c <- WS.acceptRequest pending
                                    return ((ca, (fcb, Just c)), Just ToConnB)
                                  otherwise -> return (s, Nothing)
                           else case s of
                                  ((Nothing, tca), cb) -> do
                                    liftIO $ print "from conn a"
                                    c <- WS.acceptRequest pending
                                    return (((Just c, tca), cb), Just FromConnA)
                                  (ca, (Nothing, tcb)) -> do
                                    liftIO $ print "from conn b"
                                    c <- WS.acceptRequest pending
                                    return ((ca, (Just c, tcb)), Just FromConnB)
                                  otherwise -> return (s, Nothing)

application :: MVar ServerState -> WS.ServerApp
application state pending = do
  maybeWhich <- liftIO $ modifyMVar state (tryConnect pending)
  when (isJust maybeWhich) $ do
    ((fca, tca), (fcb, tcb)) <- readMVar state
    when (isJust fca && isJust tca &&
          isJust fcb && isJust tcb) $ do
      randSeed <- getStdRandom random :: IO Int
      let readyJsonStr = T.pack ("[0," ++ show randSeed ++ "]" :: String)
      WS.sendTextData (fromJust tca) readyJsonStr
      WS.sendTextData (fromJust tcb) readyJsonStr
    serveLoop state (fromJust maybeWhich)
    return ()

failPageServe :: IO Network.Wai.Application
failPageServe = scottyApp $ notFound $ html "WHAT DO YOU WANT FROM ME"

main :: IO ()
main = do
  state <- newMVar ((Nothing, Nothing), (Nothing, Nothing))
  let wsApp = liftM (WaiWS.websocketsOr WS.defaultConnectionOptions (application state))
                failPageServe
  Warp.run 9160 =<< wsApp
