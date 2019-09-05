module Widgets.BaseTest exposing (anonymous)

import Realm as R
import Widgets.Base as M


anonymous : String -> M.Config -> R.TestResult
anonymous id config =
    case config.name of
        Just name ->
            R.TestFailed id <| "expected anonymous, found: " ++ name

        Nothing ->
            R.TestPassed id
