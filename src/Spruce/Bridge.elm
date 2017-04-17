module Spruce.Bridge exposing (listen)

import Dict exposing (Dict)
import Process
import Task exposing (Task)
import Json.Decode as D
import Json.Encode as E
import Native.Spruce
import Spruce.Middleware exposing (..)
import Spruce.Request exposing (Request)
import Spruce.Response exposing (..)


type alias RawRequest =
    { url : String
    , method : String
    , httpVersion : String
    , headers : String
    , trailers : String
    , body : String
    }


listen : String -> MiddlewareFn -> Task Never Process.Id
listen address middleware =
    Native.Spruce.listen address
        { onRequest = handleRequest middleware }


handleRequest : MiddlewareFn -> String -> Task Never String
handleRequest middleware raw =
    decodeRequest raw
        |> Result.map (middleware NoMiddleware)
        |> Result.mapError
            (\e -> Debug.log ("ERROR: Native.Spruce produced an invalid request. " ++ e) raw)
        |> Result.withDefault (Task.succeed defaultResponse)
        |> Task.andThen encodeResponse


decodeRequest : String -> Result String Request
decodeRequest =
    D.decodeString <|
        D.map6 Request
            (D.field "url" D.string)
            (D.field "method" D.string)
            (D.field "httpVersion" D.string)
            (D.field "headers" (D.dict D.string))
            (D.field "trailers" (D.dict D.string))
            (D.field "body" D.string)


defaultResponse : Response
defaultResponse =
    -- TODO what should we actually do if there's a bug in the bridge/native code?
    response |> status ServerError


encodeResponse : Response -> Task Never String
encodeResponse response =
    Task.succeed <|
        E.encode 0
            (E.object
                [ ( "status", E.int (statusCode response.status) )
                , ( "headers", encodeDict response.headers )
                , ( "trailers", encodeDict response.trailers )
                , ( "body", E.string response.body )
                ]
            )


encodeDict : Dict String String -> E.Value
encodeDict dict =
    dict
        |> Dict.map (always E.string)
        |> Dict.toList
        |> E.object
