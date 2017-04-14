module Spruce.Response exposing (..)

type alias Response =
    { body : String }

plainText : String -> Response
plainText body =
    { body = body }
