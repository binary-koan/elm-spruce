module Resources.Authors exposing (actions)

import Spruce.Resource exposing (..)
import Spruce.Router exposing (..)
import Task exposing (Task)


create : List RouterStep
create _ =
    [ status 200, text "Created!" ]


actions : List Action
actions =
    [ Create create ]
