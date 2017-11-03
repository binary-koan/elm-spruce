module Spruce.Routing.Router exposing (..)

import Spruce.Routing.Steps exposing (Step(..))
import Spruce.Request exposing (Request)
import Spruce.Response exposing (Response, emptyResponse)
import Task exposing (Task)
import Regex exposing (..)


type alias Router =
    Request -> Task Never Response


type alias RoutingContext =
    { request : Request
    , response : Response
    , remainingPath : String
    , stopped : Bool
    }


router : List Step -> Request -> Task Never Response
router steps request =
    runSteps (emptyContext request) steps
        |> Task.andThen (Task.succeed << .response)


runSteps : RoutingContext -> List Step -> Task Never RoutingContext
runSteps context steps =
    let
        unwrapTask handler step task =
            task |> Task.andThen (handler step)

        unlessFinished handler step ctx =
            if ctx.stopped then
                Task.succeed ctx
            else
                handler step ctx

        nextStep step ctx =
            case step of
                OnPath path steps ->
                    handleOnPath ctx path steps

                OnParam handler ->
                    handleOnParam ctx handler

                PathMatched steps ->
                    handlePathMatched ctx steps

                OnMethod method steps ->
                    handleOnMethod ctx method steps

                WithRequest handler ->
                    handler ctx.request
                        |> Task.andThen (runSteps ctx)

                TransformResponse transformer ->
                    Task.succeed { ctx | response = (transformer ctx.response) }
    in
        List.foldl (unwrapTask (unlessFinished nextStep)) (Task.succeed context) steps


handleOnPath : RoutingContext -> String -> List Step -> Task Never RoutingContext
handleOnPath context path steps =
    let
        matchesPath path =
            String.startsWith ("/" ++ path) context.remainingPath

        pathWithoutMatch =
            String.dropLeft (String.length path + 1) context.remainingPath
    in
        if matchesPath context.remainingPath then
            runSteps { context | remainingPath = pathWithoutMatch } steps
                |> Task.andThen (\ctx -> Task.succeed { ctx | stopped = True })
        else
            Task.succeed context


handleOnParam : RoutingContext -> (String -> List Step) -> Task Never RoutingContext
handleOnParam context handler =
    let
        paramRegex =
            regex "/([^/]+)"

        paramMatch =
            find (AtMost 1) paramRegex context.remainingPath

        pathWithoutMatch match =
            String.dropLeft (String.length match.match) context.remainingPath

        paramValue match =
            List.head match.submatches |> Maybe.withDefault (Just "") |> Maybe.withDefault ""
    in
        case paramMatch of
            [ match ] ->
                runSteps { context | remainingPath = pathWithoutMatch match } (handler (paramValue match))

            _ ->
                Task.succeed context


handlePathMatched : RoutingContext -> List Step -> Task Never RoutingContext
handlePathMatched context steps =
    if String.isEmpty context.remainingPath then
        runSteps context steps
    else
        Task.succeed context


handleOnMethod : RoutingContext -> String -> List Step -> Task Never RoutingContext
handleOnMethod context method steps =
    if String.toLower context.request.method == String.toLower method then
        runSteps context steps
    else
        Task.succeed context


stopRouting : RoutingContext -> RoutingContext
stopRouting context =
    { context | stopped = True }


emptyContext : Request -> RoutingContext
emptyContext request =
    { request = request, response = emptyResponse, remainingPath = request.url.path, stopped = False }
