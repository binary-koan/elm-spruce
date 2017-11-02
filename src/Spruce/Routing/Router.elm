module Spruce.Routing.Router exposing (..)

import Spruce.Routing.Steps exposing (Step)
import Spruce.Middleware exposing (Middleware, MiddlewareChain(..))
import Spruce.Response exposing (emptyResponse)
import Task exposing (Task)


router : List Step -> Middleware
router steps =
    (\_ _ -> emptyResponse |> Task.succeed)
