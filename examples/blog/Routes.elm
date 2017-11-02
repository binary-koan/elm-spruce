module Routes exposing (routes)

import Resources.Articles as Articles
import Resources.Authors as Authors

r =
    router
        root
        [ on "articles"
            [ do checkAuthenticated
            , is
                [ method GET [ attempt Articles.index resourceError ]
                , method POST [ attempt Articles.create resourceError ]
                ]
            , onParam "id"
                (\id ->
                    [ is
                        [ method GET [ attempt (Articles.show id) resourceError ]
                        , method PUT [ attempt (Articles.update id) resourceError ]
                        , method DELETE [ attempt (Articles.destroy id) resourceError ]
                        ]
                    ]
                )
            ]
        ]


r2 =
    router
        [ get "login" Auth.login
        , withAuthentication
            [ Articles.resource
            , Authors.resource
            ]
        ]


login : Route
login =
    [ json "bla" ]


create : Route
create =
    let
        createArticle =
            bla

        handleError =
            bla
    in
        [ attempt createArticle handleError ]

withAuthentication : List Route -> Route
withAuthentication routes =
    withRequest (req ->
        if Dict.get req.headers "auth-token" == authToken then
            routes
        else
            bailOut
    )
