module Pages.LoginTest exposing (main)

import Pages.Login as M
import Realm as R
import Realm.Utils exposing (fieldError)
import Widgets.BaseTest as BaseTest


main =
    R.test0 M.app init


init : R.In -> R.TestFlags M.Config -> ( M.Model, Cmd (R.Msg M.Msg) )
init in_ test =
    let
        ( m, c ) =
            M.app.init in_ test.config
    in
    case test.id of
        "anonymous" ->
            ( m
            , R.result c [ BaseTest.anonymous "base" test.config.base, R.TestDone ]
            )

        "unknown-user" ->
            ( m
            , R.result c
                [ BaseTest.anonymous "base" test.config.base
                , fieldError "username-error"
                    "username"
                    "Username not found."
                    in_
                    test.config.form
                , R.TestDone
                ]
            )

        "incorrect-password" ->
            ( m
            , R.result c
                [ BaseTest.anonymous "base" test.config.base
                , fieldError "password-error"
                    "password"
                    "Incorrect password."
                    in_
                    test.config.form
                , R.TestDone
                ]
            )

        _ ->
            ( m, R.result c [ R.TestFailed test.id "id not known" ] )
