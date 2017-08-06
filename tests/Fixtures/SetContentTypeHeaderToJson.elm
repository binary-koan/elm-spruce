port module Main exposing (testServer)

import Task exposing (Task)
import Spruce exposing (..)
import Spruce.Bridge exposing (NativeServer)
import Spruce.Response exposing (..)

setHeader : Task Never Response
setHeader =
    response
        |> addHeader "Content-Type" "json"
        |> Task.succeed

testServer : Task String NativeServer
testServer =
    server [ always (always setHeader) ]
        |> createServer

type alias Test = { a: String, b: String }

port check : Test -> Cmd msg
