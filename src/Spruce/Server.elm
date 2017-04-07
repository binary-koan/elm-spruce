effect module Spruce.Server where { subscription = MySub } exposing (..)

import Process
import Dict
import Task exposing (Task)


-- TEMPORARY, until I figure out what format to use for requests
type alias Request = String


type MySub msg
    = Listen String (Request -> msg)


type Middleware
    = Nothing


type alias Model =
    {}


type Msg
    = NoOp
    | CannotStartServer CannotStartReason
    | OnRequest String


type alias Updater =
    Msg -> Model -> ( Model, Cmd Msg )


initialState : String -> List Middleware -> ( Model, Cmd Msg )
initialState address middleware =
    ( {}, Cmd.none )


updater : List Middleware -> Updater
updater middleware =
    \msg model -> ( model, Cmd.none )


handleEvents : String -> List Middleware -> Sub Msg
handleEvents address middleware
    = subscription (Listen address OnRequest)

handleListenResult : Result CannotStartReason () -> Msg
handleListenResult result =
    case result of
        Ok _ ->
            NoOp

        Err reason ->
            CannotStartServer reason



-- Native bindings


type CannotStartReason
    = AddressInUse
    | UnknownError


listen : String -> Platform.Router msg Msg -> Task CannotStartReason ()
listen address router =
    Native.Spruce.listen address
        { onRequest = \req -> Platform.sendToSelf router (OnRequest req)
        }



-- Effect module stuff


type alias State msg =
    Dict.Dict String (Watcher msg)


type alias Watcher msg =
    { taggers : List (String -> msg)
    , pid : Process.Id
    }


init : Task Never (State msg)
init =
    Task.succeed Dict.empty


subMap : (a -> b) -> MySub a -> MySub b
subMap fn sub =
    case sub of
        Listen address tagger ->
            Listen address (tagger >> fn)


onEffects : Platform.Router msg Msg -> List (MySub msg) -> State msg -> Task Never (State msg)
onEffects router newSubs oldState =
    Task.succeed Dict.empty


onSelfMsg : Platform.Router msg Msg -> Msg -> State msg -> Task Never (State msg)
onSelfMsg router msg state =
    Task.succeed state
