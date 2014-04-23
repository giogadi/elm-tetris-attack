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

import qualified Network.Wai
import qualified Network.WebSockets as WS
import qualified Network.Wai.Handler.WebSockets as WaiWS
import Web.Scotty
import qualified Network.Wai.Handler.Warp as Warp

type ServerState = [WS.Connection]

addSlave :: WS.Connection -> ServerState -> ServerState
addSlave conn state = conn : state

broadcast :: WS.Connection -> MVar ServerState -> IO ()
broadcast src state = forever $ do
  msg <- WS.receiveData src :: IO Text
  slaves <- readMVar state
  forM_ slaves $ flip WS.sendTextData $ msg

stupid :: WS.Connection -> IO ()
stupid conn = forever $ ((WS.receiveData conn :: IO Text) >> return ())

application :: MVar ServerState -> WS.ServerApp
application state pending = do
  let service = WS.pendingRequest pending
  if (unpack $ WS.requestPath service) == "/slave"
    then do
           conn <- WS.acceptRequest pending
           liftIO $ modifyMVar_ state $ return . addSlave conn
           stupid conn -- wtf lol
    else liftIO $ WS.acceptRequest pending >>= (flip broadcast $ state)

failPageServe :: IO Network.Wai.Application
failPageServe = scottyApp $ notFound $ html "WHAT DO YOU WANT FROM ME"

main :: IO ()
main = do
  state <- newMVar []
  let wsApp = liftM (WaiWS.websocketsOr WS.defaultConnectionOptions (application state))
                failPageServe
  Warp.run 9160 =<< wsApp
