port module Spruce.Server exposing (..)

import Json.Decode


type Middleware
    = Nothing


type alias Model =
    { }


type Msg
    = Request


type alias Updater =
    Msg -> Model -> ( Model, Cmd Msg )


initialState : String -> List Middleware -> ( Model, Cmd Msg )
initialState address middleware =
    ( {}, startListening address )


handleRequest : List Middleware -> Updater
handleRequest middleware  =
    \msg model -> ( model, Cmd.none )


port startListening : String -> Cmd msg


port onRequest : (() -> msg) -> Sub msg
