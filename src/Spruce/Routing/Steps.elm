module Spruce.Routing.Steps exposing (..)

import Spruce.Request exposing (Request)
import Spruce.Response exposing (Response)
import Testable.Task exposing (Task)
import Dict exposing (Dict)


type Step
    = OnPath String (List Step)
    | OnParam (String -> List Step)
    | PathMatched (List Step)
    | RootMatched (List Step)
    | OnMethod String (List Step)
    | WithRequest (Request -> Task Never (List Step))
    | TransformResponse (Response -> Response)


on : String -> List Step -> Step
on fragment steps =
    OnPath ("/" ++ fragment) steps


onParam : (String -> List Step) -> Step
onParam handler =
    OnParam handler


is : List Step -> Step
is steps =
    PathMatched steps


root : List Step -> Step
root steps =
    RootMatched steps


method : String -> List Step -> Step
method m steps =
    OnMethod m steps


withRequest : (Request -> Task Never (List Step)) -> Step
withRequest handler =
    WithRequest handler


text : String -> Step
text body =
    TransformResponse (\response -> { response | body = body })


status : Int -> Step
status code =
    TransformResponse (\response -> { response | status = code })


setHeader : String -> String -> Step
setHeader name value =
    TransformResponse (\response -> { response | headers = Dict.insert name value response.headers })


setTrailer : String -> String -> Step
setTrailer name value =
    TransformResponse (\response -> { response | trailers = Dict.insert name value response.trailers })
