module Spruce.Router exposing (router)

import Regex exposing (Regex, HowMany(..), regex)
import Spruce.Middleware exposing (..)
import Spruce.Request exposing (..)


type alias Route =
    { method : String
    , path : Regex
    , fn : MiddlewareFn
    }


router : List ( String, MiddlewareFn ) -> MiddlewareFn
router routes =
    handler (parseRoutes routes)


handler : List Route -> MiddlewareFn
handler routes =
    \next req ->
        case matchRoute req routes of
            Just fn ->
                fn next req

            Nothing ->
                continue next req


parseRoutes : List ( String, MiddlewareFn ) -> List Route
parseRoutes routes =
    List.filterMap parseRoute routes


parseRoute : ( String, MiddlewareFn ) -> Maybe Route
parseRoute ( desc, fn ) =
    let
        allowedMethods =
            "HEAD|OPTIONS|GET|PUT|PATCH|POST|DELETE"

        matcher =
            regex ("^(" ++ allowedMethods ++ ")?\\s+(/.*)")

        maybeMatch =
            List.head <| Regex.find (AtMost 1) matcher desc

        methodAndPath match =
            case match.submatches of
                method :: path :: _ ->
                    ( Maybe.withDefault "GET" method, Maybe.withDefault "" path )

                _ ->
                    ( "GET", "" )

        method match =
            Tuple.first (methodAndPath match)

        path match =
            pathToRegex (Tuple.second (methodAndPath match))
    in
        case maybeMatch of
            Just match ->
                Just { method = method match, path = path match, fn = fn }

            Nothing ->
                (always Nothing) (Debug.log "WARNING: Ignoring malformed route definition" desc)


pathToRegex : String -> Regex
pathToRegex path =
    let
        substituted = Regex.replace All (regex ":\\w+") (always "([^/]+)") path
    in
        regex <| Debug.log "regex" <| ("^" ++ substituted ++ "$")


matchRoute : Request -> List Route -> Maybe MiddlewareFn
matchRoute req routes =
    case routes of
        [] ->
            Nothing

        route :: rest ->
            if matches route req then
                Just route.fn
            else
                matchRoute req rest


matches : Route -> Request -> Bool
matches route req =
    let
        methodMatches =
            req.method == route.method || (req.method == "HEAD" && route.method == "GET")
    in
        Debug.log req.url <| methodMatches && (Regex.contains route.path req.url)
