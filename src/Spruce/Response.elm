module Spruce.Response exposing (..)

import Dict exposing (Dict)


type Status
    = Ok
    | NotFound
    | ServerError
    | CustomStatus Int


type alias Response =
    { status : Status
    , headers : Dict String String
    , trailers : Dict String String
    , body : String
    }



-- Creating responses


response : Response
response =
    { status = Ok
    , headers = Dict.empty
    , trailers = Dict.empty
    , body = ""
    }


text : String -> Response -> Response
text body response =
    { response | body = body }


status : Status -> Response -> Response
status s response =
    { response | status = s }


addHeader : String -> String -> Response -> Response
addHeader name value response =
    { response | headers = Dict.insert name value response.headers }


addTrailer : String -> String -> Response -> Response
addTrailer name value response =
    { response | trailers = Dict.insert name value response.trailers }



-- Utilities


statusCode : Status -> Int
statusCode status =
    case status of
        Ok ->
            200

        NotFound ->
            404

        ServerError ->
            500

        CustomStatus code ->
            code
