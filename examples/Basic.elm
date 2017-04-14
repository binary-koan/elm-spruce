module Basic exposing (..)

import Spruce exposing (..)
import Spruce.Middleware exposing (..)
import Spruce.Request exposing (..)
import Spruce.Response exposing (..)
import Task exposing (Task)

helloMiddleware : Middleware -> Request -> Task Never Response
helloMiddleware next req =
    Task.succeed <| plainText "Hello!"


main : Server
main =
    listen "localhost:4000" (Middleware helloMiddleware)
