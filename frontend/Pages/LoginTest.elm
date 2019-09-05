module Pages.LoginTest exposing (main)

import Pages.Login as M
import Realm as R


main =
    R.test0 M.app init


init : R.In -> R.TestFlags M.Config -> ( M.Model, Cmd (R.Msg M.Msg) )
init in_ config =
    let
        ( m, c ) =
            M.app.init in_ config.config
    in
    case config.id of
        _ ->
            ( m, c )
