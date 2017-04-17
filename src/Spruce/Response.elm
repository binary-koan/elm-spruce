module Spruce.Response exposing (..)

import Dict exposing (Dict)


type Status
    = Ok
    | NotFound
    | CustomStatus Int


type alias Response =
    { status : Status
    , headers : Dict String String
    , trailers : Dict String String
    , body : String
    }


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
