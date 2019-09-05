module Requests exposing (isNameAvailable)

import Http
import Json.Decode as JD
import Realm.Requests as RR


isNameAvailable : (RR.ApiData Bool -> msg) -> String -> Cmd msg
isNameAvailable msg name =
    Http.get
        { url = "/api/is_name_available/?name=" ++ name
        , expect = Http.expectJson (RR.try >> msg) (RR.bresult JD.bool)
        }
