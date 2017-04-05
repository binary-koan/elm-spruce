effect module Spruce.Server where { subscription = MySub } exposing (..)

import Process
import Dict
import Task exposing (Task)


type MySub msg
    = RequestReceived msg


type Middleware
    = Nothing


type alias Model =
    {}


type Msg
    = Request


type alias Updater =
    Msg -> Model -> ( Model, Cmd Msg )


initialState : String -> List Middleware -> ( Model, Cmd Msg )
initialState address middleware =
    ( {}, Cmd.none )


handleRequest : List Middleware -> Updater
handleRequest middleware =
    \msg model -> ( model, Cmd.none )



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
        RequestReceived req ->
            RequestReceived (fn req)

onEffects : Platform.Router msg Msg -> List (MySub msg) -> State msg -> Task Never (State msg)
onEffects router newSubs oldState =
    Task.succeed Dict.empty


onSelfMsg : Platform.Router msg Msg -> Msg -> State msg -> Task Never (State msg)
onSelfMsg router msg state =
    Task.succeed state
