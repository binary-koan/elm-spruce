module Main exposing (..)

import Spruce exposing (..)
import Spruce.Middleware exposing (..)
import Spruce.Request exposing (..)
import Spruce.Response exposing (..)
import Spruce.Router exposing (..)
import Task exposing (Task)


homepage : Request -> Task Never Response
homepage req =
    response
        |> text "Homepage!"
        |> Task.succeed


showProject : Request -> Task Never Response
showProject req =
    response
        |> text "Project X!"
        |> Task.succeed


routes : MiddlewareFn
routes =
    router
        [ ( "GET /", always homepage )
        , ( "GET /projects/:id", always showProject )
        ]


main : RunningServer
main =
    server routes
        |> listen "localhost:4000"
        |> run
