module Spruce exposing (Server, RunningServer, server, run, listen, createServer)

{-|
Spruce is a library which allows you to write your server in Elm. It wraps the
Node.js `http` module, so it needs to be run using Node.

# Types
@docs Server, RunningServer

# Basic functions
@docs server, listen, run, createServer
-}

import Task exposing (Task)
import Spruce.Bridge as Bridge
import Spruce.Routing.Router exposing (..)
import Spruce.Routing.Steps exposing (Step)


type Msg
    = NoOp


{-|
Used for building a web server, which can be started with `run`.
-}
type alias Server =
    { router : Router
    , onStart : List (Cmd Msg)
    }


{-|
Alias for the type of program that the server runs.
-}
type alias RunningServer =
    Program Never {} Msg


{-|
Create a server which will use the given middleware to respond to requests.
Middleware will be composed left-to-right, so the first bit of middleware in
the list will be queried first. Its `next` reference will point to the next
item in the list, and so on.
-}
server : List Step -> Server
server steps =
    { router = router steps
    , onStart = []
    }


{-|
Adds a command to listen on the given address when the server is started.

These addresses are all equivalent:

- `"http://localhost:4000"`
- `"localhost:4000"`
- `":4000"`

You can specify any host and port for the server to listen on. For example,
`"0.0.0.0:4000"` will listen on port 4000 on all interfaces, allowing you to
access your server from other devices on the network.
-}
listen : String -> Server -> Server
listen address server =
    let
        handleStart =
            Task.attempt (always NoOp) (Bridge.listen address server.router)
    in
        { server | onStart = handleStart :: server.onStart }


{-|
Just returns a native Node server.
-}
createServer : Server -> Task String Bridge.NativeServer
createServer server =
    Bridge.createServer server.router


{-|
Actually start the server
-}
run : Server -> RunningServer
run server =
    Platform.program
        { init = ( {}, Cmd.batch server.onStart )
        , update = \_ _ -> ( {}, Cmd.none )
        , subscriptions = always Sub.none
        }
