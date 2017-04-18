module Spruce.Bridge exposing (listen)

import Dict exposing (Dict)
import Process
import Task exposing (Task)
import Json.Decode exposing (Decoder, decodeString, field, string, dict)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Json.Encode as E
import Native.Spruce
import Spruce.Middleware exposing (..)
import Spruce.Request exposing (Request, Url)
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
    decode Request
        |> required "url" decodeUrl
        |> required "method" string
        |> required "httpVersion" string
        |> required "headers" (dict string)
        |> required "trailers" (dict string)
        |> required "body" string
        |> decodeString


decodeUrl : Decoder Url
decodeUrl =
    decode Url
        |> optional "protocol" string ""
        |> optional "auth" string ""
        |> optional "host" string ""
        |> optional "hostname" string ""
        |> optional "port" string ""
        |> optional "hash" string ""
        |> optional "search" string ""
        |> required "query" (dict string)
        |> optional "pathname" string ""
        |> optional "path" string ""
        |> required "href" string


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
