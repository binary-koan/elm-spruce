module Spruce exposing (..)

{-| Description description description. Do it later, but don't forget!

# Basics
@docs Server, listen

-}

import Spruce.Server exposing (..)


{-| Server
-}
type alias Server =
    Program Never Model Msg


{-| Create a basic server which uses middleware to handle requests
-}
listen : String -> List Middleware -> Server
listen address middleware =
    Platform.program
        { init = initialState address middleware
        , update = updater middleware
        , subscriptions = handleEvents address middleware
        }
