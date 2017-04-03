module Spruce exposing (..)

{-| Description description description. Do it later, but don't forget!

# Basics
@docs serve

-}

import Spruce.Server exposing (..)


{-| Create a basic server which uses middleware to handle requests
-}
serve : List Middleware -> Config -> Program Never Model Msg
serve middleware config =
    Platform.program
        { init = initialState middleware config
        , update = handleRequest middleware config
        , subscriptions = \model -> Sub.none
        }
