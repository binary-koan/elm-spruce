module Spruce.Response exposing (..)

import Dict exposing (Dict)


-- type Status
--     = Ok
--     | NotFound
--     | ServerError
--     | CustomStatus Int


type alias Response =
    { status : Int
    , headers : Dict String String
    , trailers : Dict String String
    , body : String
    }



-- Creating responses


emptyResponse : Response
emptyResponse =
    { status = 200
    , headers = Dict.empty
    , trailers = Dict.empty
    , body = ""
    }



-- Utilities
-- statusCode : Status -> Int
-- statusCode status =
--     case status of
--         Ok ->
--             200
--         NotFound ->
--             404
--         ServerError ->
--             500
--         CustomStatus code ->
--             code
