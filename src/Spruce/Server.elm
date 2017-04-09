effect module Spruce.Server where { subscription = MySub } exposing (..)

import Process
import Task exposing (Task)


-- TEMPORARY, until I figure out what format to use for requests


type alias Request =
    String


type MySub msg
    = Listen String (Request -> msg)


type Middleware
    = EmptyMiddleware


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
handleEvents address middleware =
    subscription (Listen address OnRequest)


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



-- Effect module stuff


type alias State msg =
    { serverStarted : Bool
    , sub : Maybe (Request -> msg)
    , pid : Maybe Process.Id
    }


type alias Watcher msg =
    { taggers : List (String -> msg)
    , pid : Process.Id
    }


init : Task Never (State msg)
init =
    Task.succeed { serverStarted = False, sub = Nothing, pid = Nothing }


subMap : (a -> b) -> MySub a -> MySub b
subMap fn sub =
    case sub of
        Listen address tagger ->
            Listen address (tagger >> fn)


onEffects : Platform.Router msg Msg -> List (MySub msg) -> State msg -> Task Never (State msg)
onEffects router newSubs oldState =
    let
        ( address, sub ) =
            case List.head newSubs of
                Just (Listen address sub) ->
                    ( address, Just sub )

                Nothing ->
                    ( "", Nothing )
    in
        if List.length newSubs /= 1 || oldState.serverStarted then
            Native.Spruce.explode "You need to start exactly one server right now ..."
        else
            attemptListen router address
                |> Task.andThen (\pid -> Task.succeed { serverStarted = True, sub = sub, pid = Just pid })


onSelfMsg : Platform.Router msg Msg -> Msg -> State msg -> Task Never (State msg)
onSelfMsg router msg state =
    Task.succeed state



--


attemptListen : Platform.Router msg Msg -> String -> Task x Process.Id
attemptListen router address =
    let
        goodOpen ws =
            Platform.sendToSelf router NoOp

        badOpen _ =
            Platform.sendToSelf router (CannotStartServer UnknownError)

        actuallyAttemptListen =
            listen address router
                |> Task.andThen goodOpen
                |> Task.onError badOpen
    in
        Process.spawn actuallyAttemptListen


listen : String -> Platform.Router msg Msg -> Task x Process.Id
listen address router =
    Native.Spruce.listen
        { onRequest = \req -> Platform.sendToSelf router (OnRequest req) }
