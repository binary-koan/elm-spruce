module Spruce.Router exposing (router, parseRoutes)

import Regex exposing (Regex, HowMany(..), regex)
import Spruce.Middleware exposing (..)
import Spruce.Request exposing (..)


type alias Route =
    { method : String
    , path : Regex
    , fn : Middleware
    }


router : List ( String, Middleware ) -> Middleware
router routes =
    handler (parseRoutes routes)


handler : List Route -> Middleware
handler routes =
    \next req ->
        case matchRoute req routes of
            Just fn ->
                fn next req

            Nothing ->
                continue next req


parseRoutes : List ( String, Middleware ) -> List Route
parseRoutes routes =
    List.filterMap parseRoute routes


parseRoute : ( String, Middleware ) -> Maybe Route
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
        substituted =
            Regex.replace All (regex ":\\w+") (always "([^/]+)") path
    in
        regex ("^" ++ substituted ++ "$")


matchRoute : Request -> List Route -> Maybe Middleware
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
        methodMatches && (Regex.contains route.path req.url.path)
