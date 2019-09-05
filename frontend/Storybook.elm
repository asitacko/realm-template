module Storybook exposing (base, base0, index, login, main, register, stories)

import Dict
import Json.Encode as JE
import Pages.Index as Index
import Pages.Login as Login
import Pages.Register as Register
import Realm.Storybook as RSB exposing (Story)
import Realm.Utils as U
import Widgets.Base as Base


main =
    RSB.app { stories = stories, title = "teja" }


stories : List ( String, List Story )
stories =
    [ ( "Index"
      , [ index "anonymous" "Anonymous" "hello" { base = base0 }
        , index "dhruv"
            "Dhruv"
            "Dhruv"
            { base = { name = Just "Super Commando Dhruv" } }
        ]
      )
    , ( "Login"
      , [ login "anonymous" "Empty Form" "hello" { base = base0, form = Dict.empty }
        , login "filled_form"
            "Filled Form"
            "Hello"
            { base = base0
            , form =
                Dict.fromList
                    [ ( "email", ( "hello", Nothing ) )
                    , ( "password", ( "hello", Nothing ) )
                    ]
            }
        , login "incorrect_email"
            "incorrect email"
            "Hello"
            { base = base0
            , form =
                Dict.fromList
                    [ ( "email", ( "hello", Just "email is already registered" ) )
                    , ( "password", ( "some pass", Nothing ) )
                    ]
            }
        , login "incorrect_password"
            "Incorrect Password"
            "Hello"
            { base = base0
            , form =
                Dict.fromList
                    [ ( "email", ( "hello", Nothing ) )
                    , ( "password", ( "some pass", Just "incorrect password" ) )
                    ]
            }
        ]
      )
    , ( "Register"
      , [ register "empty_form" "Empty Form" "hello" { base = base0, form = Dict.empty }
        , register "filled_form"
            "Filled Form"
            "hello"
            { base = base0
            , form =
                Dict.fromList
                    [ ( "password", ( "some pass", Nothing ) )
                    , ( "name", ( "John Doe", Nothing ) )
                    , ( "email", ( "john@doe.com", Nothing ) )
                    ]
            }
        ]
      )
    ]


base0 : Base.Config
base0 =
    { name = Nothing }


base : Base.Config -> JE.Value
base b =
    JE.object [ ( "name", U.maybeS b.name ) ]


index : String -> String -> String -> Index.Config -> Story
index id title pageTitle c =
    { id = id
    , title = title
    , pageTitle = pageTitle
    , elmId = "Pages.Index"
    , config = JE.object [ ( "base", base c.base ) ]
    }


login : String -> String -> String -> Login.Config -> Story
login id title pageTitle c =
    { id = id
    , title = title
    , pageTitle = pageTitle
    , elmId = "Pages.Login"
    , config = JE.object [ ( "base", base c.base ), ( "form", U.formE c.form ) ]
    }


register : String -> String -> String -> Register.Config -> Story
register id title pageTitle c =
    { id = id
    , title = title
    , pageTitle = pageTitle
    , elmId = "Pages.Register"
    , config = JE.object [ ( "base", base c.base ), ( "form", U.formE c.form ) ]
    }
