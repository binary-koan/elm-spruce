module Spruce.Resource exposing (..)

import Spruce.Router exposing (..)


type Action
    = Index (List RouterStep)
    | Create (List RouterStep)
    | Show (String -> List RouterStep)
    | Update (String -> List RouterStep)
    | Destroy (String -> List RouterStep)


routes : String -> List Action -> RouterStep
routes name actions =
    on name
        [ is (rootActions actions)
        , onParam "id"
            (\id ->
                [ is (itemActions id actions) ]
            )
        ]


rootActions : List Action -> List RouterStep
rootActions actions =
    let
        actionHandler action =
            case action of
                Index handler ->
                    Just <| method GET handler

                Create handler ->
                    Just <| method POST handler

                _ ->
                    Nothing
    in
        List.filterMap actionHandler actions


itemActions : String -> List Action -> List RouterStep
itemActions id actions =
    let
        actionHandler action =
            case action of
                Show handler ->
                    Just <| method GET (handler id)

                Update handler ->
                    Just <| method PUT (handler id)

                Destroy handler ->
                    Just <| method DELETE (handler id)

                _ ->
                    Nothing
    in
        List.filterMap actionHandler actions
