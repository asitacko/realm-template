module Test exposing (index, login, main, tests)

import Actions
import Realm.Test as RT
import Routes


main =
    RT.app { tests = tests, title = "Teja" }


tests : List RT.Test
tests =
    [ index, login ]


index : RT.Test
index =
    { id = "index"
    , context = []
    , steps = [ RT.Navigate "Index" "anonymous" Routes.index ]
    }


login : RT.Test
login =
    { id = "login"
    , context = []
    , steps =
        [ RT.Navigate "Login" "anonymous" Routes.login
        , RT.Submit "Index" "logged in" <| Actions.login "amitu" "foo"
        ]
    }
