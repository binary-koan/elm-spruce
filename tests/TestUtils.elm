module TestUtils exposing (..)

import Spruce.Middleware exposing (..)
import Spruce.Response exposing (..)
import Task


emptyMiddleware : Middleware
emptyMiddleware _ _ =
    response |> Task.succeed
