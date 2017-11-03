module Spruce.Bridge exposing (NativeServer, listen, createServer)

import Dict exposing (Dict)
import Task exposing (Task)
import Json.Decode exposing (Decoder, decodeString, field, string, dict)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Json.Encode as E
import Native.Spruce
import Spruce.Routing.Router exposing (..)
import Spruce.Request exposing (Request, Url)
import Spruce.Response exposing (..)


type NativeServer
    = NativeServer


type alias NativeServerOpts =
    { onRequest : String -> Task Never String }


type alias RawRequest =
    { url : String
    , method : String
    , httpVersion : String
    , headers : String
    , trailers : String
    , body : String
    }


listen : String -> Router -> Task String NativeServer
listen address router =
    buildNativeServer (Native.Spruce.listen address) router


createServer : Router -> Task String NativeServer
createServer router =
    buildNativeServer Native.Spruce.createServer router


buildNativeServer : (NativeServerOpts -> Task String NativeServer) -> Router -> Task String NativeServer
buildNativeServer builder router =
    builder { onRequest = handleRequest router }


handleRequest : Router -> String -> Task Never String
handleRequest router raw =
    decodeRequest raw
        |> Result.map router
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
    { emptyResponse | status = 500 }


encodeResponse : Response -> Task Never String
encodeResponse response =
    Task.succeed <|
        E.encode 0
            (E.object
                [ ( "statusCode", E.int response.status )
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
