module Spruce.Middleware exposing (..)

import Task exposing (Task)
import Spruce.Request exposing (..)
import Spruce.Response exposing (..)


type MiddlewareChain
    = NoMiddleware
    | ChainedMiddleware (Request -> Task Never Response)


type alias Middleware =
    MiddlewareChain -> Request -> Task Never Response


compose : List Middleware -> MiddlewareChain
compose middleware =
    let
        addToChain next chain =
            ChainedMiddleware (next chain)
    in
        List.foldr addToChain NoMiddleware middleware


continue : MiddlewareChain -> Request -> Task Never Response
continue middleware req =
    case middleware of
        NoMiddleware ->
            response |> status NotFound |> Task.succeed

        ChainedMiddleware fn ->
            fn req
