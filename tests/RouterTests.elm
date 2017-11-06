module RouterTests exposing (..)

import Test exposing (..)
import Testable.Cmd
import Testable.TestContext exposing (..)
import Testable.Html exposing (node)
import Testable.Task
import Expect
import Dict
import Spruce.Routing.Router exposing (..)
import Spruce.Routing.Steps exposing (..)
import Spruce.Request exposing (Request)
import Spruce.Response exposing (Response, emptyResponse)


testGet : String -> Request
testGet path =
    { url =
        { protocol = "https"
        , auth = ""
        , host = ""
        , hostname = ""
        , port_ = ""
        , hash = ""
        , search = ""
        , query = Dict.empty
        , pathname = ""
        , path = path
        , href = ""
        }
    , method = "GET"
    , httpVersion = "2"
    , headers = Dict.empty
    , trailers = Dict.empty
    , body = ""
    }


type alias Msg =
    Response


type alias Model =
    { response : Maybe Msg }


testRouter : Router -> Request -> Component Msg Model
testRouter router request =
    { init = ( { response = Nothing }, Testable.Task.perform identity (router request) )
    , update = (\response _ -> ( { response = Just response }, Testable.Cmd.none ))
    , view = (\_ -> node "noop" [] [])
    }


testResponse : Router -> Request -> Response -> Expect.Expectation
testResponse router request response =
    assertCurrentModel { response = Just response } (startForTest (testRouter router request))


textResponse : String -> Response
textResponse text =
    { emptyResponse | body = text }


all : Test
all =
    describe "Spruce Router"
        [ describe "root route"
            [ test "the response is set when the request path is /" <|
                let
                    route =
                        router [ root [ text "Root!" ] ]

                    request =
                        testGet "/"
                in
                    \() ->
                        testResponse route request (textResponse "Root!")
            ]
        ]
