module Basic exposing (..)

import Spruce exposing (..)
import Spruce.Request exposing (..)
import Spruce.Response exposing (..)
import Task exposing (Task)


sayHello : Request -> Task Never Response
sayHello req =
    response
        |> text "Hello!"
        |> Task.succeed


main : RunningServer
main =
    server (always sayHello)
        |> listen "localhost:4000"
        |> run
