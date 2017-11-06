module Spruce.Routing.Router exposing (..)

import Spruce.Routing.Steps exposing (Step(..))
import Spruce.Request exposing (Request)
import Spruce.Response exposing (Response, emptyResponse)
import Testable.Task exposing (..)
import Regex exposing (..)


type alias Router =
    Request -> Task Never Response


type alias RoutingContext =
    { request : Request
    , response : Response
    , remainingPath : String
    , stopped : Bool
    }


router : List Step -> Router
router steps request =
    runSteps (emptyContext request) steps
        |> andThen (succeed << .response)


runSteps : RoutingContext -> List Step -> Task Never RoutingContext
runSteps context steps =
    let
        unwrapTask handler step task =
            task |> andThen (handler step)

        unlessFinished handler step ctx =
            if ctx.stopped then
                succeed ctx
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

                RootMatched steps ->
                    handleRootMatched ctx steps

                OnMethod method steps ->
                    handleOnMethod ctx method steps

                WithRequest handler ->
                    handler ctx.request
                        |> andThen (runSteps ctx)

                TransformResponse transformer ->
                    succeed { ctx | response = (transformer ctx.response) }
    in
        List.foldl (unwrapTask (unlessFinished nextStep)) (succeed context) steps


handleOnPath : RoutingContext -> String -> List Step -> Task Never RoutingContext
handleOnPath context path steps =
    let
        pathMatches =
            String.startsWith path context.remainingPath && (String.isEmpty pathWithoutMatch || String.startsWith "/" pathWithoutMatch)

        pathWithoutMatch =
            String.dropLeft (String.length path) context.remainingPath
    in
        if pathMatches then
            runSteps { context | remainingPath = pathWithoutMatch } steps
                |> andThen (\ctx -> succeed { ctx | stopped = True })
        else
            succeed context


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
                succeed context


handlePathMatched : RoutingContext -> List Step -> Task Never RoutingContext
handlePathMatched context steps =
    if String.isEmpty context.remainingPath || context.remainingPath == "/" then
        runSteps context steps
    else
        succeed context


handleRootMatched : RoutingContext -> List Step -> Task Never RoutingContext
handleRootMatched context steps =
    if context.request.url.path == "/" && context.remainingPath == "/" then
        runSteps context steps
    else
        succeed context


handleOnMethod : RoutingContext -> String -> List Step -> Task Never RoutingContext
handleOnMethod context method steps =
    if String.toLower context.request.method == String.toLower method then
        runSteps context steps
    else
        succeed context


stopRouting : RoutingContext -> RoutingContext
stopRouting context =
    { context | stopped = True }


emptyContext : Request -> RoutingContext
emptyContext request =
    { request = request, response = emptyResponse, remainingPath = request.url.path, stopped = False }
