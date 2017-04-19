module Spruce exposing (Server, RunningServer, server, run, listen)

{-| Description description description. Do it later, but don't forget!

# Basics
@docs Server, RunningServer, server, listen, run

-}

import Task exposing (Task)
import Spruce.Bridge as Bridge
import Spruce.Middleware exposing (..)


type Msg
    = NoOp


{-| Server
-}
type alias Server =
    { middleware : MiddlewareChain
    , onStart : List (Cmd Msg)
    }


{-| RunningServer
-}
type alias RunningServer =
    Program Never {} Msg


{-| server
-}
server : List Middleware -> Server
server middleware =
    { middleware = compose middleware
    , onStart = []
    }

{-| listen
-}
listen : String -> Server -> Server
listen address server =
    let
        handleStart =
            Task.attempt (always NoOp) (Bridge.listen address server.middleware)
    in
        { server | onStart = handleStart :: server.onStart }


{-| run
-}
run : Server -> RunningServer
run server =
    Platform.program
        { init = ( {}, Cmd.batch server.onStart )
        , update = \_ _ -> ( {}, Cmd.none )
        , subscriptions = always Sub.none
        }
