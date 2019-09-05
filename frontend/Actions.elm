port module Actions exposing (login, register)

import Json.Encode as JE
import Types exposing (..)


s : String -> List ( String, JE.Value ) -> JE.Value
s url params =
    [ ( "url", JE.string url ), ( "data", JE.object params ) ]
        |> JE.object


register : String -> Name -> String -> JE.Value
register email name password =
    s "/register/"
        [ ( "name", JE.string (getName name) )
        , ( "email", JE.string email )
        , ( "password", JE.string password )
        ]


login : String -> String -> JE.Value
login email password =
    s "/login/"
        [ ( "email", JE.string email )
        , ( "password", JE.string password )
        ]
