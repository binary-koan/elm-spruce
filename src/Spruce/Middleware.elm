module Spruce.Middleware exposing (..)

import Task exposing (Task)
import Spruce.Request exposing (..)
import Spruce.Response exposing (..)

type Middleware
    = NoMiddleware
    | Middleware (Middleware -> Request -> Task Never Response)
