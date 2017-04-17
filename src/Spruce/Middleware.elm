module Spruce.Middleware exposing (..)

import Task exposing (Task)
import Spruce.Request exposing (..)
import Spruce.Response exposing (..)

type Middleware
    = NoMiddleware
    | DefinedMiddleware MiddlewareFn

type alias MiddlewareFn
    = Middleware -> Request -> Task Never Response
