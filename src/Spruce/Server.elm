effect module Spruce.Server where { subscription = MySub } exposing (..)

import Process
import Task exposing (Task)
import Native.Spruce


-- TEMPORARY, until I figure out what format to use for requests


type alias Request =
    String


type alias Response =
    { body : String }


plainText : String -> Response
plainText body =
    { body = body }


type MySub msg
    = Listen String (List Middleware) (Request -> msg)


type Middleware
    = EmptyMiddleware
    | Middleware (Middleware -> Request -> Task Never Response)


type alias Model =
    { lastRequest : Maybe Request }


type Msg
    = NoOp
    | CannotStartServer CannotStartReason
    | OnRequest Request


initialState : String -> List Middleware -> ( Model, Cmd Msg )
initialState address middleware =
    ( { lastRequest = Nothing }, Cmd.none )


updater : List Middleware -> Msg -> Model -> ( Model, Cmd Msg )
updater middleware msg model =
    case msg of
        OnRequest req ->
            Debug.log "requested" ( { model | lastRequest = Just req }, Cmd.none )

        _ ->
            ( model, Cmd.none )


handleEvents : String -> List Middleware -> Model -> Sub Msg
handleEvents address middleware _ =
    subscription (Listen address middleware OnRequest)



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
        Listen address middleware tagger ->
            Listen address middleware (tagger >> fn)


onEffects : Platform.Router msg Msg -> List (MySub msg) -> State msg -> Task Never (State msg)
onEffects router newSubs oldState =
    let
        ( address, middleware, sub ) =
            case List.head newSubs of
                Just (Listen address middleware sub) ->
                    ( address, middleware, Just sub )

                Nothing ->
                    ( "", [ EmptyMiddleware ], Nothing )
    in
        if List.length newSubs /= 1 || oldState.serverStarted then
            Native.Spruce.explode "You need to start exactly one server right now ..."
        else
            attemptListen router middleware address
                |> Task.andThen (\pid -> Task.succeed { serverStarted = True, sub = sub, pid = Just pid })


onSelfMsg : Platform.Router msg Msg -> Msg -> State msg -> Task Never (State msg)
onSelfMsg router msg state =
    Task.succeed state



--


attemptListen : Platform.Router msg Msg -> List Middleware -> String -> Task x Process.Id
attemptListen router middleware address =
    let
        goodOpen ws =
            Platform.sendToSelf router NoOp

        badOpen _ =
            Platform.sendToSelf router (CannotStartServer UnknownError)

        actuallyAttemptListen =
            listen address middleware router
                |> Task.andThen goodOpen
                |> Task.onError badOpen
    in
        Process.spawn actuallyAttemptListen


listen : String -> List Middleware -> Platform.Router msg Msg -> Task x Process.Id
listen address middleware router =
    let
        firstMiddleware =
            Maybe.withDefault EmptyMiddleware (List.head middleware)
    in
        Native.Spruce.listen address
            -- { onRequest = \req -> Platform.sendToSelf router (OnRequest req) }
            { onRequest = \req -> runMiddleware firstMiddleware req }


runMiddleware : Middleware -> Request -> Task Never Response
runMiddleware middleware req =
    case middleware of
        Middleware fn ->
            fn EmptyMiddleware req

        EmptyMiddleware ->
            Task.succeed <| plainText "404"
