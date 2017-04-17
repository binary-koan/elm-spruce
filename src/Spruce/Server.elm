module Spruce.Server exposing (..)

import Process
import Task exposing (Task)
import Native.Spruce
import Spruce.Middleware exposing (..)


type Msg
    = NoOp


type alias Server =
    { middleware : MiddlewareFn
    , onStart : List (Cmd Msg)
    }


type alias RunningServer =
    Program Never {} Msg


server : MiddlewareFn -> Server
server middleware =
    { middleware = middleware
    , onStart = []
    }


run : Server -> RunningServer
run server =
    Platform.program
        { init = ( {}, Cmd.batch server.onStart )
        , update = \_ _ -> ( {}, Cmd.none )
        , subscriptions = always Sub.none
        }


listen : String -> Server -> Server
listen address server =
    let
        handleStart =
            Task.perform (always NoOp) (startListening address server.middleware)
    in
        { server | onStart = handleStart :: server.onStart }


startListening : String -> MiddlewareFn -> Task Never Process.Id
startListening address middleware =
    Native.Spruce.listen address
        { onRequest = \req -> middleware NoMiddleware req }
