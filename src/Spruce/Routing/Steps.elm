module Spruce.Routing.Steps exposing (..)

import Spruce.Request exposing (Request)
import Spruce.Response exposing (Response)
import Task exposing (Task)
import Dict exposing (Dict)


type Step
    = OnPath String (List Step)
    | OnParam String (String -> List Step)
    | PathMatched (List Step)
    | OnMethod Method (List Step)
    | WithRequest (Request -> List Step)
    | Attempt (Task Never (List Step))
    | TransformResponse (Response -> Response)


type Method
    = GET
    | POST
    | PUT
    | DELETE


on : String -> List Step -> Step
on path steps =
    OnPath path steps


onParam : String -> (String -> List Step) -> Step
onParam name handler =
    OnParam name handler


is : List Step -> Step
is steps =
    PathMatched steps


root : List Step -> Step
root =
    is


method : Method -> List Step -> Step
method m steps =
    OnMethod m steps


withRequest : (Request -> List Step) -> Step
withRequest handler =
    WithRequest handler


attempt : Task Never (List Step) -> Step
attempt task =
    Attempt task


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
