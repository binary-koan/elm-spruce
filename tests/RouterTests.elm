module RouterTests exposing (..)

import Test exposing (..)
import Expect
import Spruce.Router exposing (router, parseRoutes)
import TestUtils exposing (..)


all : Test
all =
    describe "Spruce Router"
        [ describe "route parsing"
            [ test "supported methods are parsed" <|
                let
                    routes =
                        parseRoutes
                            [ ( "HEAD /", emptyMiddleware )
                            , ( "OPTIONS /", emptyMiddleware )
                            , ( "GET /", emptyMiddleware )
                            , ( "PUT /", emptyMiddleware )
                            , ( "PATCH /", emptyMiddleware )
                            , ( "POST /", emptyMiddleware )
                            , ( "DELETE /", emptyMiddleware )
                            ]
                in
                    \() ->
                        Expect.equal (List.length routes) 7
            , test "unsupported methods are ignored" <|
                let
                    routes =
                        parseRoutes
                            [ ( "GET /", emptyMiddleware )
                            , ( "POST /", emptyMiddleware )
                            , ( "BLAH /", emptyMiddleware )
                            , ( "put /", emptyMiddleware )
                            , ( "Hello /", emptyMiddleware )
                            ]
                in
                    \() ->
                        Expect.equal (List.length routes) 2
            ]
        ]



-- describe "Sample Test Suite"
--     [ describe "Unit test examples"
--         [ test "Addition" <|
--             \() ->
--                 Expect.equal (3 + 7) 10
--         , test "String.left" <|
--             \() ->
--                 Expect.equal "a" (String.left 1 "abcdefg")
--         , test "This test should fail - you should remove it" <|
--             \() ->
--                 Expect.fail "Failed as expected!"
--         ]
--     , describe "Fuzz test examples, using randomly generated input"
--         [ fuzz (list int) "Lists always have positive length" <|
--             \aList ->
--                 List.length aList |> Expect.atLeast 0
--         , fuzz (list int) "Sorting a list does not change its length" <|
--             \aList ->
--                 List.sort aList |> List.length |> Expect.equal (List.length aList)
--         , fuzzWith { runs = 1000 } int "List.member will find an integer in a list containing it" <|
--             \i ->
--                 List.member i [ i ] |> Expect.true "If you see this, List.member returned False!"
--         , fuzz2 string string "The length of a string equals the sum of its substrings' lengths" <|
--             \s1 s2 ->
--                 s1 ++ s2 |> String.length |> Expect.equal (String.length s1 + String.length s2)
--         ]
--     ]
