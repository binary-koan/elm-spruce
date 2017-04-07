module Basic exposing (..)

import Spruce exposing (..)


main : Server
main =
    listen "localhost:4000" []
