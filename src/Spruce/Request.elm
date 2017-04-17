module Spruce.Request exposing (..)

import Dict exposing (Dict)


type alias Request =
    { url : String
    , method : String
    , httpVersion : String
    , headers : Dict String String
    , trailers : Dict String String
    , body : String
    }
