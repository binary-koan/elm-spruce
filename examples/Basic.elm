module Main exposing (..)

import Spruce exposing (..)
import Spruce.Routing.Steps exposing (..)


homepage : List Step
homepage =
    [ text "Homepage!" ]


showProject : String -> List Step
showProject id =
    [ text ("Project " ++ id ++ "!") ]


app : Server
app =
    server
        [ root homepage
        , on "projects"
            [ onParam (\id -> showProject id)
            ]
        ]


main : RunningServer
main =
    app
        |> listen "localhost:4000"
        |> run
