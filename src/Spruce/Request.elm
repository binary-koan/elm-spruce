module Spruce.Request exposing (..)

import Dict exposing (Dict)


type alias Url =
    { protocol : String
    , auth : String
    , host : String
    , hostname : String
    , port_ : String
    , hash : String
    , search : String
    , query : Dict String String
    , pathname : String
    , path : String
    , href : String
    }


type alias Request =
    { url : Url
    , method : String
    , httpVersion : String
    , headers : Dict String String
    , trailers : Dict String String
    , body : String
    }
