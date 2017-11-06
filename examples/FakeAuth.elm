module Main exposing (..)

import Spruce exposing (..)
import Spruce.Routing.Steps exposing (..)
import Testable.Task exposing (succeed)
import Dict


secretPassword : String
secretPassword =
    "secret"


authenticate : List Step -> Step
authenticate steps =
    withRequest
        (\request ->
            if Dict.get "password" request.url.query == Just secretPassword then
                succeed steps
            else
                succeed [ redirect "/" ]
        )


homepage : List Step
homepage =
    [ html ("<html><body><a href='/projects?password=" ++ secretPassword ++ "'>Log in</a></html>") ]


listProjects : List Step
listProjects =
    [ html ("<html><body><a href='/projects/1?password=" ++ secretPassword ++ "'>Project 1</a></body></html>") ]


showProject : String -> List Step
showProject id =
    [ html ("<html><body><h1>Project " ++ id ++ "</h1></body></html>") ]


app : Server
app =
    server
        [ root homepage
        , on "projects"
            [ authenticate
                [ is listProjects
                , onParam (\id -> showProject id)
                ]
            ]
        ]


main : RunningServer
main =
    app
        |> listen "localhost:4000"
        |> run
