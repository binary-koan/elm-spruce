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


testBasicRequest : String -> String -> Request
testBasicRequest method path =
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
    , method = method
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


testGet : String -> List Step -> Response -> Expect.Expectation
testGet path steps response =
    testResponse (router steps) (testBasicRequest "GET" path) response


all : Test
all =
    describe "Spruce Router"
        [ describe "root"
            [ test "the response is set when the request path is /" <|
                \() -> testGet "/" [ root [ text "Root!" ] ] (textResponse "Root!")
            , test "the response is not set when the request path exists" <|
                \() -> testGet "/test" [ root [ text "Root!" ] ] emptyResponse
            ]
        , describe "path matching"
            [ test "the response is set when the request path matches" <|
                \() -> testGet "/test" [ on "test" [ text "Test path!" ] ] (textResponse "Test path!")
            , test "the response is set when the first part of the request path matches" <|
                \() -> testGet "/test/bla" [ on "test" [ text "Test path!" ] ] (textResponse "Test path!")
            , test "the response is not set when the request path does not match" <|
                \() -> testGet "/testanother" [ on "test" [ text "Test path!" ] ] emptyResponse
            ]
        , describe "subpath matching"
            [ test "the response is set when the request path matches" <|
                \() -> testGet "/test/thing" [ on "test" [ on "thing" [ text "Thing path!" ] ] ] (textResponse "Thing path!")
            , test "the response is not set when the request path matches only the first part" <|
                \() -> testGet "/test" [ on "test" [ on "thing" [ text "Thing path!" ] ] ] emptyResponse
            ]
        , describe "param matching"
            [ test "the param is set when a param is supplied" <|
                \() -> testGet "/test/1" [ on "test" [ onParam (\id -> [ text id ]) ] ] (textResponse "1")
            , test "the param is set correctly when the path continues after the param" <|
                \() -> testGet "/test/1/2" [ on "test" [ onParam (\id -> [ text id ]) ] ] (textResponse "1")
            , test "the response is not changed when a param is not supplied" <|
                \() -> testGet "/test/" [ on "test" [ onParam (\id -> [ text id ]) ] ] emptyResponse
            ]
        , describe "nested param matching"
            [ test "the params are set correctly" <|
                \() ->
                    testGet "/test/1/2"
                        [ on "test"
                            [ onParam
                                (\id ->
                                    [ onParam
                                        (\id2 ->
                                            [ text (id ++ " " ++ id2) ]
                                        )
                                    ]
                                )
                            ]
                        ]
                        (textResponse "1 2")
            ]
        ]
