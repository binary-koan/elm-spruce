module Basic exposing (..)

import Spruce exposing (..)
import Spruce.Server exposing (Middleware, Request, Response, plainText)
import Task exposing (Task)


helloMiddleware : Middleware -> Request -> Task Never Response
helloMiddleware next req =
    Task.succeed <| plainText "Hello!"


main : Server
main =
    listen "localhost:4000" [ Spruce.Server.Middleware helloMiddleware ]
