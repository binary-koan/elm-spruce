port module Basic exposing (..)

import Spruce exposing (..)


main : Server
main =
    listen "localhost:4000" []

port listen2 : String -> Cmd msg

port onRequest : (String -> msg) -> Sub msg
