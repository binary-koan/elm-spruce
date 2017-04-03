module Spruce.Server exposing (..)


type alias Config =
    { bind : String }


type Middleware
    = Nothing


type alias Model =
    { config : Config }


type Msg
    = Request


type alias Updater =
    Msg -> Model -> ( Model, Cmd Msg )


initialState : List Middleware -> Config -> ( Model, Cmd Msg )
initialState middleware config =
    let
        model =
            { config = config }

        cmd =
            Cmd.none
    in
        ( model, cmd )


handleRequest : List Middleware -> Config -> Updater
handleRequest middleware config =
    \msg model -> ( model, Cmd.none )
