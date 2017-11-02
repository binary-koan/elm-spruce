module Main exposing (..)

import Spruce exposing (..)
import Spruce.Middleware exposing (..)
import Spruce.Routing.Router exposing (..)
import Spruce.Routing.Steps exposing (..)


homepage : List Step
homepage =
    [ text "Homepage!" ]


showProject : String -> List Step
showProject id =
    [ text ("Project " ++ id ++ "!") ]


routes : Middleware
routes =
    router
        [ root homepage
        , on "projects"
            [ onParam "id" (\id -> showProject id)
            ]
        ]


main : RunningServer
main =
    server [ routes ]
        |> listen "localhost:4000"
        |> run
