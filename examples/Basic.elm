module Basic exposing (..)

import Spruce.Server exposing (..)
import Spruce.Request exposing (..)
import Spruce.Response exposing (..)
import Task exposing (Task)

sayHello : Request -> Task Never Response
sayHello req =
    Task.succeed <| plainText "Hello!"


main : RunningServer
main =
    server (always sayHello)
        |> listen "localhost:4000"
        |> run
